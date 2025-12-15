import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';
import 'package:lite_x/features/chat/view_model/chat/Chat_view_model.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';
import 'Chat_view_model_test.mocks.dart';

class MockCurrentUserNotifier extends CurrentUser {
  final UserModel? _initialUser;
  MockCurrentUserNotifier(this._initialUser);
  @override
  UserModel? build() => _initialUser;
}

class MockConversationsNotifier extends ConversationsViewModel {
  @override
  AsyncValue<List<ConversationModel>> build() {
    return const AsyncValue.data([]);
  }

  @override
  void updateConversationAfterSending({
    required String chatId,
    required String content,
    required String messageType,
    required DateTime timestamp,
  }) {}
}

@GenerateMocks([ChatRemoteRepository, ChatLocalRepository, SocketRepository])
void main() {
  late ProviderContainer container;
  late MockChatRemoteRepository mockRemote;
  late MockChatLocalRepository mockLocal;
  late MockSocketRepository mockSocket;
  late MockConversationsNotifier mockConversationsVM;
  late StreamController<Map<String, dynamic>> newMessageStream;
  late StreamController<Map<String, dynamic>> messageAddedStream;
  late StreamController<Map<String, dynamic>> messagesReadStream;
  late StreamController<Map<String, dynamic>> typingStream;
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

  final msg1 = MessageModel(
    id: 'msg_1',
    chatId: 'chat_1',
    userId: 'user_1',
    content: 'Hello',
    messageType: 'text',
    createdAt: testDate,
    status: 'SENT',
  );

  final msg2 = MessageModel(
    id: 'msg_2',
    chatId: 'chat_1',
    userId: 'user_2',
    content: 'Hi',
    messageType: 'text',
    createdAt: testDate.add(Duration(minutes: 1)),
    status: 'SENT',
  );
  setUpAll(() {
    provideDummy<Either<AppFailure, List<MessageModel>>>(const Right([]));
  });

  setUp(() {
    mockRemote = MockChatRemoteRepository();
    mockLocal = MockChatLocalRepository();
    mockSocket = MockSocketRepository();
    mockConversationsVM = MockConversationsNotifier();

    newMessageStream = StreamController<Map<String, dynamic>>.broadcast();
    messageAddedStream = StreamController<Map<String, dynamic>>.broadcast();
    messagesReadStream = StreamController<Map<String, dynamic>>.broadcast();
    typingStream = StreamController<Map<String, dynamic>>.broadcast();
    when(
      mockSocket.newMessageStream,
    ).thenAnswer((_) => newMessageStream.stream);
    when(
      mockSocket.messageAddedStream,
    ).thenAnswer((_) => messageAddedStream.stream);
    when(
      mockSocket.messagesReadStream,
    ).thenAnswer((_) => messagesReadStream.stream);
    when(mockSocket.typingStream).thenAnswer((_) => typingStream.stream);

    container = ProviderContainer(
      overrides: [
        chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
        chatLocalRepositoryProvider.overrideWithValue(mockLocal),
        socketRepositoryProvider.overrideWithValue(mockSocket),
        currentUserProvider.overrideWith(
          () => MockCurrentUserNotifier(currentUser),
        ),
        conversationsViewModelProvider.overrideWith(() => mockConversationsVM),
      ],
    );
  });

  tearDown(() {
    newMessageStream.close();
    messageAddedStream.close();
    messagesReadStream.close();
    typingStream.close();
    container.dispose();
  });

  group('ChatViewModel', () {
    test('initial build returns empty state', () {
      final state = container.read(chatViewModelProvider);
      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
    });

    test('loadChat returns early if currentUser is null', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          chatRemoteRepositoryProvider.overrideWithValue(mockRemote),
          chatLocalRepositoryProvider.overrideWithValue(mockLocal),
          socketRepositoryProvider.overrideWithValue(mockSocket),
          currentUserProvider.overrideWith(() => MockCurrentUserNotifier(null)),
        ],
      );

      await container.read(chatViewModelProvider.notifier).loadChat('chat_1');
      verifyNever(mockRemote.getlastChatMessages(any));
    });

    test('loadChat loads cached messages then remote messages', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturnInOrder([
        [msg1],
        [msg1, msg2],
      ]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([msg1, msg2]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      await container.read(chatViewModelProvider.notifier).loadChat('chat_1');
      final state = container.read(chatViewModelProvider);
      expect(state.messages.length, 2);
      expect(state.messages.last.id, msg2.id);
      expect(state.isLoading, false);

      verify(mockSocket.openChat('chat_1')).called(1);
    });
    test(
      'loadChat stops processing if active chat changed during remote call',
      () async {
        final completer1 = Completer<Either<AppFailure, List<MessageModel>>>();
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) => completer1.future);
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        when(mockLocal.getCachedMessages('chat_2')).thenReturn([]);
        when(
          mockRemote.getlastChatMessages('chat_2'),
        ).thenAnswer((_) async => Right([]));
        when(mockLocal.getPendingMessages('chat_2')).thenReturn([]);
        final notifier = container.read(chatViewModelProvider.notifier);
        final future1 = notifier.loadChat('chat_1');
        await notifier.loadChat('chat_2');
        completer1.complete(Right([msg1]));
        await future1;
        verifyNever(mockLocal.saveInitialMessages([msg1]));
        verifyNever(mockSocket.openChat('chat_1'));
      },
    );

    test('loadChat handles remote failure gracefully if disposed', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      final completer = Completer<Either<AppFailure, List<MessageModel>>>();
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) => completer.future);
      final notifier = container.read(chatViewModelProvider.notifier);
      final future = notifier.loadChat('chat_1');
      container.dispose();
      completer.complete(Left(AppFailure(message: 'Net Error')));
      await future;
    });
    test('sendMessage creates local message and calls socket', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      when(mockLocal.saveMessage(any)).thenAnswer((_) async {});
      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      await notifier.sendMessage(content: 'Test Msg');
      final state = container.read(chatViewModelProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first.content, 'Test Msg');
      expect(state.messages.first.status, 'SENDING');
      verify(mockSocket.sendMessage(any)).called(1);
    });

    test('handleMessageAck replaces temp message', () async {
      final tempMsg = msg1.copyWith(id: 'temp_1', status: 'SENDING');
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([tempMsg]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([tempMsg]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      when(
        mockLocal.replaceTempWithServerMessage(
          tempId: anyNamed('tempId'),
          serverMessage: anyNamed('serverMessage'),
        ),
      ).thenAnswer((_) async {});
      final subscription = container.listen(chatViewModelProvider, (_, __) {});

      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      expect(container.read(chatViewModelProvider).messages.length, 1);
      final ackData = {'chatId': 'chat_1', 'messageId': 'real_id_1'};
      messageAddedStream.add(ackData);
      await Future.delayed(const Duration(milliseconds: 100));
      final state = container.read(chatViewModelProvider);
      expect(state.messages.isNotEmpty, true);
      expect(state.messages.first.id, 'real_id_1');
      expect(state.messages.first.status, 'SENT');

      verify(
        mockLocal.replaceTempWithServerMessage(
          tempId: 'temp_1',
          serverMessage: anyNamed('serverMessage'),
        ),
      ).called(1);

      subscription.close();
    });

    test('handleIncomingMessage ignores own messages', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      final data = {
        'createdMessage': {
          'id': 'msg_new',
          'chatId': 'chat_1',
          'userId': 'user_1',
          'content': 'Mine',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'SENT',
        },
      };
      newMessageStream.add(data);
      await Future.delayed(Duration(milliseconds: 100));
      final state = container.read(chatViewModelProvider);
      expect(state.messages.length, 0);
      verifyNever(mockLocal.saveMessage(any));
    });

    test(
      'handleIncomingMessage adds others message and marks read if active',
      () async {
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        when(mockLocal.saveMessage(any)).thenAnswer((_) async {});
        final subscription = container.listen(
          chatViewModelProvider,
          (previous, next) {},
        );
        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');
        final data = {
          'createdMessage': {
            'id': 'msg_new',
            'chatId': 'chat_1',
            'userId': 'user_2',
            'content': 'Theirs',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'SENT',
          },
        };
        newMessageStream.add(data);
        await Future.delayed(const Duration(milliseconds: 100));
        final state = container.read(chatViewModelProvider);

        expect(state.messages.length, 1);
        expect(state.messages.first.status, 'READ');
        verify(
          mockLocal.saveMessage(
            argThat(predicate<MessageModel>((m) => m.status == 'READ')),
          ),
        ).called(1);
        verify(mockSocket.openChat('chat_1')).called(2);
        subscription.close();
      },
    );

    test(
      'handleIncomingMessage saves but does not add to state if chat inactive',
      () async {
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        when(mockLocal.saveMessage(any)).thenAnswer((_) async {});
        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');
        final data = {
          'createdMessage': {
            'id': 'msg_other',
            'chatId': 'chat_2',
            'userId': 'user_2',
            'content': 'Other chat',
            'createdAt': DateTime.now().toIso8601String(),
            'status': 'SENT',
          },
        };
        newMessageStream.add(data);
        await Future.delayed(Duration(milliseconds: 100));
        final state = container.read(chatViewModelProvider);
        expect(state.messages, isEmpty);
        verify(
          mockLocal.saveMessage(
            argThat(
              predicate<MessageModel>(
                (m) => m.id == 'msg_other' && m.status == 'SENT',
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'handleMessagesRead updates message status locally and in state',
      () async {
        final sentMsg = msg1.copyWith(status: 'SENT');

        when(mockLocal.getCachedMessages('chat_1')).thenReturn([sentMsg]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([sentMsg]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        when(
          mockLocal.markMessagesAsRead('chat_1', 'user_1'),
        ).thenAnswer((_) async {});
        final subscription = container.listen(
          chatViewModelProvider,
          (_, __) {},
        );

        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');
        expect(
          container.read(chatViewModelProvider).messages.first.status,
          'SENT',
        );
        messagesReadStream.add({'chatId': 'chat_1'});
        await Future.delayed(const Duration(milliseconds: 100));
        final state = container.read(chatViewModelProvider);

        expect(state.messages.isNotEmpty, true);
        expect(state.messages.first.status, 'READ');

        verify(mockLocal.markMessagesAsRead('chat_1', 'user_1')).called(1);

        subscription.close();
      },
    );
    test('sendTyping returns early if no active chat', () {
      container.read(chatViewModelProvider.notifier).sendTyping(true);
      verifyNever(mockSocket.sendTyping(any, any));
    });
    test('isActiveChat returns correct status', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      final notifier = container.read(chatViewModelProvider.notifier);
      expect(notifier.isActiveChat('chat_1'), false);
      await notifier.loadChat('chat_1');
      expect(notifier.isActiveChat('chat_1'), true);
      expect(notifier.isActiveChat('chat_2'), false);
    });
    test(
      'loadOlderMessages sets hasMoreHistory to false when empty list returned',
      () async {
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([msg1]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([msg1]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        when(
          mockRemote.getOlderMessagesChat(
            chatId: 'chat_1',
            lastMessageTimestamp: anyNamed('lastMessageTimestamp'),
          ),
        ).thenAnswer((_) async => Right([]));
        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');
        await notifier.loadOlderMessages();
        final state = container.read(chatViewModelProvider);
        expect(state.isLoadingHistory, false);
        expect(state.hasMoreHistory, false);
      },
    );

    test(
      'loadOlderMessages stops execution on failure if view model is disposed',
      () async {
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([msg1]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([msg1]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        final completer = Completer<Either<AppFailure, List<MessageModel>>>();
        when(
          mockRemote.getOlderMessagesChat(
            chatId: 'chat_1',
            lastMessageTimestamp: anyNamed('lastMessageTimestamp'),
          ),
        ).thenAnswer((_) => completer.future);

        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');
        final future = notifier.loadOlderMessages();
        expect(container.read(chatViewModelProvider).isLoadingHistory, true);
        container.dispose();
        completer.complete(Left(AppFailure(message: 'Network Error')));
        await expectLater(future, completes);
      },
    );
    test('handleMessageAck ignores null IDs', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      messageAddedStream.add({'chatId': null, 'messageId': 'real_id'});
      messageAddedStream.add({'chatId': 'chat_1', 'messageId': null});
      await Future.delayed(Duration.zero);
      verifyNever(
        mockLocal.replaceTempWithServerMessage(
          tempId: anyNamed('tempId'),
          serverMessage: anyNamed('serverMessage'),
        ),
      );
    });

    test(
      'loadOlderMessages handles disposed state gracefully (Success case)',
      () async {
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([msg1]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([msg1]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');
        final completer = Completer<Either<AppFailure, List<MessageModel>>>();
        when(
          mockRemote.getOlderMessagesChat(
            chatId: 'chat_1',
            lastMessageTimestamp: anyNamed('lastMessageTimestamp'),
          ),
        ).thenAnswer((_) => completer.future);
        final future = notifier.loadOlderMessages();
        container.dispose();
        completer.complete(Right([msg2]));
        await expectLater(future, completes);
      },
    );

    test(
      'loadOlderMessages handles disposed state gracefully (Failure case)',
      () async {
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([msg1]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([msg1]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);

        final notifier = container.read(chatViewModelProvider.notifier);
        await notifier.loadChat('chat_1');

        final completer = Completer<Either<AppFailure, List<MessageModel>>>();
        when(
          mockRemote.getOlderMessagesChat(
            chatId: 'chat_1',
            lastMessageTimestamp: anyNamed('lastMessageTimestamp'),
          ),
        ).thenAnswer((_) => completer.future);
        final future = notifier.loadOlderMessages();
        container.dispose();
        completer.complete(Left(AppFailure(message: 'Fail')));
        await expectLater(future, completes);
      },
    );
    test('sendTyping calls socket when chat is active', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      notifier.sendTyping(true);
      verify(mockSocket.sendTyping('chat_1', true)).called(1);
    });

    test(
      'reconcilePendingMessages finds match and replaces temp message',
      () async {
        final pendingDate = DateTime.now();
        final pendingMsg = MessageModel(
          id: 'temp_123',
          chatId: 'chat_1',
          userId: 'user_1',
          content: 'Hello World',
          messageType: 'text',
          createdAt: pendingDate,
          status: 'SENDING',
        );
        final serverMsg = MessageModel(
          id: 'server_999',
          chatId: 'chat_1',
          userId: 'user_1',
          content: 'Hello World',
          messageType: 'text',
          createdAt: pendingDate.add(const Duration(seconds: 5)),
          status: 'SENT',
        );
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([serverMsg]));
        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([pendingMsg]);
        when(
          mockLocal.replaceTempWithServerMessage(
            tempId: anyNamed('tempId'),
            serverMessage: anyNamed('serverMessage'),
          ),
        ).thenAnswer((_) async {});
        await container.read(chatViewModelProvider.notifier).loadChat('chat_1');
        verify(
          mockLocal.replaceTempWithServerMessage(
            tempId: 'temp_123',
            serverMessage: serverMsg,
          ),
        ).called(1);
        verifyNever(mockSocket.sendMessage(any));
      },
    );

    test(
      'reconcilePendingMessages resends message if no match found',
      () async {
        final pendingDate = DateTime.now();
        final pendingMsg = MessageModel(
          id: 'temp_456',
          chatId: 'chat_1',
          userId: 'user_1',
          content: 'Missed Message',
          messageType: 'text',
          createdAt: pendingDate,
          status: 'SENDING',
        );
        when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
        when(
          mockRemote.getlastChatMessages('chat_1'),
        ).thenAnswer((_) async => Right([]));

        when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
        when(mockLocal.getPendingMessages('chat_1')).thenReturn([pendingMsg]);
        await container.read(chatViewModelProvider.notifier).loadChat('chat_1');
        verifyNever(
          mockLocal.replaceTempWithServerMessage(
            tempId: anyNamed('tempId'),
            serverMessage: anyNamed('serverMessage'),
          ),
        );
        verify(
          mockSocket.sendMessage(
            argThat(
              predicate<Map<String, dynamic>>(
                (map) =>
                    map['data']['content'] == 'Missed Message' &&
                    map['chatId'] == 'chat_1',
              ),
            ),
          ),
        ).called(1);
      },
    );
    test('loadOlderMessages fetches history and prepends', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([msg2]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([msg2]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getOlderMessagesChat(
          chatId: 'chat_1',
          lastMessageTimestamp: anyNamed('lastMessageTimestamp'),
        ),
      ).thenAnswer((_) async => Right([msg1]));
      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      expect(container.read(chatViewModelProvider).messages.length, 1);
      await notifier.loadOlderMessages();
      final state = container.read(chatViewModelProvider);
      expect(state.messages.length, 2);
      expect(state.isLoadingHistory, false);
      expect(state.hasMoreHistory, true);
      expect(state.messages.first.id, msg1.id);
      expect(state.messages.last.id, msg2.id);
    });
    test('handleTypingEvent updates state', () async {
      when(mockLocal.getCachedMessages('chat_1')).thenReturn([]);
      when(
        mockRemote.getlastChatMessages('chat_1'),
      ).thenAnswer((_) async => Right([]));
      when(mockLocal.saveInitialMessages(any)).thenAnswer((_) async {});
      when(mockLocal.getPendingMessages('chat_1')).thenReturn([]);
      final subscription = container.listen(chatViewModelProvider, (_, __) {});
      final notifier = container.read(chatViewModelProvider.notifier);
      await notifier.loadChat('chat_1');
      typingStream.add({
        'chatId': 'chat_1',
        'userId': 'user_2',
        'isTyping': true,
      });
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(chatViewModelProvider).isRecipientTyping, true);
      subscription.close();
    });
  });
}
