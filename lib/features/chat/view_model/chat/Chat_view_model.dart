// ignore_for_file: unused_field

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
    return ChatState(isLoading: true);
  }

  void _setupSocketListeners() {
    _socketRepository.onNewMessage((data) {
      if (data['chatId'] == _activeChatId) {
        handleIncomingMessage(data);
      }
    });
    _socketRepository.onMessagesRead((data) {
      handleMessagesRead(data);
    });

    _socketRepository.onTyping((data) {
      handleTypingEvent(data);
    });
  }

  // load messages (offline first)
  Future<void> loadChat(String chatId) async {
    if (_currentUser == null) {
      print("Error: No current user found");
      return;
    }
    _activeChatId = chatId;

    _myUserId = _currentUser!.id;

    final cachedMessages = _chatLocalRepository.getMessagesForChat(chatId);

    state = state.copyWith(messages: cachedMessages, isLoading: true);

    final result = await _chatRemoteRepository.getInitialChatMessages(chatId);

    final messages = result.fold((failure) {
      print("Error loading messages: ${failure.message}");
      return cachedMessages;
    }, (msgs) => msgs);

    await _chatLocalRepository.saveMessages(messages);

    state = state.copyWith(messages: messages, isLoading: false);

    _socketRepository.openChat(chatId); // mark all as read
  }

  // handle new real-time message
  void handleIncomingMessage(Map<String, dynamic> data) {
    final msg = MessageModel.fromApiResponse(data);
    final exists = state.messages.any((m) {
      if (m.id == msg.id) return true;
      if (m.localId != null &&
          msg.localId != null &&
          m.localId == msg.localId) {
        return true;
      }
      return false;
    });
    if (exists) {
      _updateLocalMessageWithServerId(msg);
      return;
    }
    _chatLocalRepository.saveMessage(msg);

    final updated = [...state.messages, msg];
    updated.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = state.copyWith(messages: updated);
    if (msg.userId != _myUserId && msg.chatId == _activeChatId) {
      _socketRepository.openChat(_activeChatId!);
    }
  }

  void _updateLocalMessageWithServerId(MessageModel serverMsg) {
    final index = state.messages.indexWhere((m) {
      return m.localId != null &&
          serverMsg.localId != null &&
          m.localId == serverMsg.localId;
    });

    if (index != -1) {
      final updatedMessages = [...state.messages];
      updatedMessages[index] = serverMsg;
      _chatLocalRepository.saveMessage(serverMsg);
      state = state.copyWith(messages: updatedMessages);
    }
  }

  // send message
  Future<void> sendMessage(MessageModel localMessage) async {
    _chatLocalRepository.saveMessage(localMessage);
    _chatLocalRepository.markMessageAsSent(localMessage.id);
    final updated = [...state.messages, localMessage];
    state = state.copyWith(messages: updated);
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
    final typingChatId = data['chatId'] as String?;
    final typingUserId = data['userId'] as String?;

    if (typingChatId != _activeChatId || typingUserId == _myUserId) return;

    final isTyping = data['isTyping'] as bool? ?? false;
    state = state.copyWith(isRecipientTyping: isTyping);
  }

  void exitChat() {
    _activeChatId = null;
    state = state.copyWith(
      isRecipientTyping: false,
      messages: [],
      isLoading: false,
    );
  }
}
