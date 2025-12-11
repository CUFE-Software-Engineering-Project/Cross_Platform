import 'dart:async';
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
  // late final ChatRemoteRepository _chatRemoteRepository;
  // late final ChatLocalRepository _chatLocalRepository;
  // late final SocketRepository _socketRepository;
  UserModel? _currentUser;
  bool _listening = false;
  StreamSubscription? _messageSub;
  ChatRemoteRepository get _chatRemoteRepository =>
      ref.watch(chatRemoteRepositoryProvider);

  ChatLocalRepository get _chatLocalRepository =>
      ref.watch(chatLocalRepositoryProvider);

  SocketRepository get _socketRepository => ref.watch(socketRepositoryProvider);

  @override
  AsyncValue<List<ConversationModel>> build() {
    // _chatRemoteRepository = ref.watch(chatRemoteRepositoryProvider);
    // _chatLocalRepository = ref.watch(chatLocalRepositoryProvider);
    // _socketRepository = ref.watch(socketRepositoryProvider);
    _currentUser = ref.watch(currentUserProvider);
    if (!_listening) {
      _listenToNewMessages();
      _listening = true;

      ref.onDispose(() {
        _messageSub?.cancel();
        _listening = false;
      });
    }
    return const AsyncValue.data([]);
  }

  void _listenToNewMessages() {
    _messageSub = _socketRepository.newMessageStream.listen((data) {
      try {
        print("New message received: $data");

        final serverUnseenCount = data["unseenMessagesCount"] as int? ?? 0;
        print("new count $serverUnseenCount");

        final newMsg = MessageModel.fromApiResponse(data);

        final activeChatId = ref.read(activeChatProvider);
        final bool isChatOpen = (activeChatId == newMsg.chatId);
        final bool isMe = newMsg.userId == _currentUser?.id;

        final currentConversations = state.maybeWhen(
          data: (list) => List<ConversationModel>.from(list),
          orElse: () => _chatLocalRepository.getAllConversations(),
        );

        final idx = currentConversations.indexWhere(
          (chat) => chat.id == newMsg.chatId,
        );

        if (idx != -1) {
          final chat = currentConversations[idx];
          int finalUnseenCount;
          if (isMe) {
            finalUnseenCount = chat.unseenCount;
          } else if (isChatOpen) {
            finalUnseenCount = 0;
            _socketRepository.openChat(newMsg.chatId);
          } else {
            if (serverUnseenCount > 0) {
              finalUnseenCount = serverUnseenCount;
            } else {
              finalUnseenCount = chat.unseenCount + 1;
            }
          }

          final updatedChat = chat.copyWith(
            lastMessageContent: newMsg.content,
            lastMessageType: newMsg.messageType,
            lastMessageTime: newMsg.createdAt,
            unseenCount: finalUnseenCount,
            lastMessageSenderId: newMsg.userId,
          );

          currentConversations[idx] = updatedChat;
        } else {
          int initialCount = (isMe || isChatOpen)
              ? 0
              : (serverUnseenCount > 0 ? serverUnseenCount : 1);
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
            unseenCount: initialCount,
            lastMessageSenderId: newMsg.userId,
          );

          currentConversations.add(created);
          _chatRemoteRepository
              .getChatInfo(newMsg.chatId, _currentUser!.id)
              .then((result) {
                result.fold((l) => null, (serverChat) async {
                  final mergedChat = serverChat.copyWith(
                    unseenCount: initialCount,
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

                  state = AsyncValue.data([...refreshed]);
                });
              });
        }
        _sortConversations(currentConversations);

        state = AsyncValue.data([...currentConversations]);

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
    required DateTime timestamp,
  }) {
    if (_currentUser == null) return;
    final currentList = state.value ?? [];
    final index = currentList.indexWhere((c) => c.id == chatId);

    if (index != -1) {
      final chat = currentList[index];

      final updatedChat = chat.copyWith(
        lastMessageContent: content,
        lastMessageType: messageType,
        lastMessageTime: timestamp,
        lastMessageSenderId: _currentUser!.id,
      );

      final updatedList = List<ConversationModel>.from(currentList);
      updatedList[index] = updatedChat;
      _sortConversations(updatedList);
      state = AsyncValue.data([...updatedList]);
      _chatLocalRepository.upsertConversations([updatedChat]);
    }
  }

  void _sortConversations(List<ConversationModel> list) {
    list.sort((a, b) {
      final aTime = a.lastMessageTime ?? a.updatedAt;
      final bTime = b.lastMessageTime ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });
  }

  void markChatAsRead(String chatId) {
    state.whenData((currentList) {
      final updatedList = currentList.map((chat) {
        if (chat.id == chatId) {
          return chat.copyWith(unseenCount: 0);
        }
        return chat;
      }).toList();
      state = AsyncValue.data([...updatedList]);

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

        state = AsyncValue.data([...updatedList]);

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
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.data([...cachedConversations]);
      }

      final result = await _chatRemoteRepository.getuserchats(_currentUser!.id);

      result.fold(
        (failure) {
          print("Error loading conversations: ${failure.message}");
        },
        (serverConversations) async {
          final serverIds = serverConversations.map((c) => c.id).toSet();
          final localConversations = _chatLocalRepository.getAllConversations();

          for (var localConv in localConversations) {
            if (!serverIds.contains(localConv.id)) {
              await _chatLocalRepository.deleteConversation(localConv.id);
            }
          }
          await _chatLocalRepository.upsertConversations(serverConversations);
          _sortConversations(serverConversations);
          state = AsyncValue.data([...serverConversations]);
        },
      );
    } catch (e, st) {
      print("Conversation Load Failed: $e");
      final cached = _chatLocalRepository.getAllConversations();
      if (cached.isNotEmpty) {
        print("Loading cached conversations because server failed");
        state = AsyncValue.data([...cached]);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<Either<AppFailure, String>> deleteChat(String chatId) async {
    if (_currentUser == null) {
      return Left(AppFailure(message: "No current user found"));
    }

    final result = await _chatRemoteRepository.deleteChat(chatId);
    print("Delete chat result: $result");
    return result.fold(
      (failure) {
        return Left(failure);
      },
      (successMessage) async {
        await _chatLocalRepository.deleteConversation(chatId);
        final currentList = state.value ?? [];
        final updatedList = List<ConversationModel>.from(currentList)
          ..removeWhere((chat) => chat.id == chatId);
        state = AsyncValue.data([...updatedList]);
        return Right(successMessage);
      },
    );
  }
}
