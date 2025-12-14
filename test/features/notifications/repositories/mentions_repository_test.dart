import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/notifications/repositories/mentions_repository.dart';
import 'package:lite_x/features/notifications/mentions_model.dart';
import 'package:lite_x/features/notifications/mentions_provider.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/models/usermodel.dart';

import 'mentions_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('MentionsRepository', () {
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
    });

    MentionsRepository _createRepository({UserModel? user}) {
      final testUser = user ??
          UserModel(
            id: 'user1',
            username: 'testuser',
            name: 'Test User',
            email: 'test@test.com',
            dob: '2000-01-01',
            isEmailVerified: true,
            isVerified: false,
            interests: const {},
          );

      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(mockDio),
          currentUserProvider.overrideWith(() {
            return CurrentUser();
          }),
        ],
      );
      
      // Set the user after container is created
      container.read(currentUserProvider.notifier).adduser(testUser);
      
      return container.read(mentionsRepositoryProvider);
    }

    test('fetches mentions from List response', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: [
          {
            'id': '1',
            'content': '@testuser mentioned',
            'createdAt': '2024-01-01',
            'likesCount': 5,
            'retweetCount': 2,
            'repliesCount': 1,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.fetchMentions();

      expect(result, isA<List<MentionItem>>());
      expect(result.length, 1);
      expect(result[0].content, '@testuser mentioned');
    });

    test('fetches mentions from Map response', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {
          'tweets': [
            {
              'id': '1',
              'content': '@testuser test',
              'createdAt': '2024-01-01',
              'likesCount': 0,
              'retweetCount': 0,
              'repliesCount': 0,
              'quotesCount': 0,
              'replyControl': 'everyone',
              'tweetType': 'tweet',
              'isLiked': false,
              'isRetweeted': false,
              'isBookmarked': false,
              'user': {
                'id': 'user1',
                'name': 'John',
                'username': 'john',
                'verified': false,
                'protectedAccount': false,
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.fetchMentions();

      expect(result, isA<List<MentionItem>>());
      expect(result.length, 1);
    });

    test('throws exception when user not logged in', () async {
      final repository = _createRepository(
        user: UserModel(
          id: '',
          username: '',
          name: '',
          email: '',
          dob: '',
          isEmailVerified: false,
          isVerified: false,
          interests: const {},
        ),
      );

      expect(
        () => repository.fetchMentions(),
        throwsException,
      );
    });

    test('handles empty mentions list', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: [],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.fetchMentions();

      expect(result, isEmpty);
    });

    test('throws exception on non-200 response', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: [],
        statusCode: 500,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      expect(
        () => repository.fetchMentions(),
        throwsException,
      );
    });

    test('fetches mentions with Map response using "data" key', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {
          'data': [
            {
              'id': '1',
              'content': '@testuser test',
              'createdAt': '2024-01-01',
              'likesCount': 0,
              'retweetCount': 0,
              'repliesCount': 0,
              'quotesCount': 0,
              'replyControl': 'everyone',
              'tweetType': 'tweet',
              'isLiked': false,
              'isRetweeted': false,
              'isBookmarked': false,
              'user': {
                'id': 'user1',
                'name': 'John',
                'username': 'john',
                'verified': false,
                'protectedAccount': false,
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.fetchMentions();

      expect(result.length, 1);
    });

    test('fetches mentions with Map response using "items" key', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {
          'items': [
            {
              'id': '1',
              'content': '@testuser test',
              'createdAt': '2024-01-01',
              'likesCount': 0,
              'retweetCount': 0,
              'repliesCount': 0,
              'quotesCount': 0,
              'replyControl': 'everyone',
              'tweetType': 'tweet',
              'isLiked': false,
              'isRetweeted': false,
              'isBookmarked': false,
              'user': {
                'id': 'user1',
                'name': 'John',
                'username': 'john',
                'verified': false,
                'protectedAccount': false,
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.fetchMentions();

      expect(result.length, 1);
    });

    test('throws exception when Map response has no list', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {'key': 'value', 'another': 'data'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      expect(
        () => repository.fetchMentions(),
        throwsException,
      );
    });

    test('throws exception on unexpected response type', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: 'string response',
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockResponse);

      expect(
        () => repository.fetchMentions(),
        throwsException,
      );
    });

    test('fetches mentions with profile media', () async {
      final repository = _createRepository();

      final mockMentionsResponse = Response(
        data: [
          {
            'id': '1',
            'content': '@testuser test',
            'createdAt': '2024-01-01',
            'likesCount': 0,
            'retweetCount': 0,
            'repliesCount': 0,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'mediaIds': [],
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
              'profileMedia': {
                'id': 'media123',
              },
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockMediaResponse = Response(
        data: {
          'url': 'https://example.com/profile.jpg',
          'keyName': 'profile',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockMentionsResponse);
      when(mockDio.get('/api/media/download-request/media123'))
          .thenAnswer((_) async => mockMediaResponse);

      final result = await repository.fetchMentions();

      expect(result.length, 1);
      expect(result[0].user.profileMedia?.id, 'https://example.com/profile.jpg');
    });

    test('handles profile media fetch failure', () async {
      final repository = _createRepository();

      final mockMentionsResponse = Response(
        data: [
          {
            'id': '1',
            'content': '@testuser test',
            'createdAt': '2024-01-01',
            'likesCount': 0,
            'retweetCount': 0,
            'repliesCount': 0,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'mediaIds': [],
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
              'profileMedia': {
                'id': 'media123',
              },
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockMentionsResponse);
      when(mockDio.get('/api/media/download-request/media123'))
          .thenThrow(Exception('Media not found'));

      final result = await repository.fetchMentions();

      expect(result.length, 1);
      expect(result[0].user.profileMedia?.id, 'media123');
    });

    test('handles profile media non-200 status code', () async {
      final repository = _createRepository();

      final mockMentionsResponse = Response(
        data: [
          {
            'id': '1',
            'content': '@testuser test',
            'createdAt': '2024-01-01',
            'likesCount': 0,
            'retweetCount': 0,
            'repliesCount': 0,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'mediaIds': [],
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
              'profileMedia': {
                'id': 'media123',
              },
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockMediaResponse = Response(
        data: {},
        statusCode: 404,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockMentionsResponse);
      when(mockDio.get('/api/media/download-request/media123'))
          .thenAnswer((_) async => mockMediaResponse);

      final result = await repository.fetchMentions();

      expect(result.length, 1);
      expect(result[0].user.profileMedia?.id, 'media123');
    });

    test('fetches mentions with tweet media', () async {
      final repository = _createRepository();

      final mockMentionsResponse = Response(
        data: [
          {
            'id': '1',
            'content': '@testuser test',
            'createdAt': '2024-01-01',
            'likesCount': 0,
            'retweetCount': 0,
            'repliesCount': 0,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'mediaIds': ['media1', 'media2'],
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockMedia1Response = Response(
        data: {
          'url': 'https://example.com/media1.jpg',
          'keyName': 'media1',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockMedia2Response = Response(
        data: {
          'url': 'https://example.com/media2.jpg',
          'keyName': 'media2',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockMentionsResponse);
      when(mockDio.get('/api/media/download-request/media1'))
          .thenAnswer((_) async => mockMedia1Response);
      when(mockDio.get('/api/media/download-request/media2'))
          .thenAnswer((_) async => mockMedia2Response);

      final result = await repository.fetchMentions();

      expect(result.length, 1);
      expect(result[0].mediaUrls.length, 2);
      expect(result[0].mediaUrls[0].url, 'https://example.com/media1.jpg');
      expect(result[0].mediaUrls[1].url, 'https://example.com/media2.jpg');
    });

    test('handles tweet media fetch failure', () async {
      final repository = _createRepository();

      final mockMentionsResponse = Response(
        data: [
          {
            'id': '1',
            'content': '@testuser test',
            'createdAt': '2024-01-01',
            'likesCount': 0,
            'retweetCount': 0,
            'repliesCount': 0,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'mediaIds': ['media1', 'media2'],
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockMedia1Response = Response(
        data: {
          'url': 'https://example.com/media1.jpg',
          'keyName': 'media1',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockMentionsResponse);
      when(mockDio.get('/api/media/download-request/media1'))
          .thenAnswer((_) async => mockMedia1Response);
      when(mockDio.get('/api/media/download-request/media2'))
          .thenThrow(Exception('Media not found'));

      final result = await repository.fetchMentions();

      expect(result.length, 1);
      expect(result[0].mediaUrls.length, 1);
      expect(result[0].mediaUrls[0].url, 'https://example.com/media1.jpg');
    });

    test('handles tweet parsing error and continues', () async {
      final repository = _createRepository();

      final mockMentionsResponse = Response(
        data: [
          {
            'id': '1',
            // Missing required fields to cause parsing error
          },
          {
            'id': '2',
            'content': '@testuser valid tweet',
            'createdAt': '2024-01-01',
            'likesCount': 0,
            'retweetCount': 0,
            'repliesCount': 0,
            'quotesCount': 0,
            'replyControl': 'everyone',
            'tweetType': 'tweet',
            'mediaIds': [],
            'isLiked': false,
            'isRetweeted': false,
            'isBookmarked': false,
            'user': {
              'id': 'user1',
              'name': 'John',
              'username': 'john',
              'verified': false,
              'protectedAccount': false,
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('/api/tweets/users/testuser/mentioned'))
          .thenAnswer((_) async => mockMentionsResponse);

      final result = await repository.fetchMentions();

      expect(result.length, 1);
      expect(result[0].id, '2');
    });

  });
}
