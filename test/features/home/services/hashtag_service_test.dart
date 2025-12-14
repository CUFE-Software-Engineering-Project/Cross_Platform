import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/services/hashtag_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'hashtag_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late HashtagService hashtagService;

  setUp(() {
    mockDio = MockDio();
    hashtagService = HashtagService(mockDio);
  });

  group('HashtagService Tests', () {
    group('fetchTrendingHashtags', () {
      test('returns list of hashtags from array response', () async {
        final responseData = [
          {'hashtag': 'flutter', 'tweetCount': 100},
          {'hashtag': 'dart', 'tweetCount': 50},
        ];

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result.length, 2);
        expect(result[0].hashtag, 'flutter');
        expect(result[0].tweetCount, 100);
        expect(result[1].hashtag, 'dart');
        expect(result[1].tweetCount, 50);
      });

      test('returns list of hashtags from object with trends array', () async {
        final responseData = {
          'trends': [
            {'hashtag': 'flutter', 'tweetCount': 100},
            {'hashtag': 'dart', 'tweetCount': 50},
          ],
        };

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result.length, 2);
        expect(result[0].hashtag, 'flutter');
        expect(result[1].hashtag, 'dart');
      });

      test('handles alternative field names (title, name)', () async {
        final responseData = [
          {'title': 'flutter', 'postCount': 100},
          {'name': 'dart', 'count': 50},
        ];

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result.length, 2);
        expect(result[0].hashtag, 'flutter');
        expect(result[0].tweetCount, 100);
        expect(result[1].hashtag, 'dart');
        expect(result[1].tweetCount, 50);
      });

      test('removes # prefix from hashtag text', () async {
        final responseData = [
          {'hashtag': '#flutter', 'tweetCount': 100},
        ];

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result[0].hashtag, 'flutter');
      });

      test('passes query parameter correctly', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '10', 'q': 'flutter'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          ),
        );

        await hashtagService.fetchTrendingHashtags(query: 'flutter');

        verify(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '10', 'q': 'flutter'},
          ),
        ).called(1);
      });

      test('passes limit parameter correctly', () async {
        when(
          mockDio.get('api/hashtags/trends', queryParameters: {'limit': '5'}),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          ),
        );

        await hashtagService.fetchTrendingHashtags(limit: 5);

        verify(
          mockDio.get('api/hashtags/trends', queryParameters: {'limit': '5'}),
        ).called(1);
      });

      test('passes category parameter correctly', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '10', 'category': 'sports'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          ),
        );

        await hashtagService.fetchTrendingHashtags(category: 'sports');

        verify(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '10', 'category': 'sports'},
          ),
        ).called(1);
      });

      test('ignores limit when set to 0 or negative', () async {
        when(
          mockDio.get('api/hashtags/trends', queryParameters: null),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          ),
        );

        await hashtagService.fetchTrendingHashtags(limit: 0);

        verify(
          mockDio.get('api/hashtags/trends', queryParameters: null),
        ).called(1);
      });

      test('returns empty list on DioException', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            response: Response(
              requestOptions: RequestOptions(path: 'api/hashtags/trends'),
              statusCode: 500,
            ),
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result, isEmpty);
      });

      test('returns empty list on timeout', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 11));
          return Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          );
        });

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result, isEmpty);
      });

      test('returns empty list when response is invalid', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: 'invalid',
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result, isEmpty);
      });

      test('filters out null items from response', () async {
        final responseData = [
          {'hashtag': 'flutter', 'tweetCount': 100},
          null,
          {'hashtag': 'dart', 'tweetCount': 50},
          'invalid',
        ];

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result.length, 2);
        expect(result[0].hashtag, 'flutter');
        expect(result[1].hashtag, 'dart');
      });

      test('handles zero tweet count', () async {
        final responseData = [
          {'hashtag': 'flutter', 'tweetCount': 0},
        ];

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.fetchTrendingHashtags();

        expect(result[0].tweetCount, 0);
      });
    });

    group('searchHashtags', () {
      test('returns empty list when query is empty', () async {
        final result = await hashtagService.searchHashtags('');

        expect(result, isEmpty);
        verifyNever(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        );
      });

      test('removes # prefix from query', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '5', 'q': 'flutter'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          ),
        );

        await hashtagService.searchHashtags('#flutter');

        verify(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '5', 'q': 'flutter'},
          ),
        ).called(1);
      });

      test('limits results to 5', () async {
        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '5', 'q': 'flutter'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: [],
            statusCode: 200,
          ),
        );

        await hashtagService.searchHashtags('flutter');

        verify(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: {'limit': '5', 'q': 'flutter'},
          ),
        ).called(1);
      });

      test('returns search results', () async {
        final responseData = [
          {'hashtag': 'flutter', 'tweetCount': 100},
          {'hashtag': 'flutterdevelopment', 'tweetCount': 50},
        ];

        when(
          mockDio.get(
            'api/hashtags/trends',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'api/hashtags/trends'),
            data: responseData,
            statusCode: 200,
          ),
        );

        final result = await hashtagService.searchHashtags('flutter');

        expect(result.length, 2);
        expect(result[0].hashtag, 'flutter');
        expect(result[1].hashtag, 'flutterdevelopment');
      });
    });
  });

  group('HashtagSuggestion Tests', () {
    test('fromJson creates HashtagSuggestion correctly', () {
      final json = {'hashtag': 'flutter', 'tweetCount': 100};

      final result = HashtagSuggestion.fromJson(json);

      expect(result.hashtag, 'flutter');
      expect(result.tweetCount, 100);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final result = HashtagSuggestion.fromJson(json);

      expect(result.hashtag, '');
      expect(result.tweetCount, 0);
    });
  });
}
