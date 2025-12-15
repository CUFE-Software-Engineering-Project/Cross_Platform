import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/providers/unseenChatsCountProvider.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'socket_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<io.Socket>(), MockSpec<AuthLocalRepository>()])
void main() {
  late MockSocket mockSocket;
  late MockAuthLocalRepository mockAuthRepo;
  late ProviderContainer container;
  late SocketRepository repository;

  setUpAll(() async {
    dotenv.load(fileName: ".env");
  });

  setUp(() {
    mockSocket = MockSocket();
    mockAuthRepo = MockAuthLocalRepository();

    when(mockAuthRepo.getTokens()).thenReturn(null);
    when(mockAuthRepo.tokenStream).thenAnswer((_) => Stream.value(null));

    container = ProviderContainer(
      overrides: [
        authLocalRepositoryProvider.overrideWithValue(mockAuthRepo),
        unseenChatsCountProvider.overrideWith((ref) => 0),
        socketRepositoryProvider.overrideWith((ref) {
          return SocketRepository(ref: ref, socket: mockSocket);
        }),
      ],
    );

    repository = container.read(socketRepositoryProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('SocketRepository Initialization', () {
    test('should set up listeners on initialization', () {
      verify(mockSocket.on('new-message', captureAny)).called(1);
      verify(mockSocket.on('messages-read', captureAny)).called(1);
      verify(mockSocket.on('message-added', captureAny)).called(1);
      verify(mockSocket.on('user-typing', captureAny)).called(1);
      verify(mockSocket.on('unseen-chats-count', captureAny)).called(1);
    });
    test('listens to token stream changes', () {
      verify(mockAuthRepo.tokenStream).called(1);
    });
  });

  group('Incoming Socket Events (Streams)', () {
    test('new-message event should add data to newMessageStream', () async {
      final captured = verify(
        mockSocket.on('new-message', captureAny),
      ).captured;
      final callback = captured.first as Function(dynamic);

      expectLater(
        repository.newMessageStream,
        emits({'id': 'msg_1', 'content': 'Hello'}),
      );

      callback({'id': 'msg_1', 'content': 'Hello'});
    });

    test('messages-read event should add data to messagesReadStream', () async {
      final captured = verify(
        mockSocket.on('messages-read', captureAny),
      ).captured;
      final callback = captured.first as Function(dynamic);

      expectLater(repository.messagesReadStream, emits({'chatId': '123'}));

      callback({'chatId': '123'});
    });

    test('message-added event should add data to messageAddedStream', () async {
      final captured = verify(
        mockSocket.on('message-added', captureAny),
      ).captured;
      final callback = captured.first as Function(dynamic);

      expectLater(repository.messageAddedStream, emits({'status': 'sent'}));

      callback({'status': 'sent'});
    });

    test('user-typing event should add data to typingStream', () async {
      final captured = verify(
        mockSocket.on('user-typing', captureAny),
      ).captured;
      final callback = captured.first as Function(dynamic);

      expectLater(
        repository.typingStream,
        emits({'userId': 'u1', 'isTyping': true}),
      );

      callback({'userId': 'u1', 'isTyping': true});
    });

    test('unseen-chats-count event should update provider state', () async {
      final capturedSocketListener =
          verify(mockSocket.on('unseen-chats-count', captureAny)).captured.first
              as Function(dynamic);

      capturedSocketListener({'count': 5});
      await Future.delayed(Duration.zero);
      expect(container.read(unseenChatsCountProvider), 5);
    });
  });
  group('Socket Listener Wrappers (onX methods)', () {
    test('onNewMessage registers callback and executes it', () {
      bool callbackCalled = false;
      final testData = {'content': 'test_data'};
      repository.onNewMessage((data) {
        callbackCalled = true;
        expect(data, testData);
      });
      final captured = verify(
        mockSocket.on('new-message', captureAny),
      ).captured;
      final socketCallback = captured.last as Function(dynamic);
      socketCallback(testData);
      expect(callbackCalled, true);
    });

    test('onTyping registers callback and executes it', () {
      bool callbackCalled = false;
      final testData = {'status': 'typing_data'};

      repository.onTyping((data) {
        callbackCalled = true;
        expect(data, testData);
      });

      final captured = verify(
        mockSocket.on('user-typing', captureAny),
      ).captured;
      final socketCallback = captured.last as Function(dynamic);
      socketCallback(testData);

      expect(callbackCalled, true);
    });

    test('onMessagesRead registers callback and executes it', () {
      bool callbackCalled = false;
      final testData = {'read': 'true'};

      repository.onMessagesRead((data) {
        callbackCalled = true;
        expect(data, testData);
      });

      final captured = verify(
        mockSocket.on('messages-read', captureAny),
      ).captured;
      final socketCallback = captured.last as Function(dynamic);
      socketCallback(testData);

      expect(callbackCalled, true);
    });

    test('onMessageAdded registers callback and executes it', () {
      bool callbackCalled = false;
      final testData = {'id': 'added_data'};

      repository.onMessageAdded((data) {
        callbackCalled = true;
        expect(data, testData);
      });

      final captured = verify(
        mockSocket.on('message-added', captureAny),
      ).captured;
      final socketCallback = captured.last as Function(dynamic);
      socketCallback(testData);

      expect(callbackCalled, true);
    });
  });
  group('socketRepositoryProvider (keepAlive)', () {
    test('creates SocketRepository and is not auto-disposed', () {
      final container = ProviderContainer(
        overrides: [
          authLocalRepositoryProvider.overrideWithValue(mockAuthRepo),
          unseenChatsCountProvider.overrideWith((ref) => 0),
        ],
      );
      final listener = container.listen(socketRepositoryProvider, (_, __) {});
      final repo1 = container.read(socketRepositoryProvider);
      listener.close();
      final repo2 = container.read(socketRepositoryProvider);
      expect(identical(repo1, repo2), isTrue);
      container.dispose();
    });
  });

  group('Outgoing Socket Events', () {
    test('sendMessage emits add-message', () {
      final msg = {'content': 'hi'};
      repository.sendMessage(msg);
      verify(mockSocket.emit('add-message', {'message': msg})).called(1);
    });

    test('sendTyping emits typing', () {
      repository.sendTyping('chat_1', true);
      verify(
        mockSocket.emit('typing', {'chatId': 'chat_1', 'isTyping': true}),
      ).called(1);
    });

    test('sendOpenMessageTab emits open-message-tab', () {
      repository.sendOpenMessageTab();
      verify(mockSocket.emit('open-message-tab')).called(1);
    });

    test('openChat emits open-chat', () {
      repository.openChat('chat_1');
      verify(mockSocket.emit('open-chat', {'chatId': 'chat_1'})).called(1);
    });
  });
  test(
    'dispose disconnects socket and closes all stream controllers',
    () async {
      repository.dispose();
      verify(mockSocket.disconnect()).called(1);
      verify(mockSocket.dispose()).called(1);
      expect(await repository.newMessageStream.isEmpty, isTrue);
      expect(await repository.messageAddedStream.isEmpty, isTrue);
      expect(await repository.typingStream.isEmpty, isTrue);
      expect(await repository.messagesReadStream.isEmpty, isTrue);
      expect(await repository.unseenChatsStream.isEmpty, isTrue);
    },
  );
}
