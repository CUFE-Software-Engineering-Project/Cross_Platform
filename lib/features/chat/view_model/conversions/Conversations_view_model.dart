import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
import 'package:lite_x/features/chat/providers/activeChatIdProvider.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'Conversations_view_model.g.dart';

@Riverpod(keepAlive: true)
class ConversationsViewModel extends _$ConversationsViewModel {
  late final ChatRemoteRepository _chatRemoteRepository;
  late final ChatLocalRepository _chatLocalRepository;
  late final SocketRepository _socketRepository;
  UserModel? _currentUser;
  bool _listening = false;

  @override
  AsyncValue<List<ConversationModel>> build() {
    _chatRemoteRepository = ref.watch(chatRemoteRepositoryProvider);
    _chatLocalRepository = ref.watch(chatLocalRepositoryProvider);
    _socketRepository = ref.watch(socketRepositoryProvider);
    _currentUser = ref.watch(currentUserProvider);
    if (!_listening) {
      _listenToNewMessages();
      _listening = true;

      ref.onDispose(() {
        _socketRepository.disposeListeners();
        _listening = false;
      });
    }
    return const AsyncValue.data([]);
  }

  void _listenToNewMessages() {
    _socketRepository.onNewMessage((data) {
      try {
        print("New message received: $data");
        final newMsg = MessageModel.fromApiResponse(data);

        final currentConversations = state.maybeWhen(
          data: (list) => List<ConversationModel>.from(list),
          orElse: () => _chatLocalRepository.getAllConversations(),
        );

        final idx = currentConversations.indexWhere(
          (chat) => chat.id == newMsg.chatId,
        );
        final openChatId = ref.read(activeChatProvider);
        final bool isChatOpen = openChatId == newMsg.chatId;
        if (idx != -1) {
          final chat = currentConversations[idx];
          final bool isMe = newMsg.userId == _currentUser?.id;
          final int newCount;
          if (isMe) {
            newCount = chat.unseenCount;
          } else if (isChatOpen) {
            newCount = 0;
          } else {
            newCount = chat.unseenCount + 1;
          }
          final updatedChat = chat.copyWith(
            lastMessageContent: newMsg.content,
            lastMessageType: newMsg.messageType,
            lastMessageTime: newMsg.createdAt,
            unseenCount: newCount,
            lastMessageSenderId: newMsg.userId,
          );

          currentConversations[idx] = updatedChat;
        } else {
          final bool isMe = newMsg.userId == _currentUser?.id;
          final int initialUnseenCount = (isMe || isChatOpen) ? 0 : 1;
          final created = ConversationModel(
            id: newMsg.chatId,
            isDMChat: true,
            createdAt: newMsg.createdAt,
            updatedAt: newMsg.createdAt,
            participantIds: [
              newMsg.userId,
              if (_currentUser != null) _currentUser!.id,
            ],
            dmPartnerUserId: newMsg.userId,
            dmPartnerName: newMsg.senderName ?? "Unknown",
            dmPartnerUsername: newMsg.senderUsername,
            dmPartnerProfileKey: newMsg.senderProfileMediaKey,
            lastMessageContent: newMsg.content,
            lastMessageType: newMsg.messageType,
            lastMessageTime: newMsg.createdAt,
            unseenCount: initialUnseenCount,
            lastMessageSenderId: newMsg.userId,
          );

          currentConversations.add(created);
          _chatRemoteRepository
              .getChatInfo(newMsg.chatId, _currentUser!.id)
              .then((result) {
                result.fold((l) => null, (serverChat) async {
                  final bool isMe = newMsg.userId == _currentUser!.id;
                  final int newCount = isMe ? 0 : 1;

                  final mergedChat = serverChat.copyWith(
                    unseenCount: newCount,
                    lastMessageContent: newMsg.content,
                    lastMessageType: newMsg.messageType,
                    lastMessageTime: newMsg.createdAt,
                    lastMessageSenderId: newMsg.userId,
                  );

                  await _chatLocalRepository.upsertConversations([mergedChat]);

                  final currentList = state.value ?? [];

                  final refreshed = List<ConversationModel>.from(currentList)
                    ..removeWhere((c) => c.id == mergedChat.id)
                    ..add(mergedChat);

                  refreshed.sort((a, b) {
                    final aTime = a.lastMessageTime ?? a.updatedAt;
                    final bTime = b.lastMessageTime ?? b.updatedAt;
                    return bTime.compareTo(aTime);
                  });

                  state = AsyncValue.data(refreshed);
                });
              });
        }

        currentConversations.sort((a, b) {
          final aTime = a.lastMessageTime ?? a.updatedAt;
          final bTime = b.lastMessageTime ?? b.updatedAt;
          return bTime.compareTo(aTime);
        });

        state = AsyncValue.data(currentConversations);
        _chatLocalRepository.upsertConversations(currentConversations);
      } catch (e) {
        print("Error handling new-message socket: $e");
      }
    });
  }

