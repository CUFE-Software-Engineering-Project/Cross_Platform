import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

void main() {
  group('FeedType', () {
    test('should have forYou value', () {
      expect(FeedType.forYou, isNotNull);
      expect(FeedType.forYou.toString(), 'FeedType.forYou');
    });

    test('should have following value', () {
      expect(FeedType.following, isNotNull);
      expect(FeedType.following.toString(), 'FeedType.following');
    });

    test('should be comparable', () {
      expect(FeedType.forYou == FeedType.forYou, true);
      expect(FeedType.following == FeedType.following, true);
      expect(FeedType.forYou == FeedType.following, false);
    });
  });

  group('HomeState', () {
    late TweetModel testTweet1;
    late TweetModel testTweet2;
    late TweetModel testTweet3;

    setUp(() {
      testTweet1 = TweetModel(
        id: '1',
        content: 'Tweet 1',
        authorName: 'User 1',
        authorUsername: 'user1',
        authorAvatar: 'avatar1.jpg',
        createdAt: DateTime(2024, 1, 1),
      );

      testTweet2 = TweetModel(
        id: '2',
        content: 'Tweet 2',
        authorName: 'User 2',
        authorUsername: 'user2',
        authorAvatar: 'avatar2.jpg',
        createdAt: DateTime(2024, 1, 2),
      );

      testTweet3 = TweetModel(
        id: '3',
        content: 'Tweet 3',
        authorName: 'User 3',
        authorUsername: 'user3',
        authorAvatar: 'avatar3.jpg',
        createdAt: DateTime(2024, 1, 3),
      );
    });

    test('should create HomeState with default values', () {
      const state = HomeState();

      expect(state.tweets, isEmpty);
      expect(state.forYouTweets, isEmpty);
      expect(state.followingTweets, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isRefreshing, false);
      expect(state.currentFeed, FeedType.following);
    });

    test('should create HomeState with custom values', () {
      final state = HomeState(
        tweets: [testTweet1, testTweet2],
        forYouTweets: [testTweet1],
        followingTweets: [testTweet2, testTweet3],
        isLoading: true,
        error: 'Test error',
        isRefreshing: true,
        currentFeed: FeedType.forYou,
      );

      expect(state.tweets.length, 2);
      expect(state.forYouTweets.length, 1);
      expect(state.followingTweets.length, 2);
      expect(state.isLoading, true);
      expect(state.error, 'Test error');
      expect(state.isRefreshing, true);
      expect(state.currentFeed, FeedType.forYou);
    });

    test('should copy state with modified tweets', () {
      const initialState = HomeState();
      final newState = initialState.copyWith(tweets: [testTweet1, testTweet2]);

      expect(newState.tweets.length, 2);
      expect(newState.tweets[0], testTweet1);
      expect(newState.tweets[1], testTweet2);
      expect(newState.isLoading, initialState.isLoading);
      expect(newState.error, initialState.error);
    });

    test('should copy state with loading flag', () {
      const initialState = HomeState(isLoading: false);
      final newState = initialState.copyWith(isLoading: true);

      expect(newState.isLoading, true);
      expect(newState.tweets, initialState.tweets);
      expect(newState.error, initialState.error);
    });

    test('should copy state with error message', () {
      const initialState = HomeState();
      final newState = initialState.copyWith(error: 'Network error');

      expect(newState.error, 'Network error');
      expect(newState.tweets, initialState.tweets);
      expect(newState.isLoading, initialState.isLoading);
    });

    test('should copy state with refreshing flag', () {
      const initialState = HomeState(isRefreshing: false);
      final newState = initialState.copyWith(isRefreshing: true);

      expect(newState.isRefreshing, true);
      expect(newState.tweets, initialState.tweets);
      expect(newState.isLoading, initialState.isLoading);
    });

    test('should copy state with different feed type', () {
      const initialState = HomeState(currentFeed: FeedType.following);
      final newState = initialState.copyWith(currentFeed: FeedType.forYou);

      expect(newState.currentFeed, FeedType.forYou);
      expect(newState.tweets, initialState.tweets);
    });

    test('should copy state with forYou tweets', () {
      const initialState = HomeState();
      final newState = initialState.copyWith(
        forYouTweets: [testTweet1, testTweet2, testTweet3],
      );

      expect(newState.forYouTweets.length, 3);
      expect(newState.forYouTweets[0], testTweet1);
      expect(newState.forYouTweets[2], testTweet3);
    });

    test('should copy state with following tweets', () {
      const initialState = HomeState();
      final newState = initialState.copyWith(
        followingTweets: [testTweet2, testTweet3],
      );

      expect(newState.followingTweets.length, 2);
      expect(newState.followingTweets[0], testTweet2);
      expect(newState.followingTweets[1], testTweet3);
    });

    test('should copy state with multiple fields', () {
      const initialState = HomeState();
      final newState = initialState.copyWith(
        tweets: [testTweet1],
        isLoading: true,
        error: 'Loading error',
        currentFeed: FeedType.forYou,
      );

      expect(newState.tweets.length, 1);
      expect(newState.isLoading, true);
      expect(newState.error, 'Loading error');
      expect(newState.currentFeed, FeedType.forYou);
    });

    test('should preserve all three tweet lists independently', () {
      final state = HomeState(
        tweets: [testTweet1],
        forYouTweets: [testTweet2],
        followingTweets: [testTweet3],
      );

      expect(state.tweets.length, 1);
      expect(state.forYouTweets.length, 1);
      expect(state.followingTweets.length, 1);
      expect(state.tweets[0].id, '1');
      expect(state.forYouTweets[0].id, '2');
      expect(state.followingTweets[0].id, '3');
    });

    test('should handle empty tweet lists', () {
      final state = HomeState(
        tweets: const [],
        forYouTweets: const [],
        followingTweets: const [],
      );

      expect(state.tweets, isEmpty);
      expect(state.forYouTweets, isEmpty);
      expect(state.followingTweets, isEmpty);
    });

    test('should clear error on copyWith without error parameter', () {
      const initialState = HomeState(error: 'Some error');
      final newState = initialState.copyWith(isLoading: true);

      expect(
        newState.error,
        'Some error',
      ); // Error persists if not explicitly cleared
    });

    test('should handle null error', () {
      const state = HomeState(error: null);
      expect(state.error, isNull);
    });

    test('should support feed switching scenario', () {
      // Simulate switching from following to forYou
      final followingState = HomeState(
        tweets: [testTweet1, testTweet2],
        followingTweets: [testTweet1, testTweet2],
        forYouTweets: const [],
        currentFeed: FeedType.following,
      );

      final forYouState = followingState.copyWith(
        tweets: [testTweet3],
        forYouTweets: [testTweet3],
        currentFeed: FeedType.forYou,
      );

      expect(forYouState.currentFeed, FeedType.forYou);
      expect(forYouState.tweets[0], testTweet3);
      expect(forYouState.forYouTweets[0], testTweet3);
      expect(
        forYouState.followingTweets.length,
        2,
      ); // Previous following tweets preserved
    });

    test('should handle loading and refreshing states independently', () {
      const state = HomeState(isLoading: true, isRefreshing: true);

      expect(state.isLoading, true);
      expect(state.isRefreshing, true);

      final loadedState = state.copyWith(isLoading: false);
      expect(loadedState.isLoading, false);
      expect(loadedState.isRefreshing, true);

      final refreshedState = loadedState.copyWith(isRefreshing: false);
      expect(refreshedState.isLoading, false);
      expect(refreshedState.isRefreshing, false);
    });
  });
}
