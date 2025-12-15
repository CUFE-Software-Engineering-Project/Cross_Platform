import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/search/data/search_repository.dart';
import 'package:lite_x/features/search/providers/search_providers.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';

import 'search_providers_test.mocks.dart';

@GenerateMocks([SearchRepository])
void main() {
  group('SearchParams', () {
    test('two instances with same values are equal', () {
      final params1 = SearchParams(query: 'flutter', tab: SearchTab.TOP);
      final params2 = SearchParams(query: 'flutter', tab: SearchTab.TOP);
      expect(params1, equals(params2));
    });

    test('two instances with different queries are not equal', () {
      final params1 = SearchParams(query: 'flutter', tab: SearchTab.TOP);
      final params2 = SearchParams(query: 'dart', tab: SearchTab.TOP);
      expect(params1, isNot(equals(params2)));
    });

    test('hashCode is consistent with equality', () {
      final params1 = SearchParams(query: 'flutter', tab: SearchTab.TOP);
      final params2 = SearchParams(query: 'flutter', tab: SearchTab.TOP);
      expect(params1.hashCode, equals(params2.hashCode));
    });
  });

  group('SearchResultsState', () {
    test('initial state has correct defaults', () {
      final state = SearchResultsState.initial();
      expect(state.tweets, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.error, isNull);
      expect(state.nextCursor, isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      final state = SearchResultsState.initial();
      final tweets = [
        TweetModel(
          id: '1',
          content: 'Test',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];

      final updated = state.copyWith(
        tweets: tweets,
        isLoading: true,
        error: 'Test error',
      );

      expect(updated.tweets, equals(tweets));
      expect(updated.isLoading, isTrue);
      expect(updated.error, equals('Test error'));
      expect(updated.isLoadingMore, isFalse);
    });

  });

  group('SearchResultsNotifier', () {
    late MockSearchRepository mockRepository;

    setUp(() {
      mockRepository = MockSearchRepository();
    });

    test('loads tweets successfully on initialization', () async {
      final tweets = [
        TweetModel(
          id: '1',
          content: 'Test tweet',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];
      final params = SearchParams(query: 'flutter', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: tweets, nextCursor: 'cursor1'));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      expect(notifier.state.tweets, equals(tweets));
      expect(notifier.state.nextCursor, equals('cursor1'));
      expect(notifier.state.isLoading, isFalse);
    });

    test('handles empty query', () async {
      final params = SearchParams(query: '', tab: SearchTab.TOP);
      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      expect(notifier.state.tweets, isEmpty);
      expect(notifier.state.nextCursor, isNull);
      verifyNever(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      ));
    });

    test('handles error on initial load', () async {
      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenThrow(Exception('Network error'));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      expect(notifier.state.error, contains('Exception: Network error'));
      expect(notifier.state.isLoading, isFalse);
    });

    test('refresh reloads tweets', () async {
      final tweets = [
        TweetModel(
          id: '1',
          content: 'Test',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];
      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: tweets, nextCursor: null));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await notifier.refresh();

      expect(notifier.state.tweets, equals(tweets));
      verify(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).called(2);
    });

    test('loadNextPage appends tweets', () async {
      final page1Tweets = [
        TweetModel(
          id: '1',
          content: 'Tweet 1',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];
      final page2Tweets = [
        TweetModel(
          id: '2',
          content: 'Tweet 2',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];

      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((invocation) {
        final cursor = invocation.namedArguments[Symbol('cursor')];
        if (cursor == null) {
          return Future.value(
              TweetSearchPage(tweets: page1Tweets, nextCursor: 'cursor1'));
        } else {
          return Future.value(
              TweetSearchPage(tweets: page2Tweets, nextCursor: null));
        }
      });

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);
      await notifier.loadNextPage();

      expect(notifier.state.tweets, hasLength(2));
      expect(notifier.state.tweets[0].id, equals('1'));
      expect(notifier.state.tweets[1].id, equals('2'));
    });

    test('loadNextPage does nothing when already loading', () async {
      final tweets = [
        TweetModel(
          id: '1',
          content: 'Test',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];
      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: tweets, nextCursor: 'cursor1'));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      // Manually set isLoadingMore to true
      notifier.state = notifier.state.copyWith(isLoadingMore: true);
      
      await notifier.loadNextPage();

      // Should not call searchTweets again
      verify(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).called(1); // Only the initial call
    });

    test('loadNextPage handles error', () async {
      final tweets = [
        TweetModel(
          id: '1',
          content: 'Test',
          authorName: 'Test Author',
          authorUsername: 'testauthor',
          authorAvatar: 'avatar.jpg',
          createdAt: DateTime.now(),
        ),
      ];
      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((invocation) {
        final cursor = invocation.namedArguments[Symbol('cursor')];
        if (cursor == null) {
          return Future.value(
              TweetSearchPage(tweets: tweets, nextCursor: 'cursor1'));
        } else {
          throw Exception('Load more error');
        }
      });

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);
      await notifier.loadNextPage();

      expect(notifier.state.error, contains('Exception: Load more error'));
      expect(notifier.state.isLoadingMore, isFalse);
      // Original tweets should still be there
      expect(notifier.state.tweets, hasLength(1));
    });

    test('toggleLike updates tweet optimistically', () async {
      final tweet = TweetModel(
        id: '1',
        content: 'Test',
        authorName: 'Test Author',
        authorUsername: 'testauthor',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
        isLiked: false,
        likes: 10,
      );

      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: [tweet], nextCursor: null));

      when(mockRepository.toggleLike('1', false))
          .thenAnswer((_) async => tweet.copyWith(isLiked: true, likes: 11));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      expect(notifier.state.tweets[0].isLiked, isFalse);
      await notifier.toggleLike('1');

      expect(notifier.state.tweets[0].isLiked, isTrue);
      expect(notifier.state.tweets[0].likes, equals(11));
    });

    test('toggleLike does nothing for non-existent tweet', () async {
      final tweet = TweetModel(
        id: '1',
        content: 'Test',
        authorName: 'Test Author',
        authorUsername: 'testauthor',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
      );

      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: [tweet], nextCursor: null));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      await notifier.toggleLike('non-existent-id');

      // Should not call toggleLike on repository
      verifyNever(mockRepository.toggleLike(any, any));
    });

    test('toggleLike keeps optimistic update on error', () async {
      final tweet = TweetModel(
        id: '1',
        content: 'Test',
        authorName: 'Test Author',
        authorUsername: 'testauthor',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
        isLiked: false,
        likes: 10,
      );

      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: [tweet], nextCursor: null));

      when(mockRepository.toggleLike('1', false))
          .thenThrow(Exception('Like failed'));

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      await notifier.toggleLike('1');

      // Optimistic update should remain even on error
      expect(notifier.state.tweets[0].isLiked, isTrue);
      expect(notifier.state.tweets[0].likes, equals(11));
    });

    test('toggleLike handles server tweet not found in current state', () async {
      final tweet = TweetModel(
        id: '1',
        content: 'Test',
        authorName: 'Test Author',
        authorUsername: 'testauthor',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
        isLiked: false,
        likes: 10,
      );

      final params = SearchParams(query: 'test', tab: SearchTab.TOP);

      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async =>
          TweetSearchPage(tweets: [tweet], nextCursor: null));

      // Return a tweet with different ID than what's in state
      final serverTweet = TweetModel(
        id: '999',
        content: 'Different tweet',
        authorName: 'Different Author',
        authorUsername: 'differentauthor',
        authorAvatar: 'avatar2.jpg',
        createdAt: DateTime.now(),
        isLiked: true,
        likes: 50,
      );

      when(mockRepository.toggleLike('1', false))
          .thenAnswer((_) async => serverTweet);

      final notifier = SearchResultsNotifier(mockRepository, params);
      await Future.delayed(Duration.zero);

      await notifier.toggleLike('1');

      // Should keep optimistic update since serverIndex is -1
      expect(notifier.state.tweets[0].id, '1');
      expect(notifier.state.tweets[0].isLiked, isTrue);
      expect(notifier.state.tweets[0].likes, equals(11));
    });
  });

  group('SearchHistoryNotifier', () {
    test('initial state is empty', () {
      final notifier = SearchHistoryNotifier();
      expect(notifier.state, isEmpty);
    });

    test('add inserts query at beginning', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('flutter');
      expect(notifier.state, equals(['flutter']));
    });

    test('add removes duplicate before inserting', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('flutter');
      notifier.add('dart');
      notifier.add('flutter');
      expect(notifier.state, equals(['flutter', 'dart']));
    });

    test('add limits history to 20 items', () {
      final notifier = SearchHistoryNotifier();
      for (int i = 0; i < 25; i++) {
        notifier.add('query$i');
      }
      expect(notifier.state, hasLength(20));
      expect(notifier.state[0], equals('query24'));
    });

    test('remove deletes query from history', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('flutter');
      notifier.add('dart');
      notifier.remove('flutter');
      expect(notifier.state, equals(['dart']));
    });

    test('clear removes all history', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('flutter');
      notifier.add('dart');
      notifier.clear();
      expect(notifier.state, isEmpty);
    });

    test('add ignores case when checking for duplicates', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('Flutter');
      notifier.add('flutter');
      expect(notifier.state, hasLength(1));
    });

    test('preserves original case of most recent query', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('flutter');
      notifier.add('Flutter');
      expect(notifier.state[0], equals('Flutter'));
    });

    test('add ignores empty string', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('');
      expect(notifier.state, isEmpty);
    });

    test('add trims query before adding', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('  flutter  ');
      expect(notifier.state[0], equals('flutter'));
    });

    test('remove is case insensitive', () {
      final notifier = SearchHistoryNotifier();
      notifier.add('Flutter');
      notifier.add('Dart');
      notifier.remove('flutter'); // lowercase
      expect(notifier.state, equals(['Dart']));
    });
  });

  group('suggestionsProvider', () {
    late MockSearchRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockSearchRepository();
      container = ProviderContainer(
        overrides: [
          searchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns empty list for empty query', () async {
      when(mockRepository.searchUsers(
        any,
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const UserSearchPage(users: [], nextCursor: null));

      final result = await container.read(suggestionsProvider('').future);

      expect(result, isEmpty);
    });

    test('returns users for valid query', () async {
      final users = [
        const SearchSuggestionUser(
          id: '1',
          name: 'John Doe',
          userName: 'johndoe',
          bio: 'Developer',
          avatarUrl: null,
          followers: 100,
          verified: true,
          isFollowing: false,
          isFollower: false,
        ),
      ];

      when(mockRepository.searchUsers(
        any,
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => UserSearchPage(users: users, nextCursor: null));

      final result = await container.read(suggestionsProvider('john').future);

      expect(result, hasLength(1));
      expect(result[0].name, equals('John Doe'));
    });

    test('passes correct limit to repository', () async {
      when(mockRepository.searchUsers(
        any,
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const UserSearchPage(users: [], nextCursor: null));

      await container.read(suggestionsProvider('test').future);

      verify(mockRepository.searchUsers(
        any,
        cursor: anyNamed('cursor'),
        limit: 20,
      )).called(1);
    });

    test('trims query before passing to repository', () async {
      when(mockRepository.searchUsers(
        any,
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const UserSearchPage(users: [], nextCursor: null));

      await container.read(suggestionsProvider('  test  ').future);

      verify(mockRepository.searchUsers(
        'test',
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).called(1);
    });

    test('returns multiple users', () async {
      final users = [
        const SearchSuggestionUser(
          id: '1',
          name: 'User 1',
          userName: 'user1',
          bio: null,
          avatarUrl: null,
          followers: 100,
          verified: false,
          isFollowing: false,
          isFollower: false,
        ),
        const SearchSuggestionUser(
          id: '2',
          name: 'User 2',
          userName: 'user2',
          bio: null,
          avatarUrl: null,
          followers: 200,
          verified: true,
          isFollowing: true,
          isFollower: false,
        ),
      ];

      when(mockRepository.searchUsers(
        any,
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => UserSearchPage(users: users, nextCursor: null));

      final result = await container.read(suggestionsProvider('user').future);

      expect(result, hasLength(2));
      expect(result[0].id, equals('1'));
      expect(result[1].id, equals('2'));
    });
  });

  group('Provider integration tests', () {
    late MockSearchRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockSearchRepository();
      container = ProviderContainer(
        overrides: [
          searchRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('searchResultsProvider creates notifier correctly', () async {
      final params = SearchParams(query: 'test', tab: SearchTab.TOP);
      when(mockRepository.searchTweets(
        query: anyNamed('query'),
        tab: anyNamed('tab'),
        peopleFilter: anyNamed('peopleFilter'),
        cursor: anyNamed('cursor'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => const TweetSearchPage(tweets: [], nextCursor: null));

      final notifier = container.read(searchResultsProvider(params).notifier);
      expect(notifier, isA<SearchResultsNotifier>());
    });
  });
}
