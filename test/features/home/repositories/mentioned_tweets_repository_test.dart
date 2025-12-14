import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/repositories/mentioned_tweets_repository.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mentioned_tweets_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late MentionedTweetsRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = MentionedTweetsRepository(mockDio);
  });

  group('MentionedTweetsRepository Tests', () {
    final testDate = DateTime(2024, 1, 1);

    group('fetchMentionedTweets', () {
      test('fetches mentioned tweets successfully', () async {
        final responseData = {
          'data': [
            {
              'id': '123',
              'content': 'Test mention @testuser',
              'user': {'name': 'Test User', 'username': 'mentioner'},
              'createdAt': testDate.toIso8601String(),
            },
          ],
          'cursor': 'next_cursor_123',
        };

        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect(result['tweets'], isA<List<TweetModel>>());
        expect((result['tweets'] as List).length, 1);
        expect(result['nextCursor'], 'next_cursor_123');
        expect(result['hasMore'], true);
      });

      test('removes @ from username', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        await repository.fetchMentionedTweets(username: '@testuser');

        verify(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20'},
          ),
        ).called(1);
      });

      test('passes cursor parameter for pagination', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20', 'cursor': 'cursor_123'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        await repository.fetchMentionedTweets(
          username: 'testuser',
          cursor: 'cursor_123',
        );

        verify(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20', 'cursor': 'cursor_123'},
          ),
        ).called(1);
      });

      test('respects custom limit parameter', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '50'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        await repository.fetchMentionedTweets(username: 'testuser', limit: 50);

        verify(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '50'},
          ),
        ).called(1);
      });

      test('handles empty response', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect((result['tweets'] as List).isEmpty, true);
        expect(result['nextCursor'], isNull);
        expect(result['hasMore'], false);
      });

      test('handles 404 response', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {},
            statusCode: 404,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect((result['tweets'] as List).isEmpty, true);
        expect(result['hasMore'], false);
      });

      test('handles DioException with 404', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: 'api/tweets/users/testuser/mentioned',
              ),
              statusCode: 404,
            ),
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect((result['tweets'] as List).isEmpty, true);
        expect(result['hasMore'], false);
      });

      test('throws exception on network error', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: 'api/tweets/users/testuser/mentioned',
              ),
              statusCode: 500,
            ),
          ),
        );

        expect(
          () => repository.fetchMentionedTweets(username: 'testuser'),
          throwsA(isA<Exception>()),
        );
      });

      test('parses multiple tweets correctly', () async {
        final responseData = {
          'data': [
            {
              'id': '1',
              'content': 'First mention',
              'user': {'name': 'User 1', 'username': 'user1'},
              'createdAt': testDate.toIso8601String(),
            },
            {
              'id': '2',
              'content': 'Second mention',
              'user': {'name': 'User 2', 'username': 'user2'},
              'createdAt': testDate.toIso8601String(),
            },
          ],
        };

        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        final tweets = result['tweets'] as List<TweetModel>;
        expect(tweets.length, 2);
        expect(tweets[0].id, '1');
        expect(tweets[1].id, '2');
      });

      test('hasMore is false when nextCursor is null', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {
              'data': [
                {
                  'id': '1',
                  'content': 'Test',
                  'user': {'name': 'User', 'username': 'user'},
                  'createdAt': testDate.toIso8601String(),
                },
              ],
              'cursor': null,
            },
            statusCode: 200,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect(result['hasMore'], false);
      });

      test('hasMore is false when nextCursor is empty string', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {
              'data': [
                {
                  'id': '1',
                  'content': 'Test',
                  'user': {'name': 'User', 'username': 'user'},
                  'createdAt': testDate.toIso8601String(),
                },
              ],
              'cursor': '',
            },
            statusCode: 200,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect(result['hasMore'], false);
      });

      test('does not include cursor in query when cursor is empty', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {'data': []},
            statusCode: 200,
          ),
        );

        await repository.fetchMentionedTweets(username: 'testuser', cursor: '');

        verify(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: {'limit': '20'},
          ),
        ).called(1);
      });

      test('handles non-DioException errors', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(Exception('Generic error'));

        expect(
          () => repository.fetchMentionedTweets(username: 'testuser'),
          throwsA(isA<Exception>()),
        );
      });

      test('handles null data field in response', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {'data': null},
            statusCode: 200,
          ),
        );

        final result = await repository.fetchMentionedTweets(
          username: 'testuser',
        );

        expect((result['tweets'] as List).isEmpty, true);
      });

      test('handles non-200 status codes', () async {
        when(
          mockDio.get(
            'api/tweets/users/testuser/mentioned',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: 'api/tweets/users/testuser/mentioned',
            ),
            data: {},
            statusCode: 403,
          ),
        );

        expect(
          () => repository.fetchMentionedTweets(username: 'testuser'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
