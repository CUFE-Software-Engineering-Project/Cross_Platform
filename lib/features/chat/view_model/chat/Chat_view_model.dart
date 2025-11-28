import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'Chat_view_model.g.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isRecipientTyping;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isRecipientTyping = false,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isRecipientTyping,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isRecipientTyping: isRecipientTyping ?? this.isRecipientTyping,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatViewModel extends _$ChatViewModel {
  late ChatRemoteRepository _chatRemoteRepository;
  late ChatLocalRepository _chatLocalRepository;
  late SocketRepository _socketRepository;
  UserModel? _currentUser;
  String? _activeChatId;
  String? _myUserId;

  @override
  ChatState build() {
    _chatRemoteRepository = ref.watch(chatRemoteRepositoryProvider);
    _chatLocalRepository = ref.watch(chatLocalRepositoryProvider);
    _socketRepository = ref.watch(socketRepositoryProvider);
    _currentUser = ref.watch(currentUserProvider);

    _setupSocketListeners();

    ref.onDispose(() {
      _socketRepository.disposeListeners();
    });
    return ChatState(isLoading: false);
  }

  bool isActiveChat(String chatId) => _activeChatId == chatId;

  void _setupSocketListeners() {
    print("Setting up Socket Listeners in ViewModel...");
    _socketRepository.onNewMessage((data) {
      print("ViewModel Received Message Event");
      if (_activeChatId == null) return;
      if (data['chatId'] == _activeChatId) {
        handleIncomingMessage(data);
      }
    });
    _socketRepository.onMessageAdded((data) {
      if (_activeChatId == null) return;
      handleMessageAdded(data);
    });

    _socketRepository.onMessagesRead((data) {
      if (_activeChatId == null) return;
      handleMessagesRead(data);
    });

    _socketRepository.onTyping((data) {
      if (_activeChatId == null) return;
      handleTypingEvent(data);
    });
  }

  void handleMessageAdded(Map<String, dynamic> data) async {
    final chatId = data["chatId"];
    final realMessageId = data["messageId"];
    if (_activeChatId != chatId) return;

    final index = state.messages.indexWhere(
      (m) => m.status == "PENDING" && m.chatId == chatId,
    );

    if (index == -1) return;

    final tempMsg = state.messages[index];

    final updatedMsg = tempMsg.copyWith(id: realMessageId, status: "SENT");
    final updated = [...state.messages];
    updated[index] = updatedMsg;
    state = state.copyWith(messages: updated);

    _chatLocalRepository.saveMessage(updatedMsg);
  }

  // load messages (offline first)
  Future<void> loadChat(String chatId) async {
    if (_currentUser == null) {
      print("Error: No current user found");
      return;
    }

    state = state.copyWith(isLoading: true);

    _activeChatId = chatId;
    _myUserId = _currentUser!.id;

    final localCached = _chatLocalRepository.getMessagesForChat(chatId);
    state = state.copyWith(messages: localCached);

    final result = await _chatRemoteRepository.getInitialChatMessages(chatId);

    if (_activeChatId != chatId) {
      state = state.copyWith(isLoading: false);
      return;
    }

    await result.fold(
      (failure) async {
        print("Failed to fetch messages: ${failure.message}");
        state = state.copyWith(isLoading: false);
      },
      (serverMessages) async {
        final mergedMessages = await _mergeAndReconcileMessages(
          localCached,
          serverMessages,
        );

        await _chatLocalRepository.saveMessages(serverMessages);

        if (_activeChatId != chatId) {
          state = state.copyWith(isLoading: false);
          return;
        }

        state = state.copyWith(messages: mergedMessages, isLoading: false);
        _socketRepository.openChat(chatId);
      },
    );
  }

  //for matching messages not send while internet is off
  MessageModel? _findMatchingServerMessage(pending, serverMessages) {
    for (final srv in serverMessages) {
      if (srv.content == pending.content &&
          srv.chatId == pending.chatId &&
          srv.userId == pending.userId) {
        return srv;
      }
    }
    return null;
  }

  // reconcile the messages
  Future<List<MessageModel>> _mergeAndReconcileMessages(
    List<MessageModel> localMessages,
    List<MessageModel> serverMessages,
  ) async {
    for (final srv in serverMessages) {
      await _chatLocalRepository.deleteMessage(srv.id);
    }

    final Map<String, MessageModel> messageMap = {};

    for (final srv in serverMessages) {
      messageMap[srv.id] = srv;
      await _chatLocalRepository.saveMessage(srv);
    }

    for (final localMsg in localMessages) {
      if (localMsg.status != "PENDING") continue;

      final match = _findMatchingServerMessage(localMsg, serverMessages);
      if (match != null) {
        await _chatLocalRepository.deleteMessage(localMsg.id);

        messageMap[match.id] = match;
      } else {
        messageMap[localMsg.id] = localMsg;
        await _chatLocalRepository.saveMessage(localMsg);
      }
    }

    final merged = messageMap.values.toList();
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return merged;
  }

  // handle for receivers
  void handleIncomingMessage(Map<String, dynamic> data) async {
    if (_activeChatId == null) return;

    final msg = MessageModel.fromApiResponse(data);
    if (msg.userId == _myUserId) {
      return;
    }

    final exists = state.messages.any((m) => m.id == msg.id);
    if (exists) {
      _updateLocalMessageWithServerId(msg);
      return;
    }

    final isActiveChat =
        (msg.userId != _myUserId && msg.chatId == _activeChatId);

    if (isActiveChat) {
      msg.status = "READ";
    }

    await _chatLocalRepository.saveMessage(msg);

    final updated = [...state.messages, msg];
    state = state.copyWith(messages: updated);
    if (isActiveChat) {
      _socketRepository.openChat(_activeChatId!);
    }
  }

  void _updateLocalMessageWithServerId(MessageModel serverMsg) {
    final index = state.messages.lastIndexWhere(
      (m) => m.status == "PENDING" && m.chatId == serverMsg.chatId,
    );

    if (index == -1) return;

    final tempMsg = state.messages[index];

    final updatedMsg = tempMsg.copyWith(
      id: serverMsg.id,
      status: serverMsg.status,
    );

    final updated = [...state.messages];
    updated[index] = updatedMsg;

    _chatLocalRepository.saveMessage(updatedMsg);

    state = state.copyWith(messages: updated);
  }

  // send message
  Future<void> sendMessage(MessageModel localMessage) async {
    _chatLocalRepository.saveMessage(localMessage);

    final isAlreadyInState = state.messages.any((m) => m.id == localMessage.id);

    if (!isAlreadyInState) {
      final updated = [...state.messages, localMessage];
      state = state.copyWith(messages: updated);
    }

    _socketRepository.sendMessage(localMessage.toApiRequest());
  }

  // handle read status event
  void handleMessagesRead(Map<String, dynamic> data) {
    final chatId = data['chatId'];
    if (chatId == null || chatId != _activeChatId) return;
    _chatLocalRepository.markMessagesAsRead(chatId, _myUserId!);
    final updated = _chatLocalRepository.getMessagesForChat(chatId);
    state = state.copyWith(messages: updated);
  }

  // typing indicator
  void sendTyping(bool isTyping) {
    if (_activeChatId == null) return;
    _socketRepository.sendTyping(_activeChatId!, isTyping);
  }

  void handleTypingEvent(dynamic data) {
    if (_activeChatId == null) return;

    final typingChatId = data['chatId'] as String?;
    final typingUserId = data['userId'] as String?;

    if (typingChatId != _activeChatId || typingUserId == _myUserId) return;

    final isTyping = data['isTyping'] as bool? ?? false;
    state = state.copyWith(isRecipientTyping: isTyping);
  }

  void exitChat() {
    final previousChatId = _activeChatId;
    _activeChatId = null;

    if (previousChatId != null) {
      state = ChatState(
        isRecipientTyping: false,
        messages: [],
        isLoading: false,
      );
    }
  }
}
