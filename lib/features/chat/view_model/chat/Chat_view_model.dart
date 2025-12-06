import 'dart:async';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
part 'Chat_view_model.g.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isRecipientTyping;
  final bool isLoading;
  final bool isLoadingHistory;
  final bool hasMoreHistory;

  ChatState({
    this.messages = const [],
    this.isRecipientTyping = false,
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.hasMoreHistory = true,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isRecipientTyping,
    bool? isLoading,
    bool? isLoadingHistory,
    bool? hasMoreHistory,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isRecipientTyping: isRecipientTyping ?? this.isRecipientTyping,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
    );
  }
}

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late ChatRemoteRepository _chatRemoteRepository;
  late ChatLocalRepository _chatLocalRepository;
  late SocketRepository _socketRepository;
  UserModel? _currentUser;
  String? _activeChatId;
  String? _myUserId;
  bool _isDisposed = false; //
  final List<MessageModel> _historyBuffer = [];
  final Set<String> _loadedMessageIds = {};
  StreamSubscription? _msgSub;
  StreamSubscription? _ackSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _readSub;
  @override
  ChatState build() {
    _chatRemoteRepository = ref.watch(chatRemoteRepositoryProvider);
    _chatLocalRepository = ref.watch(chatLocalRepositoryProvider);
    _socketRepository = ref.watch(socketRepositoryProvider);
    _currentUser = ref.watch(currentUserProvider);

    _setupSocketListeners();

    ref.onDispose(() {
      print("Disposing ChatViewModel and cancelling subscriptions");
      _isDisposed = true;
      _msgSub?.cancel();
      _ackSub?.cancel();
      _typingSub?.cancel();
      _readSub?.cancel();
    });
    return ChatState(isLoading: false);
  }

  bool isActiveChat(String chatId) => _activeChatId == chatId;

  void _setupSocketListeners() {
    _msgSub = _socketRepository.newMessageStream.listen((data) {
      if (_isDisposed) return;
      print("New message received in ChatVM: $data");
      _handleIncomingMessage(data);
    });

    _ackSub = _socketRepository.messageAddedStream.listen((data) {
      if (_isDisposed) return;
      _handleMessageAck(data);
    });

    _readSub = _socketRepository.messagesReadStream.listen((data) {
      if (_isDisposed) return;
      _handleMessagesRead(data);
    });

    _typingSub = _socketRepository.typingStream.listen((data) {
      if (_isDisposed) return;
      _handleTypingEvent(data);
    });
  }

  List<MessageModel> _sortMessages(List<MessageModel> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  Future<void> loadChat(String chatId) async {
    if (_currentUser == null) return;

    state = state.copyWith(isLoading: true, hasMoreHistory: true);
    _activeChatId = chatId;
    _myUserId = _currentUser!.id;
    _historyBuffer.clear();
    _loadedMessageIds.clear();

    final cachedMessages = _chatLocalRepository.getCachedMessages(chatId);
    _loadedMessageIds.addAll(cachedMessages.map((m) => m.id));

    final sortedCache = _sortMessages(cachedMessages);
    state = state.copyWith(messages: sortedCache);

    final result = await _chatRemoteRepository.getlastChatMessages(chatId);

    if (_activeChatId != chatId) {
      state = state.copyWith(isLoading: false);
      return;
    }

    await result.fold(
      (failure) async {
        if (_isDisposed) return; //
        state = state.copyWith(isLoading: false);
      },
      (serverMessages) async {
        if (_isDisposed) return; //
        await _chatLocalRepository.saveInitialMessages(serverMessages);
        await _reconcilePendingMessages(chatId, serverMessages);

        final updatedCache = _chatLocalRepository.getCachedMessages(chatId);
        _loadedMessageIds.clear();
        _loadedMessageIds.addAll(updatedCache.map((m) => m.id));

        if (_activeChatId != chatId) {
          state = state.copyWith(isLoading: false);
          return;
        }

        final sortedUpdated = _sortMessages(updatedCache);
        if (_isDisposed) return; //
        state = state.copyWith(messages: sortedUpdated, isLoading: false);
        _socketRepository.openChat(chatId);
      },
    );
  }

  Future<void> _reconcilePendingMessages(
    String chatId,
    List<MessageModel> serverMessages,
  ) async {
    final pendingMessages = _chatLocalRepository.getPendingMessages(chatId);
    if (pendingMessages.isEmpty) return;

    for (final pending in pendingMessages) {
      final match = _findMatchingServerMessage(pending, serverMessages);
      if (match != null) {
        await _chatLocalRepository.replaceTempWithServerMessage(
          tempId: pending.id,
          serverMessage: match,
        );
      } else {
        _socketRepository.sendMessage(pending.toApiRequest());
      }
    }
  }

  MessageModel? _findMatchingServerMessage(
    MessageModel pending,
    List<MessageModel> serverMessages,
  ) {
    return serverMessages.cast<MessageModel?>().firstWhere(
      (srv) =>
          srv!.content == pending.content &&
          srv.chatId == pending.chatId &&
          srv.userId == pending.userId &&
          srv.createdAt.difference(pending.createdAt).inSeconds.abs() < 60,
      orElse: () => null,
    );
  }

  Future<void> sendMessage({
    required String content,
    String messageType = 'text',
  }) async {
    if (_activeChatId == null || _myUserId == null) return;

    final tempId = 'temp_${const Uuid().v4()}';
    final now = DateTime.now();

    final localMessage = MessageModel(
      id: tempId,
      chatId: _activeChatId!,
      userId: _myUserId!,
      content: content,
      messageType: messageType,
      createdAt: now,
      status: 'SENDING',
    );

    await _chatLocalRepository.saveMessage(localMessage);

    final updatedMessages = [...state.messages, localMessage];
    state = state.copyWith(messages: updatedMessages);
    _loadedMessageIds.add(tempId);

    ref
        .read(conversationsViewModelProvider.notifier)
        .updateConversationAfterSending(
          chatId: _activeChatId!,
          content: content,
          messageType: messageType,
        );

    _socketRepository.sendMessage(localMessage.toApiRequest());
  }

  void _handleMessageAck(Map<String, dynamic> data) async {
    final chatId = data["chatId"] as String?;
    final realMessageId = data["messageId"] as String?;

    if (chatId == null || realMessageId == null) return;
    if (_activeChatId != chatId) return;

    final index = state.messages.indexWhere(
      (m) => m.status == "SENDING" && m.chatId == chatId,
    );

    if (index == -1) return;

    final tempMsg = state.messages[index];

    final serverMessage = tempMsg.copyWith(id: realMessageId, status: "SENT");

    await _chatLocalRepository.replaceTempWithServerMessage(
      tempId: tempMsg.id,
      serverMessage: serverMessage,
    );

    _loadedMessageIds.remove(tempMsg.id);
    _loadedMessageIds.add(realMessageId);

    final updatedMessages = [...state.messages];
    updatedMessages[index] = serverMessage;
    state = state.copyWith(messages: updatedMessages);
  }

  void _handleIncomingMessage(Map<String, dynamic> data) async {
    final msg = MessageModel.fromApiResponse(data);

    if (msg.userId == _myUserId) return;
    if (_loadedMessageIds.contains(msg.id)) return;

    final isActiveChat = (_activeChatId == msg.chatId);
    final finalMsg = msg.copyWith(status: isActiveChat ? "READ" : msg.status);

    await _chatLocalRepository.saveMessage(finalMsg);

    print("is in chat ${isActiveChat}");
    if (isActiveChat) {
      final updatedMessages = [...state.messages, finalMsg];
      if (_isDisposed || _activeChatId != msg.chatId) return; //
      state = state.copyWith(messages: updatedMessages);
      _loadedMessageIds.add(msg.id);
      _socketRepository.openChat(_activeChatId!); // to decrease unseen count
    }
  }

  void _handleMessagesRead(Map<String, dynamic> data) async {
    final chatId = data['chatId'] as String?;
    if (chatId == null || chatId != _activeChatId) return;

    final messagesBeforeUpdate = [...state.messages];

    await _chatLocalRepository.markMessagesAsRead(chatId, _myUserId!);

    final updatedMessages = messagesBeforeUpdate.map((msg) {
      if (msg.chatId == chatId &&
          msg.userId == _myUserId &&
          msg.status != "READ") {
        return msg.copyWith(status: "READ");
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> loadOlderMessages() async {
    if (_activeChatId == null ||
        state.isLoadingHistory ||
        !state.hasMoreHistory) {
      return;
    }

    final allCurrentMessages = [...state.messages, ..._historyBuffer];
    if (allCurrentMessages.isEmpty) return;

    final sortedCurrent = _sortMessages(allCurrentMessages);
    final oldestMessage = sortedCurrent.first;
    final lastTimestamp = oldestMessage.createdAt;

    state = state.copyWith(isLoadingHistory: true);

    final result = await _chatRemoteRepository.getOlderMessagesChat(
      chatId: _activeChatId!,
      lastMessageTimestamp: lastTimestamp,
    );

    await result.fold(
      (failure) async {
        if (_isDisposed) return; //
        state = state.copyWith(isLoadingHistory: false);
      },
      (olderMessages) async {
        if (_isDisposed) return; //
        if (olderMessages.isEmpty) {
          state = state.copyWith(
            isLoadingHistory: false,
            hasMoreHistory: false,
          );
          return;
        }

        final newMessages = olderMessages
            .where((msg) => !_loadedMessageIds.contains(msg.id))
            .toList();

        _historyBuffer.addAll(newMessages);
        _loadedMessageIds.addAll(newMessages.map((m) => m.id));

        final allMessages = [..._historyBuffer, ...state.messages];

        state = state.copyWith(messages: allMessages, isLoadingHistory: false);
      },
    );
  }

  void sendTyping(bool isTyping) {
    if (_activeChatId == null) return;
    _socketRepository.sendTyping(_activeChatId!, isTyping);
  }

  void _handleTypingEvent(dynamic data) {
    if (_activeChatId == null) return;

    final typingChatId = data['chatId'] as String?;
    final typingUserId = data['userId'] as String?;

    if (typingChatId != _activeChatId || typingUserId == _myUserId) return;

    final isTyping = data['isTyping'] as bool? ?? false;
    state = state.copyWith(isRecipientTyping: isTyping);
  }

  // void exitChat() {
  //   if (_activeChatId == null) return;
  //   _activeChatId = null;
  //   _historyBuffer.clear();
  //   _loadedMessageIds.clear();
  //   state = ChatState(isRecipientTyping: false, messages: [], isLoading: false);
  // }
}
