// chat_remote_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'chat_remote_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late ChatRemoteRepository chatRepository;

  setUp(() {
    mockDio = MockDio();
    chatRepository = ChatRemoteRepository(dio: mockDio);
  });
  group('create_chat', () {
    const testRecipientIds = ['user1', 'user2'];
    const testCurrentUserId = 'currentUser';
    const testDMChat = true;

    final newChatResponse = {
      'newChat': {
        'id': 'chat123',
        'DMChat': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
        'chatUsers': [
          {
            'userId': 'user1',
            'user': {
              'id': 'user1',
              'name': 'User One',
              'username': 'user1',
              'profileMediaId': 'profile1',
            },
          },
          {
            'userId': testCurrentUserId,
            'user': {
              'id': testCurrentUserId,
              'name': 'Current User',
              'username': 'current',
            },
          },
        ],
        'messages': [],
        'unseenMessagesCount': 0,
      },
    };

    test(
      'should return ConversationModel on successful chat creation',
      () async {
        when(
          mockDio.post(
            'api/dm/chat/create-chat',
            data: {'participant_ids': testRecipientIds, 'DMChat': testDMChat},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
            data: newChatResponse,
            statusCode: 200,
          ),
        );

        final result = await chatRepository.create_chat(
          recipientIds: testRecipientIds,
          Current_UserId: testCurrentUserId,
          DMChat: testDMChat,
        );

        expect(result.isRight(), true);
        result.fold((failure) => fail('Should have returned Right'), (
          conversation,
        ) {
          expect(conversation, isA<ConversationModel>());
          expect(conversation.id, 'chat123');
          expect(conversation.isDMChat, true);
          expect(conversation.participantIds.length, 2);
        });
      },
    );

    test('should return ConversationModel for group chat', () async {
      final groupChatResponse = {
        'newChat': {
          'id': 'groupChat123',
          'DMChat': false,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
          'chatUsers': [
            {'userId': 'user1'},
            {'userId': 'user2'},
            {'userId': testCurrentUserId},
          ],
          'messages': [],
          'unseenMessagesCount': 0,
        },
      };

      when(
        mockDio.post(
          'api/dm/chat/create-chat',
          data: {
            'participant_ids': ['user1', 'user2', testCurrentUserId],
            'DMChat': false,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
          data: groupChatResponse,
          statusCode: 200,
        ),
      );

      final result = await chatRepository.create_chat(
        recipientIds: ['user1', 'user2', testCurrentUserId],
        Current_UserId: testCurrentUserId,
        DMChat: false,
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (
        conversation,
      ) {
        expect(conversation.isDMChat, false);
        expect(conversation.isGroup, true);
      });
    });

    test('should return AppFailure with message on DioException', () async {
      when(
        mockDio.post('api/dm/chat/create-chat', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
            data: {'message': 'Chat already exists'},
            statusCode: 400,
          ),
        ),
      );

      final result = await chatRepository.create_chat(
        recipientIds: testRecipientIds,
        Current_UserId: testCurrentUserId,
        DMChat: testDMChat,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, 'Chat already exists');
      }, (conversation) => fail('Should have returned Left'));
    });

    test('should return AppFailure with error field on DioException', () async {
      when(
        mockDio.post('api/dm/chat/create-chat', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
            data: {'error': 'Invalid participants'},
            statusCode: 400,
          ),
        ),
      );

      final result = await chatRepository.create_chat(
        recipientIds: testRecipientIds,
        Current_UserId: testCurrentUserId,
        DMChat: testDMChat,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Invalid participants');
      }, (conversation) => fail('Should have returned Left'));
    });

    test('should return default error message on DioException', () async {
      when(
        mockDio.post('api/dm/chat/create-chat', data: anyNamed('data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/create-chat'),
          message: 'Network error',
        ),
      );

      final result = await chatRepository.create_chat(
        recipientIds: testRecipientIds,
        Current_UserId: testCurrentUserId,
        DMChat: testDMChat,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to create chat');
      }, (conversation) => fail('Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.post('api/dm/chat/create-chat', data: anyNamed('data')),
      ).thenThrow(Exception('Unexpected error'));

      final result = await chatRepository.create_chat(
        recipientIds: testRecipientIds,
        Current_UserId: testCurrentUserId,
        DMChat: testDMChat,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (conversation) => fail('Should have returned Left'));
    });
  });

  group('getlastChatMessages', () {
    const testChatId = 'chat123';

    final messagesResponse = {
      'messages': [
        {
          'id': 'msg1',
          'chatId': testChatId,
          'userId': 'user1',
          'content': 'Hello',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'status': 'SENT',
          'user': {
            'username': 'user1',
            'name': 'User One',
            'profileMediaId': 'profile1',
          },
        },
        {
          'id': 'msg2',
          'chatId': testChatId,
          'userId': 'user2',
          'content': 'Hi there',
          'createdAt': '2024-01-01T00:01:00.000Z',
          'status': 'READ',
          'user': {'username': 'user2', 'name': 'User Two'},
        },
      ],
    };

    test('should return list of MessageModel on success', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: messagesResponse,
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (messages) {
        expect(messages, isA<List<MessageModel>>());
        expect(messages.length, 2);
        expect(messages[0].id, 'msg1');
        expect(messages[0].content, 'Hello');
        expect(messages[1].id, 'msg2');
        expect(messages[1].status, 'READ');
      });
    });

    test('should return empty list when no messages', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: {'messages': []},
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (messages) {
        expect(messages, isEmpty);
      });
    });

    test('should handle null messages field', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: <String, dynamic>{},
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (messages) {
        expect(messages, isEmpty);
      });
    });

    test('should return AppFailure on DioException with message', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
            data: {'message': 'Chat not found'},
            statusCode: 404,
          ),
        ),
      );

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Chat not found');
      }, (messages) => fail('Should have returned Left'));
    });

    test('should return AppFailure on DioException with error', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
            data: {'error': 'Unauthorized access'},
            statusCode: 403,
          ),
        ),
      );

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Unauthorized access');
      }, (messages) => fail('Should have returned Left'));
    });

    test('should return default error on DioException', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          message: 'Network error',
        ),
      );

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to get initial messages');
      }, (messages) => fail('Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.get('api/dm/chat/$testChatId'),
      ).thenThrow(Exception('Parse error'));

      final result = await chatRepository.getlastChatMessages(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (messages) => fail('Should have returned Left'));
    });
  });

  group('getuserchats', () {
    const testCurrentUserId = 'currentUser';

    final chatsListResponse = [
      {
        'id': 'chat1',
        'DMChat': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
        'chatUsers': [
          {
            'userId': 'user1',
            'user': {'id': 'user1', 'name': 'User One', 'username': 'user1'},
          },
          {
            'userId': testCurrentUserId,
            'user': {'id': testCurrentUserId},
          },
        ],
        'messages': [],
        'unseenMessagesCount': 2,
      },
      {
        'id': 'chat2',
        'DMChat': false,
        'createdAt': '2024-01-02T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
        'chatUsers': [
          {'userId': 'user2'},
          {'userId': 'user3'},
          {'userId': testCurrentUserId},
        ],
        'messages': [],
        'unseenMessagesCount': 0,
      },
    ];

    test('should return list of ConversationModel on success', () async {
      when(mockDio.get('api/dm/chat/user')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/user'),
          data: chatsListResponse,
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getuserchats(testCurrentUserId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (
        conversations,
      ) {
        expect(conversations, isA<List<ConversationModel>>());
        expect(conversations.length, 2);
        expect(conversations[0].id, 'chat1');
        expect(conversations[0].isDMChat, true);
        expect(conversations[0].unseenCount, 2);
        expect(conversations[1].id, 'chat2');
        expect(conversations[1].isGroup, true);
      });
    });

    test('should return empty list when user has no chats', () async {
      when(mockDio.get('api/dm/chat/user')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/user'),
          data: [],
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getuserchats(testCurrentUserId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (
        conversations,
      ) {
        expect(conversations, isEmpty);
      });
    });

    test('should return AppFailure on DioException with message', () async {
      when(mockDio.get('api/dm/chat/user')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/user'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/user'),
            data: {'message': 'User not authenticated'},
            statusCode: 401,
          ),
        ),
      );

      final result = await chatRepository.getuserchats(testCurrentUserId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'User not authenticated');
      }, (conversations) => fail('Should have returned Left'));
    });

    test('should return AppFailure on DioException with error', () async {
      when(mockDio.get('api/dm/chat/user')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/user'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/user'),
            data: {'error': 'Database error'},
            statusCode: 500,
          ),
        ),
      );

      final result = await chatRepository.getuserchats(testCurrentUserId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Database error');
      }, (conversations) => fail('Should have returned Left'));
    });

    test('should return default error on DioException', () async {
      when(mockDio.get('api/dm/chat/user')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/user'),
          message: 'Connection timeout',
        ),
      );

      final result = await chatRepository.getuserchats(testCurrentUserId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to get user chats');
      }, (conversations) => fail('Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.get('api/dm/chat/user'),
      ).thenThrow(Exception('Unexpected error'));

      final result = await chatRepository.getuserchats(testCurrentUserId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (conversations) => fail('Should have returned Left'));
    });
  });

  group('getOlderMessagesChat', () {
    const testChatId = 'chat123';
    final testTimestamp = DateTime(2024, 1, 1, 12, 0, 0);

    final olderMessagesResponse = [
      {
        'id': 'msg1',
        'chatId': testChatId,
        'userId': 'user1',
        'content': 'Old message 1',
        'createdAt': '2024-01-01T10:00:00.000Z',
        'status': 'READ',
        'user': {'username': 'user1', 'name': 'User One'},
      },
      {
        'id': 'msg2',
        'chatId': testChatId,
        'userId': 'user2',
        'content': 'Old message 2',
        'createdAt': '2024-01-01T11:00:00.000Z',
        'status': 'READ',
        'user': {'username': 'user2', 'name': 'User Two'},
      },
    ];

    test('should return list of older messages on success', () async {
      when(
        mockDio.get(
          'api/dm/chat/$testChatId/messages',
          queryParameters: {
            'lastMessageTimestamp': testTimestamp.toIso8601String() + 'Z',
            'chatId': testChatId,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/dm/chat/$testChatId/messages',
          ),
          data: olderMessagesResponse,
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getOlderMessagesChat(
        chatId: testChatId,
        lastMessageTimestamp: testTimestamp,
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (messages) {
        expect(messages, isA<List<MessageModel>>());
        expect(messages.length, 2);
        expect(messages[0].id, 'msg1');
        expect(messages[0].content, 'Old message 1');
        expect(messages[1].id, 'msg2');
      });
    });

    test('should return empty list when no older messages', () async {
      when(
        mockDio.get(
          'api/dm/chat/$testChatId/messages',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: 'api/dm/chat/$testChatId/messages',
          ),
          data: [],
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getOlderMessagesChat(
        chatId: testChatId,
        lastMessageTimestamp: testTimestamp,
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (messages) {
        expect(messages, isEmpty);
      });
    });

    test('should return AppFailure on DioException with message', () async {
      when(
        mockDio.get(
          'api/dm/chat/$testChatId/messages',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'api/dm/chat/$testChatId/messages',
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: 'api/dm/chat/$testChatId/messages',
            ),
            data: {'message': 'Invalid timestamp'},
            statusCode: 400,
          ),
        ),
      );

      final result = await chatRepository.getOlderMessagesChat(
        chatId: testChatId,
        lastMessageTimestamp: testTimestamp,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Invalid timestamp');
      }, (messages) => fail('Should have returned Left'));
    });

    test('should return default error on DioException', () async {
      when(
        mockDio.get(
          'api/dm/chat/$testChatId/messages',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: 'api/dm/chat/$testChatId/messages',
          ),
          message: 'Network error',
        ),
      );

      final result = await chatRepository.getOlderMessagesChat(
        chatId: testChatId,
        lastMessageTimestamp: testTimestamp,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to get messages');
      }, (messages) => fail('Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.get(
          'api/dm/chat/$testChatId/messages',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(Exception('Parse error'));

      final result = await chatRepository.getOlderMessagesChat(
        chatId: testChatId,
        lastMessageTimestamp: testTimestamp,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (messages) => fail('Should have returned Left'));
    });
  });

  group('searchUsers', () {
    const testQuery = 'john';

    final searchUsersResponse = {
      'users': [
        {
          'id': 'user1',
          'username': 'john_doe',
          'name': 'John Doe',
          'bio': 'Software developer',
          'profileMedia': {'keyName': 'profile/user1.jpg'},
          '_count': {'followers': 150},
        },
        {
          'id': 'user2',
          'username': 'johnny',
          'name': 'Johnny Smith',
          'bio': null,
          'profileMedia': 'profile/user2.jpg',
          '_count': {'followers': 75},
        },
        {
          'id': 'user3',
          'username': 'john123',
          'name': 'John Johnson',
          'profileMedia': null,
          '_count': null,
        },
      ],
    };

    test('should return list of UserSearchModel on success', () async {
      when(
        mockDio.get('api/users/search', queryParameters: {'query': testQuery}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/users/search'),
          data: searchUsersResponse,
          statusCode: 200,
        ),
      );

      final result = await chatRepository.searchUsers(testQuery);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (users) {
        expect(users, isA<List<UserSearchModel>>());
        expect(users.length, 3);
        expect(users[0].id, 'user1');
        expect(users[0].username, 'john_doe');
        expect(users[0].followers, 150);
        expect(users[0].profileMedia, 'profile/user1.jpg');
        expect(users[1].followers, 75);
        expect(users[2].followers, 0);
      });
    });

    test('should return empty list when no users found', () async {
      when(
        mockDio.get('api/users/search', queryParameters: {'query': testQuery}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/users/search'),
          data: {'users': []},
          statusCode: 200,
        ),
      );

      final result = await chatRepository.searchUsers(testQuery);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (users) {
        expect(users, isEmpty);
      });
    });

    test('should handle null users field', () async {
      when(
        mockDio.get('api/users/search', queryParameters: {'query': testQuery}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/users/search'),
          data: <String, dynamic>{},
          statusCode: 200,
        ),
      );

      final result = await chatRepository.searchUsers(testQuery);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (users) {
        expect(users, isEmpty);
      });
    });

    test('should return AppFailure on DioException with message', () async {
      when(
        mockDio.get(
          'api/users/search',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/search'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/users/search'),
            data: {'message': 'Query too short'},
            statusCode: 400,
          ),
        ),
      );

      final result = await chatRepository.searchUsers(testQuery);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Query too short');
      }, (users) => fail('Should have returned Left'));
    });

    test('should return AppFailure on DioException with error', () async {
      when(
        mockDio.get(
          'api/users/search',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/users/search'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/users/search'),
            data: {'error': 'Rate limit exceeded'},
            statusCode: 429,
          ),
        ),
      );

      final result = await chatRepository.searchUsers(testQuery);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Rate limit exceeded');
      }, (users) => fail('Should have returned Left'));
    });
    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.get(
          'api/users/search',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(Exception('Unexpected system error'));
      final result = await chatRepository.searchUsers(testQuery);
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, contains('Exception: Unexpected system error'));
      }, (users) => fail('Should have returned Left'));
    });
  });
  group('getChatInfo', () {
    const testChatId = 'chat123';
    const testCurrentUserId = 'currentUser';

    final chatInfoResponse = {
      'id': testChatId,
      'DMChat': true,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
      'chatUsers': [
        {
          'userId': 'user1',
          'user': {
            'id': 'user1',
            'name': 'User One',
            'username': 'user1',
            'profileMediaId': 'profile1',
          },
        },
        {
          'userId': testCurrentUserId,
          'user': {'id': testCurrentUserId},
        },
      ],
      'messages': [
        {
          'content': 'Last message',
          'createdAt': '2024-01-01T12:00:00.000Z',
          'userId': 'user1',
        },
      ],
      'unseenMessagesCount': 5,
    };

    test('should return ConversationModel on success', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: chatInfoResponse,
          statusCode: 200,
        ),
      );

      final result = await chatRepository.getChatInfo(
        testChatId,
        testCurrentUserId,
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (
        conversation,
      ) {
        expect(conversation, isA<ConversationModel>());
        expect(conversation.id, testChatId);
        expect(conversation.isDMChat, true);
        expect(conversation.unseenCount, 5);
        expect(conversation.lastMessageContent, 'Last message');
      });
    });

    test('should return AppFailure on DioException with message', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
            data: {'message': 'Chat not found'},
            statusCode: 404,
          ),
        ),
      );

      final result = await chatRepository.getChatInfo(
        testChatId,
        testCurrentUserId,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Chat not found');
      }, (conversation) => fail('Should have returned Left'));
    });

    test('should return default error on DioException', () async {
      when(mockDio.get('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          message: 'Network error',
        ),
      );

      final result = await chatRepository.getChatInfo(
        testChatId,
        testCurrentUserId,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to get chat info');
      }, (conversation) => fail('Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.get('api/dm/chat/$testChatId'),
      ).thenThrow(Exception('Parse error'));

      final result = await chatRepository.getChatInfo(
        testChatId,
        testCurrentUserId,
      );

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (conversation) => fail('Should have returned Left'));
    });
  });

  group('deleteChat', () {
    const testChatId = 'chat123';

    test('should return success message on successful deletion', () async {
      when(mockDio.delete('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: {'message': 'Chat deleted successfully'},
          statusCode: 200,
        ),
      );

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (message) {
        expect(message, 'Chat deleted successfully');
      });
    });

    test('should return default message when message is missing', () async {
      when(mockDio.delete('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: <String, dynamic>{},
          statusCode: 200,
        ),
      );

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should have returned Right'), (message) {
        expect(message, 'Chat deleted successfully');
      });
    });

    test('should return AppFailure on non-200 status code', () async {
      when(mockDio.delete('api/dm/chat/$testChatId')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          data: {},
          statusCode: 500,
        ),
      );

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Unexpected error');
      }, (message) => fail('Should have returned Left'));
    });

    test('should return AppFailure on DioException with message', () async {
      when(mockDio.delete('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
            data: {'message': 'Unauthorized to delete'},
            statusCode: 403,
          ),
        ),
      );

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Unauthorized to delete');
      }, (message) => fail('Should have returned Left'));
    });

    test('should return AppFailure on DioException with error', () async {
      when(mockDio.delete('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          response: Response(
            requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
            data: {'error': 'Chat not found'},
            statusCode: 404,
          ),
        ),
      );

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Chat not found');
      }, (message) => fail('Should have returned Left'));
    });

    test('should return default error on DioException', () async {
      when(mockDio.delete('api/dm/chat/$testChatId')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/dm/chat/$testChatId'),
          message: 'Network error',
        ),
      );

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure.message, 'Failed to delete chat');
      }, (message) => fail('Should have returned Left'));
    });

    test('should return AppFailure on generic exception', () async {
      when(
        mockDio.delete('api/dm/chat/$testChatId'),
      ).thenThrow(Exception('Unexpected error'));

      final result = await chatRepository.deleteChat(testChatId);

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Exception'));
      }, (message) => fail('Should have returned Left'));
    });
  });
}
