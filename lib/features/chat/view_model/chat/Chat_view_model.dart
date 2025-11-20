// ignore_for_file: unused_field, unused_local_variable

import 'dart:io';

import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/chat/models/mediamodel.dart';
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

    _socketRepository.onMessageAdded((data) {
      handleMessageAdded(data);
    });

    _socketRepository.onMessagesRead((data) {
      handleMessagesRead(data);
    });

    _socketRepository.onTyping((data) {
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

  // handle for receivers
  void handleIncomingMessage(Map<String, dynamic> data) async {
    final msg = MessageModel.fromApiResponse(data);
    if (msg.userId == _myUserId) {
      return;
    }

    final exists = state.messages.any((m) {
      if (m.id == msg.id) return true;
      if (m.media != null &&
          msg.media != null &&
          m.media!.isNotEmpty &&
          msg.media!.isNotEmpty &&
          m.media!.first.id == msg.media!.first.id)
        return true;

      return false;
    });

    if (exists) {
      _updateLocalMessageWithServerId(msg);
      return;
    }

    if (msg.media != null && msg.media!.isNotEmpty) {
      for (var media in msg.media!) {
        if (media.localPath == null) {
          _download_media_for_receiver(msg, media);
        }
      }
    }

    final isActiveChat =
        (msg.userId != _myUserId && msg.chatId == _activeChatId);

    if (isActiveChat) {
      msg.status = "READ";
    }

    await _chatLocalRepository.saveMessage(msg);

    final updated = [...state.messages, msg];
    updated.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = state.copyWith(messages: updated);
    if (isActiveChat) {
      _socketRepository.openChat(_activeChatId!);
    }
  }

  void _updateLocalMessageWithServerId(MessageModel serverMsg) {
    final index = state.messages.indexWhere(
      (m) => m.status == "PENDING" && m.chatId == serverMsg.chatId,
    );

    if (index == -1) return;

    final tempMsg = state.messages[index];

    final updatedMsg = tempMsg.copyWith(
      id: serverMsg.id,
      status: serverMsg.status,
      media: serverMsg.media,
    );

    final updated = [...state.messages];
    updated[index] = updatedMsg;

    _chatLocalRepository.saveMessage(updatedMsg);

    state = state.copyWith(messages: updated);
  }

  // send message
  Future<void> sendMessage(MessageModel localMessage) async {
    assert(localMessage.media == null || localMessage.media!.isEmpty);
    _chatLocalRepository.saveMessage(localMessage);
    _chatLocalRepository.markMessageAsSent(localMessage.id);
    final updated = [...state.messages, localMessage];
    state = state.copyWith(messages: updated);
    _socketRepository.sendMessage(localMessage.toApiRequest());
  }

  //send image/video
  Future<void> send_File_Message(File file, String filetype) async {
    if (_activeChatId == null || _myUserId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final local_Media = MediaModel(
      id: tempId,
      keyName: "",
      type: filetype.contains("image") ? "IMAGE" : "VIDEO",
      size: await file.length(),
      name: file.path.split("/").last,
    );

    final localMessage = MessageModel(
      id: tempId,
      chatId: _activeChatId!,
      userId: _myUserId!,
      createdAt: DateTime.now(),
      status: 'PENDING',
      messageType: local_Media.type == 'IMAGE' ? 'image' : 'video',
      media: [local_Media],
    );

    _chatLocalRepository.saveMessage(localMessage);

    state = state.copyWith(messages: [...state.messages, localMessage]);

    final result = await _chatRemoteRepository.upload_Media_Message(
      file: file,
      fileType: filetype,
    );

    result.fold(
      (failure) {
        print("Upload failed: ${failure.message}");
      },
      (mediaData) async {
        final serverMedia = local_Media.copyWith(
          mediaMessageId: mediaData['mediaId'],
          keyName: mediaData['keyName'],
          localPath: file.path,
        );

        final socketMessage = localMessage.copyWith(
          media: [serverMedia],
          status: 'SENT',
        );

        _chatLocalRepository.saveMessage(socketMessage);

        state = state.copyWith(
          messages: [
            ...state.messages.where((m) => m.id != tempId),
            socketMessage,
          ],
        );
        _socketRepository.sendMessage({
          "chatId": _activeChatId,
          "data": {
            "content": "",
            "messageMedia": [
              {"mediaId": mediaData['mediaId']},
            ],
          },
        });
      },
    );
  }

  // download_media_for receiver
  Future<void> _download_media_for_receiver(
    MessageModel msg,
    MediaModel media,
  ) async {
    final result = await _chatRemoteRepository.downloadMedia(mediaId: media.id);
    result.fold((fail) => print("download Failed"), (file) async {
      final updatedMedia = media.copyWith(localPath: file.path);
      final updatedMediaList = msg.media!
          .map((m) => m.id == media.id ? updatedMedia : m)
          .toList();
      final updatedMsg = msg.copyWith(media: updatedMediaList);
      await _chatLocalRepository.saveMessage(updatedMsg);
      state = state.copyWith(
        messages: state.messages
            .map((m) => m.id == msg.id ? updatedMsg : m)
            .toList(),
      );
    });
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
