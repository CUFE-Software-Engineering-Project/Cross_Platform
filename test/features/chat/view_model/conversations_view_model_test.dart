import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
import 'package:lite_x/features/chat/providers/activeChatIdProvider.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';

import 'conversations_view_model_test.mocks.dart';

class MockCurrentUserNotifier extends CurrentUser {
  final UserModel? _initialUser;
  MockCurrentUserNotifier(this._initialUser);

  @override
  UserModel? build() {
    return _initialUser;
  }
}

@GenerateMocks([ChatRemoteRepository, ChatLocalRepository, SocketRepository])
void main() {
  late ProviderContainer container;
  late MockChatRemoteRepository mockRemote;
  late MockChatLocalRepository mockLocal;
  late MockSocketRepository mockSocket;
  late StreamController<Map<String, dynamic>> socketStream;

  final currentUser = UserModel(
    id: 'user_1',
    email: 'test@test.com',
    name: 'Current User',
    username: 'curr',
    dob: '2000-01-01',
    isEmailVerified: true,
    isVerified: true,
  );

  final testDate = DateTime(2024, 1, 1);

  final conv1 = ConversationModel(
    id: 'chat_1',
    isDMChat: true,
    createdAt: testDate,
    updatedAt: testDate,
    participantIds: ['user_1', 'user_2'],
    unseenCount: 0,
    dmPartnerUserId: 'user_2',
    dmPartnerName: 'User Two',
    lastMessageContent: 'Old msg',
  );

  final conv2 = ConversationModel(
    id: 'chat_2',
    isDMChat: true,
    createdAt: testDate,
    updatedAt: testDate,
    participantIds: ['user_1', 'user_3'],
    unseenCount: 2,
    dmPartnerUserId: 'user_3',
    dmPartnerName: 'User Three',
  );
  provideDummy<Either<AppFailure, List<ConversationModel>>>(const Right([]));
  provideDummy<Either<AppFailure, ConversationModel>>(Right(conv1));
  provideDummy<Either<AppFailure, String>>(const Right(''));
  provideDummy<Either<AppFailure, List<UserSearchModel>>>(const Right([]));

  setUp(() {
    mockRemote = MockChatRemoteRepository();
    mockLocal = MockChatLocalRepository();
    mockSocket = MockSocketRepository();
    socketStream = StreamController<Map<String, dynamic>>.broadcast();
    when(mockSocket.newMessageStream).thenAnswer((_) => socketStream.stream);

    container = ProviderContainer(
      overrides: [
        chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
        chatLocalRepositoryProvider.overrideWithValue(mockLocal),
        socketRepositoryProvider.overrideWithValue(mockSocket),
        currentUserProvider.overrideWith(
          () => MockCurrentUserNotifier(currentUser),
        ),
        activeChatProvider.overrideWith(() => ActiveChat()),
      ],
    );
  });

  tearDown(() {
    socketStream.close();
    container.dispose();
  });

  group('ConversationsViewModel', () {
    test('initial build returns empty list', () {
      final state = container.read(conversationsViewModelProvider);
      expect(state, const AsyncValue<List<ConversationModel>>.data([]));
    });
    test('loadConversations loads local then remote and syncs', () async {
      final cachedList = [conv1, conv2];
      final remoteList = [conv1];

      when(mockLocal.getAllConversations()).thenReturn(cachedList);
      when(
        mockRemote.getuserchats(currentUser.id),
      ).thenAnswer((_) async => Right(remoteList));
      when(mockLocal.deleteConversation('chat_2')).thenAnswer((_) async {});
      when(mockLocal.upsertConversations(remoteList)).thenAnswer((_) async {});

      await container
          .read(conversationsViewModelProvider.notifier)
          .loadConversations();

      verify(mockLocal.deleteConversation('chat_2')).called(1);
      verify(mockLocal.upsertConversations(remoteList)).called(1);

      final state = container.read(conversationsViewModelProvider);
      expect(state.value, [conv1]);
    });
    test('loadConversations returns early if current user is null', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
          chatLocalRepositoryProvider.overrideWithValue(mockLocal),
          socketRepositoryProvider.overrideWithValue(mockSocket),
          currentUserProvider.overrideWith(() => MockCurrentUserNotifier(null)),
          activeChatProvider.overrideWith(() => ActiveChat()),
        ],
      );
      await container
          .read(conversationsViewModelProvider.notifier)
          .loadConversations();
      verifyNever(mockRemote.getuserchats(any));
    });
    test('loadConversations falls back to cache on remote failure', () async {
      when(mockLocal.getAllConversations()).thenReturn([conv1]);

      when(
        mockRemote.getuserchats(any),
      ).thenAnswer((_) async => Left(AppFailure(message: 'Error')));

      await container
          .read(conversationsViewModelProvider.notifier)
          .loadConversations();

      final state = container.read(conversationsViewModelProvider);
      expect(state.value, [conv1]);
    });

    test(
      'loadConversations returns error if remote fails and cache empty',
      () async {
        when(mockLocal.getAllConversations()).thenReturn([]);

        when(
          mockRemote.getuserchats(any),
        ).thenThrow(Exception("Network Error"));

        await container
            .read(conversationsViewModelProvider.notifier)
            .loadConversations();

        final state = container.read(conversationsViewModelProvider);
        expect(state.hasError, true);
      },
    );

    test('createChat returns local chat if exists', () async {
      when(
        mockRemote.create_chat(
          recipientIds: ['user_2'],
          Current_UserId: currentUser.id,
          DMChat: true,
        ),
      ).thenAnswer((_) async => Right(conv1));

      when(mockLocal.getConversationById('chat_1')).thenReturn(conv1);

      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .createChat(recipientIds: ['user_2'], isDMChat: true);

      expect(result.isRight(), true);
      verifyNever(mockLocal.upsertConversations(any));
    });
    test('createChat returns failure if current user is null', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
          chatLocalRepositoryProvider.overrideWithValue(mockLocal),
          socketRepositoryProvider.overrideWithValue(mockSocket),
          currentUserProvider.overrideWith(() => MockCurrentUserNotifier(null)),
          activeChatProvider.overrideWith(() => ActiveChat()),
        ],
      );
      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .createChat(recipientIds: ['u2'], isDMChat: true);

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, contains("No current user found")),
        (r) => fail('Should be left'),
      );
    });
    test('createChat catches exceptions and returns Left', () async {
      when(
        mockRemote.create_chat(
          recipientIds: anyNamed('recipientIds'),
          Current_UserId: anyNamed('Current_UserId'),
          DMChat: anyNamed('DMChat'),
        ),
      ).thenThrow(Exception("Unexpected Network Crash"));
      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .createChat(recipientIds: ['u2'], isDMChat: true);
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, contains("Unexpected Network Crash")),
        (r) => fail('Should be left'),
      );
    });
    test('createChat saves to local if not exists', () async {
      when(
        mockRemote.create_chat(
          recipientIds: ['user_2'],
          Current_UserId: currentUser.id,
          DMChat: true,
        ),
      ).thenAnswer((_) async => Right(conv1));

      when(mockLocal.getConversationById('chat_1')).thenReturn(null);
      when(mockLocal.upsertConversations([conv1])).thenAnswer((_) async {});

      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .createChat(recipientIds: ['user_2'], isDMChat: true);

      expect(result.isRight(), true);
      verify(mockLocal.upsertConversations([conv1])).called(1);

      final state = container.read(conversationsViewModelProvider);
      expect(state.value, contains(conv1));
    });
    test(
      'createChat adds new chat and sorts list by latest activity',
      () async {
        final oldChat = conv1.copyWith(
          id: 'old_chat',
          updatedAt: DateTime(2020),
          lastMessageTime: DateTime(2020),
        );

        when(mockLocal.getAllConversations()).thenReturn([oldChat]);
        when(
          mockRemote.getuserchats(any),
        ).thenAnswer((_) async => Right([oldChat]));
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});
        await container
            .read(conversationsViewModelProvider.notifier)
            .loadConversations();

        final newChat = conv2.copyWith(
          id: 'new_chat',
          updatedAt: DateTime(2025),
          lastMessageTime: DateTime(2025),
        );

        when(
          mockRemote.create_chat(
            recipientIds: anyNamed('recipientIds'),
            Current_UserId: anyNamed('Current_UserId'),
            DMChat: anyNamed('DMChat'),
          ),
        ).thenAnswer((_) async => Right(newChat));
        when(mockLocal.getConversationById('new_chat')).thenReturn(null);
        await container
            .read(conversationsViewModelProvider.notifier)
            .createChat(recipientIds: ['u3'], isDMChat: true);

        final state = container.read(conversationsViewModelProvider).value!;
        expect(state.length, 2);
        expect(state[0].id, 'new_chat');
        expect(state[1].id, 'old_chat');
      },
    );
    test('createChat handles errors', () async {
      when(
        mockRemote.create_chat(
          recipientIds: ['user_2'],
          Current_UserId: currentUser.id,
          DMChat: true,
        ),
      ).thenAnswer((_) async => Left(AppFailure(message: 'Fail')));

      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .createChat(recipientIds: ['user_2'], isDMChat: true);

      expect(result.isLeft(), true);
    });
    test(
      'socket listener uses local repository fallback when state is not AsyncData',
      () async {
        when(mockLocal.getAllConversations()).thenReturn([conv1]);
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});
        when(mockLocal.getAllConversations()).thenReturn([conv1]);
        when(mockRemote.getuserchats(any)).thenThrow(Exception("Fail"));

        try {
          await container
              .read(conversationsViewModelProvider.notifier)
              .loadConversations();
        } catch (_) {}
        when(mockLocal.getAllConversations()).thenReturn([conv1]);
        when(
          mockRemote.getuserchats(any),
        ).thenAnswer((_) async => Left(AppFailure(message: 'Fail')));
        when(mockLocal.getAllConversations()).thenReturn([]);
        when(mockRemote.getuserchats(any)).thenThrow(Exception('Crash'));

        try {
          await container
              .read(conversationsViewModelProvider.notifier)
              .loadConversations();
        } catch (_) {}
        when(mockLocal.getAllConversations()).thenReturn([conv1]);
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});
        final messageData = {
          'createdMessage': {
            'id': 'msg_new',
            'chatId': 'chat_1',
            'userId': 'user_2',
            'content': 'Update',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'SENT',
            'user': {'username': 'u2', 'name': 'U2'},
          },
          'unseenMessagesCount': 5,
        };

        socketStream.add(messageData);
        await Future.delayed(Duration.zero);
        verifyNever(mockRemote.getChatInfo(any, any));
        final captured = verify(
          mockLocal.upsertConversations(captureAny),
        ).captured;
        final savedList = captured.first as List<ConversationModel>;
        expect(savedList.first.id, 'chat_1');
        expect(savedList.first.unseenCount, 5);
      },
    );
    test(
      'socket listener does not increment unseen count if message is from me',
      () async {
        when(mockLocal.getAllConversations()).thenReturn([conv1]);
        when(
          mockRemote.getuserchats(any),
        ).thenAnswer((_) async => Right([conv1]));
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

        await container
            .read(conversationsViewModelProvider.notifier)
            .loadConversations();
        final messageData = {
          'createdMessage': {
            'id': 'msg_me',
            'chatId': 'chat_1',
            'userId': 'user_1',
            'content': 'My msg',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'SENT',
            'user': {'username': 'curr', 'name': 'Current User'},
          },
          'unseenMessagesCount': 99,
        };

        socketStream.add(messageData);
        await Future.delayed(Duration.zero);

        final state = container.read(conversationsViewModelProvider);
        final chat = state.value!.first;
        expect(chat.lastMessageContent, 'My msg');
        expect(chat.unseenCount, 0);
      },
    );
    test(
      'socket listener increments unseen count manually if server count is missing/zero',
      () async {
        final existingChat = conv1.copyWith(unseenCount: 2);
        when(mockLocal.getAllConversations()).thenReturn([existingChat]);
        when(
          mockRemote.getuserchats(any),
        ).thenAnswer((_) async => Right([existingChat]));
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

        await container
            .read(conversationsViewModelProvider.notifier)
            .loadConversations();
        final messageData = {
          'createdMessage': {
            'id': 'msg_other',
            'chatId': 'chat_1',
            'userId': 'user_2',
            'content': 'Msg',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'SENT',
            'user': {'username': 'u2', 'name': 'U2'},
          },
          'unseenMessagesCount': 0,
        };

        socketStream.add(messageData);
        await Future.delayed(Duration.zero);

        final state = container.read(conversationsViewModelProvider);
        expect(state.value!.first.unseenCount, 3);
      },
    );
    test('socket listener updates existing conversation', () async {
      when(mockLocal.getAllConversations()).thenReturn([conv1]);
      when(
        mockRemote.getuserchats(any),
      ).thenAnswer((_) async => Right([conv1]));
      when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

      await container
          .read(conversationsViewModelProvider.notifier)
          .loadConversations();

      final messageData = {
        'createdMessage': {
          'id': 'msg_new',
          'chatId': 'chat_1',
          'userId': 'user_2',
          'content': 'New socket message',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'SENT',
          'user': {'username': 'u2', 'name': 'U2'},
        },
        'unseenMessagesCount': 5,
      };

      socketStream.add(messageData);

      await Future.delayed(Duration.zero);

      final state = container.read(conversationsViewModelProvider);
      final updated = state.value!.first;
      expect(updated.lastMessageContent, 'New socket message');
      expect(updated.unseenCount, 5);
    });

    test('socket listener creates new conversation if missing', () async {
      final convNew = ConversationModel(
        id: 'chat_new',
        isDMChat: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        participantIds: ['user_1', 'user_3'],
        unseenCount: 1,
        dmPartnerUserId: 'user_3',
        dmPartnerName: 'User Three',
      );
      when(mockLocal.getAllConversations()).thenReturn([]);
      when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});
      when(
        mockRemote.getChatInfo('chat_new', currentUser.id),
      ).thenAnswer((_) async => Right(convNew));

      final messageData = {
        'createdMessage': {
          'id': 'msg_new',
          'chatId': 'chat_new',
          'userId': 'user_3',
          'content': 'Brand new',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'SENT',
          'user': {'username': 'u3', 'name': 'U3'},
        },
        'unseenMessagesCount': 1,
      };
      container.read(conversationsViewModelProvider);
      socketStream.add(messageData);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      verify(mockRemote.getChatInfo('chat_new', currentUser.id)).called(1);
      final state = container.read(conversationsViewModelProvider);

      expect(state.value!.length, 1);
      expect(state.value!.first.id, 'chat_new');
    });

    test('socket listener handles active chat correctly', () async {
      container.dispose();

      container = ProviderContainer(
        overrides: [
          chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
          chatLocalRepositoryProvider.overrideWithValue(mockLocal),
          socketRepositoryProvider.overrideWithValue(mockSocket),

          currentUserProvider.overrideWith(
            () => MockCurrentUserNotifier(currentUser),
          ),
          activeChatProvider.overrideWith(() => ActiveChat()),
        ],
      );

      container.read(activeChatProvider.notifier).setActive('chat_1');
      when(mockSocket.newMessageStream).thenAnswer((_) => socketStream.stream);
      when(mockLocal.getAllConversations()).thenReturn([conv1]);
      when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

      final notifier = container.read(conversationsViewModelProvider.notifier);
      await notifier.loadConversations();

      final messageData = {
        'createdMessage': {
          'id': 'msg_new',
          'chatId': 'chat_1',
          'userId': 'user_2',
          'content': 'Open chat msg',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'SENT',
          'user': {'username': 'u2', 'name': 'U2'},
        },
        'unseenMessagesCount': 10,
      };

      socketStream.add(messageData);
      await Future.delayed(Duration.zero);

      final state = container.read(conversationsViewModelProvider);

      expect(state.value!.first.unseenCount, 0);
      verify(mockSocket.openChat('chat_1')).called(1);
    });

    test('updateConversationAfterSending updates state', () async {
      when(mockLocal.getAllConversations()).thenReturn([conv1]);
      when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

      final notifier = container.read(conversationsViewModelProvider.notifier);
      await notifier.loadConversations();

      notifier.updateConversationAfterSending(
        chatId: 'chat_1',
        content: 'Sent content',
        messageType: 'text',
        timestamp: DateTime.now(),
      );

      final state = container.read(conversationsViewModelProvider);
      expect(state.value!.first.lastMessageContent, 'Sent content');
      expect(state.value!.first.lastMessageSenderId, currentUser.id);
    });

    test('markChatAsRead zeros unseen count', () async {
      final unread = conv1.copyWith(unseenCount: 5);
      when(mockLocal.getAllConversations()).thenReturn([unread]);
      when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

      final notifier = container.read(conversationsViewModelProvider.notifier);
      await notifier.loadConversations();

      notifier.markChatAsRead('chat_1');

      final state = container.read(conversationsViewModelProvider);
      expect(state.value!.first.unseenCount, 0);
    });

    test('deleteChat removes from state and calls repos', () async {
      when(mockLocal.getAllConversations()).thenReturn([conv1]);
      when(
        mockRemote.deleteChat('chat_1'),
      ).thenAnswer((_) async => Right("Deleted"));
      when(mockLocal.deleteConversation('chat_1')).thenAnswer((_) async {});

      final notifier = container.read(conversationsViewModelProvider.notifier);
      await notifier.loadConversations();

      final result = await notifier.deleteChat('chat_1');

      expect(result.isRight(), true);
      expect(container.read(conversationsViewModelProvider).value, isEmpty);
      verify(mockLocal.deleteConversation('chat_1')).called(1);
    });
    test('deleteChat returns failure when remote repository fails', () async {
      when(
        mockRemote.deleteChat('chat_1'),
      ).thenAnswer((_) async => Left(AppFailure(message: 'Delete failed')));

      final notifier = container.read(conversationsViewModelProvider.notifier);
      final result = await notifier.deleteChat('chat_1');
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'Delete failed'),
        (r) => fail('Should be left'),
      );
      verifyNever(mockLocal.deleteConversation(any));
    });
    test('deleteChat returns failure if current user is null', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
          chatLocalRepositoryProvider.overrideWithValue(mockLocal),
          socketRepositoryProvider.overrideWithValue(mockSocket),
          currentUserProvider.overrideWith(() => MockCurrentUserNotifier(null)),
          activeChatProvider.overrideWith(() => ActiveChat()),
        ],
      );
      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .deleteChat('chat_1');
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, contains("No current user found")),
        (r) => fail('Should be left'),
      );
    });
    test(
      'conversations are sorted by lastMessageTime descending on load',
      () async {
        final chatNew = conv1.copyWith(
          id: 'new',
          lastMessageTime: DateTime(2025),
        );
        final chatOld = conv2.copyWith(
          id: 'old',
          lastMessageTime: DateTime(2020),
        );
        final chatMid = conv1.copyWith(
          id: 'mid',
          lastMessageTime: DateTime(2023),
        );
        final unsortedList = [chatOld, chatNew, chatMid];

        when(mockLocal.getAllConversations()).thenReturn([]);
        when(
          mockRemote.getuserchats(any),
        ).thenAnswer((_) async => Right(unsortedList));
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});
        await container
            .read(conversationsViewModelProvider.notifier)
            .loadConversations();
        final state = container.read(conversationsViewModelProvider).value!;
        expect(state[0].id, 'new');
        expect(state[1].id, 'mid');
        expect(state[2].id, 'old');
      },
    );
    test(
      'socket listener catches errors and preserves state on invalid data',
      () async {
        when(mockLocal.getAllConversations()).thenReturn([conv1]);
        when(
          mockRemote.getuserchats(any),
        ).thenAnswer((_) async => Right([conv1]));
        when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});

        await container
            .read(conversationsViewModelProvider.notifier)
            .loadConversations();
        socketStream.add({'invalid_key': 'no_data'});

        await Future.delayed(Duration.zero);
        final state = container.read(conversationsViewModelProvider);
        expect(state.value!.length, 1);
        expect(state.value!.first.id, 'chat_1');
        verify(mockLocal.upsertConversations(any)).called(1);
      },
    );
    test('socket listener sorts new server conversations by time', () async {
      final oldChat = conv1.copyWith(
        id: 'chat_old',
        updatedAt: DateTime(2020),
        lastMessageTime: DateTime(2020),
      );

      when(mockLocal.getAllConversations()).thenReturn([oldChat]);
      when(
        mockRemote.getuserchats(any),
      ).thenAnswer((_) async => Right([oldChat]));
      when(mockLocal.upsertConversations(any)).thenAnswer((_) async {});
      await container
          .read(conversationsViewModelProvider.notifier)
          .loadConversations();
      final newChatId = 'chat_new_server';
      final newChat = conv2.copyWith(
        id: newChatId,
        updatedAt: DateTime(2025),
        lastMessageTime: DateTime(2025),
      );
      when(
        mockRemote.getChatInfo(newChatId, currentUser.id),
      ).thenAnswer((_) async => Right(newChat));
      final messageData = {
        'createdMessage': {
          'id': 'msg_new',
          'chatId': newChatId,
          'userId': 'user_3',
          'content': 'New Msg',
          'createdAt': DateTime(2025).toIso8601String(),
          'status': 'SENT',
          'user': {'username': 'u3', 'name': 'U3'},
        },
        'unseenMessagesCount': 1,
      };

      socketStream.add(messageData);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      final state = container.read(conversationsViewModelProvider).value!;
      expect(state.length, 2);
      expect(state[0].id, newChatId);
      expect(state[1].id, 'chat_old');
    });
    test('searchUsers calls remote', () async {
      final users = [
        UserSearchModel(
          id: 'u2',
          username: 'u2',
          name: 'n',
          bio: '',
          profileMedia: null,
          followers: 0,
        ),
      ];
      when(
        mockRemote.searchUsers('query'),
      ).thenAnswer((_) async => Right(users));

      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .searchUsers('query');

      expect(result, users);
    });

    test('searchUsers returns empty on failure', () async {
      when(
        mockRemote.searchUsers('query'),
      ).thenAnswer((_) async => Left(AppFailure(message: 'Fail')));

      final result = await container
          .read(conversationsViewModelProvider.notifier)
          .searchUsers('query');

      expect(result, isEmpty);
    });
  });
}
