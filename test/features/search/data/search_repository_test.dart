import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:lite_x/features/search/data/search_repository.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';

import 'search_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;

  SearchRepository createRepository() {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
      ],
    );
    return container.read(searchRepositoryProvider);
  }

  setUp(() {
    mockDio = MockDio();
  });

  // ----------------- searchUsers -----------------
  group('SearchRepository.searchUsers', () {
    test('returns empty result for empty query', () async {
      final repo = createRepository();
      final result = await repo.searchUsers('');
      expect(result.users, isEmpty);
      expect(result.nextCursor, isNull);
      verifyNever(mockDio.get(any));
    });

    test('parses list response correctly', () async {
      final repo = createRepository();
      when(mockDio.get('api/users/search', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: [
                  {'id': '1', 'name': 'John', 'username': 'john', 'verified': true, '_count': {'followers': 10}}
                ],
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchUsers('john');
      expect(result.users.single.userName, 'john');
      expect(result.users.single.followers, 10);
      expect(result.users.single.verified, isTrue);
    });

    test('parses map response with users + cursor', () async {
      final repo = createRepository();
      when(mockDio.get('api/users/search', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'users': [
                    {'id': '1', 'name': 'Alice', 'username': 'alice'}
                  ],
                  'nextCursor': 'cursor123',
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchUsers('alice');
      expect(result.users.length, 1);
      expect(result.nextCursor, 'cursor123');
    });

    test('trims query and sends cursor', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: [], statusCode: 200, requestOptions: RequestOptions(path: '')));

      await repo.searchUsers('  test  ', cursor: 'c1');
      verify(mockDio.get('api/users/search',
              queryParameters: argThat(
                allOf(containsPair('query', 'test'), containsPair('cursor', 'c1')),
                named: 'queryParameters',
              )))
          .called(1);
    });

    test('handles invalid response type', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: 42, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await repo.searchUsers('test');
      expect(result.users, isEmpty);
      expect(result.nextCursor, isNull);
    });

    // New DioException edge cases
    test('throws on DioException with no response', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
        DioException(requestOptions: RequestOptions(path: ''), message: 'Connection timeout'),
      );

      expect(() => repo.searchUsers('test'), throwsA(contains('Connection timeout')));
    });

    
    test('throws on DioException with response map missing message/error', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(statusCode: 503, data: {'someField': 'someValue'}, requestOptions: RequestOptions(path: '')),
        ),
      );

      expect(() => repo.searchUsers('test'), throwsA(contains('Unknown error')));
    });
  });

  // ----------------- searchTweets -----------------
  group('SearchRepository.searchTweets', () {
    test('returns empty result for empty query', () async {
      final repo = createRepository();
      final result = await repo.searchTweets(query: '', tab: SearchTab.TOP);
      expect(result.tweets, isEmpty);
      expect(result.nextCursor, isNull);
    });

    test('parses list tweet response', () async {
      final repo = createRepository();
      when(mockDio.get('api/tweets/search', queryParameters: anyNamed('queryParameters'))).thenAnswer(
        (_) async => Response(
          data: [
            {'id': '1', 'content': 'Tweet', 'authorName': 'Author', 'authorUsername': 'author', 'createdAt': '2024-01-01T00:00:00Z'}
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repo.searchTweets(query: 'flutter', tab: SearchTab.TOP);
      expect(result.tweets.single.id, '1');
    });

    test('maps tabs and request parameters correctly', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: [], statusCode: 200, requestOptions: RequestOptions(path: '')));

      await repo.searchTweets(query: 'test', tab: SearchTab.LATEST, cursor: 'c1', limit: 50);

      verify(mockDio.get('api/tweets/search',
              queryParameters: argThat(
                allOf(containsPair('searchTab', 'LATEST'), containsPair('cursor', 'c1'), containsPair('limit', 50)),
                named: 'queryParameters',
              )))
          .called(1);
    });

    test('parses map response with data + cursor', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'data': [
                    {'id': '2', 'content': 'Tweet', 'authorName': 'A', 'authorUsername': 'a', 'createdAt': '2024-01-01T00:00:00Z'}
                  ],
                  'nextCursor': 'next123',
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchTweets(query: 'test', tab: SearchTab.TOP);
      expect(result.tweets.length, 1);
      expect(result.nextCursor, 'next123');
    });

    test('handles invalid response type', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: 'invalid', statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await repo.searchTweets(query: 'flutter', tab: SearchTab.TOP);
      expect(result.tweets, isEmpty);
      expect(result.nextCursor, isNull);
    });

    test('throws on DioException', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: ''), message: 'Network error'));

      expect(() => repo.searchTweets(query: 'test', tab: SearchTab.TOP), throwsA(contains('Network error')));
    });

    test('throws on DioException with string response', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(statusCode: 400, data: 'Bad request', requestOptions: RequestOptions(path: '')),
        ),
      );

      expect(() => repo.searchTweets(query: 'test', tab: SearchTab.TOP), throwsA(contains('Bad request')));
    });
  });

  // ----------------- SearchSuggestionUser.fromJson -----------------
  group('SearchSuggestionUser.fromJson', () {
    test('parses full json correctly', () {
      final user = SearchSuggestionUser.fromJson({
        'id': '1',
        'name': 'John',
        'username': 'john',
        'bio': 'bio',
        'verified': true,
        'isFollowing': true,
        '_count': {'followers': 100},
        'profileMedia': {'id': 'avatar'},
      });

      expect(user.userName, 'john');
      expect(user.followers, 100);
      expect(user.avatarUrl, 'avatar');
      expect(user.verified, isTrue);
    });

    test('handles missing optional fields', () {
      final user = SearchSuggestionUser.fromJson({'id': '1', 'name': 'John', 'username': 'john'});
      expect(user.followers, 0);
      expect(user.bio, isNull);
      expect(user.verified, isFalse);
    });

    test('handles profileMedia as string + followers as double + null optional fields', () {
      final user = SearchSuggestionUser.fromJson({
        'id': '1',
        'name': 'John',
        'username': 'john',
        'profileMedia': 'media123',
        '_count': {'followers': 42.5},
        'bio': null,
        'verified': null,
        'isFollowing': null,
        'isFollower': null,
      });

      expect(user.avatarUrl, 'media123');
      expect(user.followers, 42);
      expect(user.bio, isNull);
      expect(user.verified, isFalse);
      expect(user.isFollowing, isFalse);
      expect(user.isFollower, isFalse);
    });

    test('handles empty strings', () {
      final user = SearchSuggestionUser.fromJson({'id': '', 'name': '', 'username': ''});
      expect(user.id, '');
      expect(user.name, '');
      expect(user.userName, '');
    });
  });

  // ----------------- Additional coverage tests -----------------
  group('SearchRepository.searchUsers - additional coverage', () {
    test('parses map response with items field', () async {
      final repo = createRepository();
      when(mockDio.get('api/users/search', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'items': [
                    {'id': '1', 'name': 'Bob', 'username': 'bob'}
                  ],
                  'nextCursor': 'cursor456',
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchUsers('bob');
      expect(result.users.length, 1);
      expect(result.users.single.userName, 'bob');
      expect(result.nextCursor, 'cursor456');
    });

    test('handles map response without users/data/items fields', () async {
      final repo = createRepository();
      when(mockDio.get('api/users/search', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'someOtherField': 'value',
                  'nextCursor': null,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchUsers('test');
      expect(result.users, isEmpty);
      expect(result.nextCursor, isNull);
    });
  });

  group('SearchRepository.searchTweets - additional coverage', () {
    test('handles PEOPLE tab correctly', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(data: [], statusCode: 200, requestOptions: RequestOptions(path: '')));

      await repo.searchTweets(query: 'test', tab: SearchTab.PEOPLE);

      verify(mockDio.get('api/tweets/search',
              queryParameters: argThat(
                containsPair('searchTab', 'TOP'),
                named: 'queryParameters',
              )))
          .called(1);
    });

    test('parses map response with items field', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'items': [
                    {'id': '3', 'content': 'Tweet3', 'authorName': 'C', 'authorUsername': 'c', 'createdAt': '2024-01-01T00:00:00Z'}
                  ],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchTweets(query: 'test', tab: SearchTab.TOP);
      expect(result.tweets.length, 1);
      expect(result.tweets.single.id, '3');
    });

    test('parses map response with results field', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'results': [
                    {'id': '4', 'content': 'Tweet4', 'authorName': 'D', 'authorUsername': 'd', 'createdAt': '2024-01-01T00:00:00Z'}
                  ],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchTweets(query: 'test', tab: SearchTab.TOP);
      expect(result.tweets.length, 1);
      expect(result.tweets.single.id, '4');
    });

    test('parses map response with tweets field', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'tweets': [
                    {'id': '5', 'content': 'Tweet5', 'authorName': 'E', 'authorUsername': 'e', 'createdAt': '2024-01-01T00:00:00Z'}
                  ],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await repo.searchTweets(query: 'test', tab: SearchTab.TOP);
      expect(result.tweets.length, 1);
      expect(result.tweets.single.id, '5');
    });
  });

  group('SearchRepository._handleError - additional coverage', () {
    test('throws on DioException with response map containing message field', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 400,
            data: {'message': 'Custom error message'},
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(() => repo.searchUsers('test'), throwsA(contains('Custom error message')));
    });

    test('throws on DioException with response map containing error field', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            data: {'error': 'Internal server error'},
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(() => repo.searchUsers('test'), throwsA(contains('Internal server error')));
    });

    test('handles DioException with null message', () async {
      final repo = createRepository();
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: null,
        ),
      );

      expect(() => repo.searchUsers('test'), throwsA(contains('Network error')));
    });
  });
}