  void updateConversationAfterSending({
    required String chatId,
    required String content,
    required String messageType,
  }) {
    if (_currentUser == null) return;

    final currentList = state.value ?? [];
    final index = currentList.indexWhere((c) => c.id == chatId);

    if (index != -1) {
      final chat = currentList[index];

      final updatedChat = chat.copyWith(
        lastMessageContent: content,
        lastMessageType: messageType,
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: _currentUser!.id,
      );

      final updatedList = List<ConversationModel>.from(currentList);
      updatedList[index] = updatedChat;

      updatedList.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.updatedAt;
        final bTime = b.lastMessageTime ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });

      state = AsyncValue.data(updatedList);
      _chatLocalRepository.upsertConversations([updatedChat]);
    }
  }

  void markChatAsRead(String chatId) {
    state.whenData((currentList) {
      final updatedList = currentList.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(unseenCount: 0);
        }
        return chat;
      }).toList();

      state = AsyncValue.data(updatedList);
      final chat = updatedList.firstWhere((c) => c.id == chatId);
      _chatLocalRepository.upsertConversations([chat]);
    });
  }

  Future<Either<AppFailure, ConversationModel>> createChat({
    required List<String> recipientIds,
    required bool isDMChat,
  }) async {
    if (_currentUser == null) {
      return Left(AppFailure(message: "No current user found"));
    }
    try {
      final result = await _chatRemoteRepository.create_chat(
        recipientIds: recipientIds,
        Current_UserId: _currentUser!.id,
        DMChat: isDMChat,
      );
      return result.fold((failure) => Left(failure), (serverChat) async {
        final localChat = _chatLocalRepository.getConversationById(
          serverChat.id,
        );

        if (localChat != null) {
          return Right(localChat);
        }
        await _chatLocalRepository.upsertConversations([serverChat]);

        final currentList = state.value ?? [];

        final updatedList = List<ConversationModel>.from(currentList)
          ..removeWhere((c) => c.id == serverChat.id)
          ..add(serverChat);

        updatedList.sort((a, b) {
          final aTime = a.lastMessageTime ?? a.updatedAt;
          final bTime = b.lastMessageTime ?? b.updatedAt;
          return bTime.compareTo(aTime);
        });

        state = AsyncValue.data(updatedList);

        return Right(serverChat);
      });
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  Future<List<UserSearchModel>> searchUsers(String query) async {
    final result = await _chatRemoteRepository.searchUsers(query);

    return result.fold((failure) {
      print("Search Error: ${failure.message}");
      return [];
    }, (users) => users);
  }

  Future<void> loadConversations() async {
    if (_currentUser == null) {
      print("Error: No current user found");
      return;
    }
    try {
      state = const AsyncValue.loading();

      final cachedConversations = ref
          .read(chatLocalRepositoryProvider)
          .getAllConversations();

      state = AsyncValue.data(cachedConversations);

      final result = await _chatRemoteRepository.getuserchats(_currentUser!.id);

      final conversations = result.fold((failure) {
        print("Error loading conversations: ${failure.message}");
        return cachedConversations;
      }, (convs) => convs);
      conversations.sort(
        (a, b) => (b.lastMessageTime ?? b.updatedAt).compareTo(
          a.lastMessageTime ?? a.updatedAt,
        ),
      );
      await ref
          .read(chatLocalRepositoryProvider)
          .upsertConversations(conversations);

      state = AsyncValue.data(conversations);
    } catch (e, st) {
      print("Conversation Load Failed: $e");
      state = AsyncValue.error(e, st);
    }
  }
}
