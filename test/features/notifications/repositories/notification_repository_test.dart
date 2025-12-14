import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/notifications/repositories/notification_repository.dart';
import 'package:lite_x/features/notifications/notification_model.dart';
import 'package:lite_x/features/notifications/notification_provider.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';

import 'notification_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('NotificationRepository', () {
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
    });

    NotificationRepository _createRepository() {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(mockDio),
        ],
      );
      return container.read(notificationRepositoryProvider);
    }

    test('fetches notifications from List response', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'Test',
            'body': 'Test Body',
            'isRead': false,
            'createdAt': '2024-01-01',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      final result = await repository.fetchNotifications();

      expect(result, isA<List<NotificationItem>>());
      expect(result.length, 1);
      expect(result[0].title, 'Test');
    });

    test('fetches notifications from Map response', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {
          'notifications': [
            {
              'id': '1',
              'title': 'Test',
              'body': 'Test Body',
              'isRead': false,
              'createdAt': '2024-01-01',
              'actor': {
                'name': 'John',
                'username': 'john',
                'profileMediaId': '',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      final result = await repository.fetchNotifications();

      expect(result, isA<List<NotificationItem>>());
      expect(result.length, 1);
    });

    test('throws exception on failed response', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: [],
        statusCode: 500,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      expect(
        () => repository.fetchNotifications(),
        throwsException,
      );
    });

    test('handles empty notification list', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: [],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      final result = await repository.fetchNotifications();

      expect(result, isEmpty);
    });

    test('fetches notifications with Map response using "data" key', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {
          'data': [
            {
              'id': '1',
              'title': 'Test',
              'body': 'Test Body',
              'isRead': false,
              'createdAt': '2024-01-01',
              'actor': {
                'name': 'John',
                'username': 'john',
                'profileMediaId': '',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].title, 'Test');
    });

    test('fetches notifications with Map response using "items" key', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {
          'items': [
            {
              'id': '1',
              'title': 'Test',
              'body': 'Test Body',
              'isRead': false,
              'createdAt': '2024-01-01',
              'actor': {
                'name': 'John',
                'username': 'john',
                'profileMediaId': '',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
    });

    

    test('throws exception when Map response has no list', () async {
      final repository = _createRepository();

      final mockResponse = Response(
        data: {'key': 'value', 'another': 'data'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      expect(
        () => repository.fetchNotifications(),
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

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockResponse);

      expect(
        () => repository.fetchNotifications(),
        throwsException,
      );
    });

    test('fetches notification with profile media', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'Test',
            'body': 'Test Body',
            'isRead': false,
            'createdAt': '2024-01-01',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': 'media123',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockMediaResponse = Response(
        data: {
          'url': 'https://example.com/avatar.jpg',
          'keyName': 'avatar',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/media/download-request/media123'))
          .thenAnswer((_) async => mockMediaResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].mediaUrl, 'https://example.com/avatar.jpg');
    });

    

    test('fetches notification with tweet details', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'LIKE',
            'body': 'Someone liked your tweet',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {
          'id': 'tweet123',
          'content': 'Tweet content',
          'createdAt': '2024-01-01',
          'likesCount': 10,
          'retweetCount': 5,
          'repliesCount': 3,
          'isLiked': true,
          'isRetweeted': false,
          'isBookmarked': true,
          'user': {
            'id': 'user1',
            'name': 'John',
            'username': 'john',
            'verified': false,
            'protectedAccount': false,
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].likesCount, 10);
      expect(result[0].repostsCount, 5);
      expect(result[0].repliesCount, 3);
      expect(result[0].isLiked, true);
      expect(result[0].isRetweeted, false);
      expect(result[0].isBookmarked, true);
      expect(result[0].tweet, isNotNull);
    });

    test('handles tweet fetch errors gracefully', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'LIKE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenThrow(Exception('Tweet not found'));

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].likesCount, 0);
      expect(result[0].tweet, isNull);
    });

    test('fetches QUOTE notification with parent tweet', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'QUOTE',
            'body': 'Someone quoted your tweet',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {
          'id': 'tweet123',
          'content': 'Quote tweet content',
          'createdAt': '2024-01-01',
          'likesCount': 5,
          'retweetCount': 2,
          'repliesCount': 1,
          'parentId': 'parent123',
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
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockParentTweetResponse = Response(
        data: {
          'id': 'parent123',
          'content': 'Original tweet content',
          'createdAt': '2024-01-01',
          'likesCount': 10,
          'retweetCount': 3,
          'repliesCount': 2,
          'isLiked': false,
          'isRetweeted': false,
          'isBookmarked': false,
          'user': {
            'id': 'user2',
            'name': 'Jane',
            'username': 'jane',
            'verified': true,
            'protectedAccount': false,
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);
      when(mockDio.get('api/tweets/parent123')).thenAnswer((_) async => mockParentTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].quotedAuthor, 'Jane');
      expect(result[0].quotedContent, 'Original tweet content');
    });

    test('handles parent tweet fetch errors for QUOTE notification', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'QUOTE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {
          'id': 'tweet123',
          'content': 'Quote',
          'createdAt': '2024-01-01',
          'likesCount': 5,
          'retweetCount': 2,
          'repliesCount': 1,
          'parentId': 'parent123',
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
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);
      when(mockDio.get('api/tweets/parent123')).thenThrow(Exception('Parent tweet not found'));

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].quotedAuthor, isNull);
      expect(result[0].quotedContent, isNull);
    });

    test('skips media fetch when profileMediaId is "null"', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'Test',
            'body': 'Test Body',
            'isRead': false,
            'createdAt': '2024-01-01',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': 'null',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].mediaUrl, isEmpty);
      verifyNever(mockDio.get(argThat(startsWith('api/media/download-request/'))));
    });

    test('skips tweet fetch when tweetId is null', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'FOLLOW',
            'body': 'Someone followed you',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': null,
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].tweet, isNull);
      verifyNever(mockDio.get(argThat(startsWith('api/tweets/'))));
    });

    

    test('handles media response with non-200 status code', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'Test',
            'body': 'Test Body',
            'isRead': false,
            'createdAt': '2024-01-01',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': 'media123',
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

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/media/download-request/media123'))
          .thenAnswer((_) async => mockMediaResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].mediaUrl, isEmpty);
    });

    test('handles tweet response with non-200 status code', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'LIKE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {},
        statusCode: 404,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].tweet, isNull);
    });

    test('handles tweet response with non-Map data', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'LIKE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: [],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].tweet, isNull);
    });

    test('handles parent tweet response with non-200 status code', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'QUOTE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {
          'id': 'tweet123',
          'content': 'Quote',
          'createdAt': '2024-01-01',
          'likesCount': 5,
          'retweetCount': 2,
          'repliesCount': 1,
          'parentId': 'parent123',
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
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockParentTweetResponse = Response(
        data: {},
        statusCode: 404,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);
      when(mockDio.get('api/tweets/parent123')).thenAnswer((_) async => mockParentTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].quotedAuthor, isNull);
    });

    

    test('does not fetch parent tweet for QUOTE with empty parentId', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'QUOTE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {
          'id': 'tweet123',
          'content': 'Quote',
          'createdAt': '2024-01-01',
          'likesCount': 5,
          'retweetCount': 2,
          'repliesCount': 1,
          'parentId': '',
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
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].quotedAuthor, isNull);
      verify(mockDio.get('api/tweets/tweet123')).called(1);
      verifyNever(mockDio.get(argThat(contains('parent'))));
    });

    test('does not fetch parent tweet for non-QUOTE notification', () async {
      final repository = _createRepository();

      final mockNotificationResponse = Response(
        data: [
          {
            'id': '1',
            'title': 'LIKE',
            'body': 'Test',
            'isRead': false,
            'createdAt': '2024-01-01',
            'tweetId': 'tweet123',
            'actor': {
              'name': 'John',
              'username': 'john',
              'profileMediaId': '',
            },
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final mockTweetResponse = Response(
        data: {
          'id': 'tweet123',
          'content': 'Tweet',
          'createdAt': '2024-01-01',
          'likesCount': 5,
          'retweetCount': 2,
          'repliesCount': 1,
          'parentId': 'parent123',
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
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.get('api/notifications')).thenAnswer((_) async => mockNotificationResponse);
      when(mockDio.get('api/tweets/tweet123')).thenAnswer((_) async => mockTweetResponse);

      final result = await repository.fetchNotifications();

      expect(result.length, 1);
      expect(result[0].quotedAuthor, isNull);
      verify(mockDio.get('api/tweets/tweet123')).called(1);
      verifyNever(mockDio.get('api/tweets/parent123'));
    });
  });
}
