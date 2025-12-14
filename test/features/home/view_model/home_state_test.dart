import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

void main() {
  group('HomeState Tests', () {
    final testDate = DateTime(2024, 1, 1);

    final testTweet1 = TweetModel(
      id: '1',
      content: 'Test tweet 1',
      authorName: 'User 1',
      authorUsername: 'user1',
      authorAvatar: 'avatar1',
      createdAt: testDate,
    );

    final testTweet2 = TweetModel(
      id: '2',
      content: 'Test tweet 2',
      authorName: 'User 2',
      authorUsername: 'user2',
      authorAvatar: 'avatar2',
      createdAt: testDate,
    );

    test('creates HomeState with default values', () {
      const state = HomeState();

      expect(state.tweets, isEmpty);
      expect(state.forYouTweets, isEmpty);
      expect(state.followingTweets, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isRefreshing, false);
      expect(state.currentFeed, FeedType.forYou);
      expect(state.isLoadingMore, false);
      expect(state.forYouCursor, isNull);
      expect(state.followingCursor, isNull);
      expect(state.hasMoreForYou, true);
      expect(state.hasMoreFollowing, true);
    });

    test('creates HomeState with custom values', () {
      final state = HomeState(
        tweets: [testTweet1],
        forYouTweets: [testTweet1],
        isLoading: true,
        error: 'Test error',
        currentFeed: FeedType.following,
      );

      expect(state.tweets.length, 1);
      expect(state.forYouTweets.length, 1);
      expect(state.isLoading, true);
      expect(state.error, 'Test error');
      expect(state.currentFeed, FeedType.following);
    });

    test('copyWith creates new state with updated tweets', () {
      const original = HomeState();

      final updated = original.copyWith(tweets: [testTweet1, testTweet2]);

      expect(updated.tweets.length, 2);
      expect(updated.tweets[0].id, '1');
      expect(updated.tweets[1].id, '2');
      expect(updated.isLoading, false); // unchanged
    });

    test('copyWith updates isLoading', () {
      const original = HomeState(isLoading: false);

      final updated = original.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.tweets, isEmpty); // unchanged
    });

    test('copyWith updates error', () {
      const original = HomeState();

      final updated = original.copyWith(error: 'Test error');

      expect(updated.error, 'Test error');
    });

    test('copyWith updates isRefreshing', () {
      const original = HomeState();

      final updated = original.copyWith(isRefreshing: true);

      expect(updated.isRefreshing, true);
    });

    test('copyWith updates currentFeed', () {
      const original = HomeState(currentFeed: FeedType.forYou);

      final updated = original.copyWith(currentFeed: FeedType.following);

      expect(updated.currentFeed, FeedType.following);
    });

    test('copyWith updates forYouTweets independently', () {
      final original = HomeState(tweets: [testTweet1]);

      final updated = original.copyWith(forYouTweets: [testTweet2]);

      expect(updated.tweets.length, 1);
      expect(updated.tweets[0].id, '1'); // original tweets unchanged
      expect(updated.forYouTweets.length, 1);
      expect(updated.forYouTweets[0].id, '2');
    });

    test('copyWith updates followingTweets independently', () {
      final original = HomeState(tweets: [testTweet1]);

      final updated = original.copyWith(followingTweets: [testTweet2]);

      expect(updated.tweets.length, 1);
      expect(updated.tweets[0].id, '1'); // original tweets unchanged
      expect(updated.followingTweets.length, 1);
      expect(updated.followingTweets[0].id, '2');
    });

    test('copyWith updates isLoadingMore', () {
      const original = HomeState();

      final updated = original.copyWith(isLoadingMore: true);

      expect(updated.isLoadingMore, true);
    });

    test('copyWith updates forYouCursor', () {
      const original = HomeState();

      final updated = original.copyWith(forYouCursor: 'cursor_123');

      expect(updated.forYouCursor, 'cursor_123');
    });

    test('copyWith updates followingCursor', () {
      const original = HomeState();

      final updated = original.copyWith(followingCursor: 'cursor_456');

      expect(updated.followingCursor, 'cursor_456');
    });

    test('copyWith updates hasMoreForYou', () {
      const original = HomeState(hasMoreForYou: true);

      final updated = original.copyWith(hasMoreForYou: false);

      expect(updated.hasMoreForYou, false);
    });

    test('copyWith updates hasMoreFollowing', () {
      const original = HomeState(hasMoreFollowing: true);

      final updated = original.copyWith(hasMoreFollowing: false);

      expect(updated.hasMoreFollowing, false);
    });

    test('copyWith updates multiple fields at once', () {
      const original = HomeState();

      final updated = original.copyWith(
        tweets: [testTweet1],
        isLoading: false,
        error: null,
        currentFeed: FeedType.following,
        hasMoreFollowing: false,
      );

      expect(updated.tweets.length, 1);
      expect(updated.isLoading, false);
      expect(updated.error, isNull);
      expect(updated.currentFeed, FeedType.following);
      expect(updated.hasMoreFollowing, false);
    });

    test('copyWith preserves unspecified fields', () {
      final original = HomeState(
        tweets: [testTweet1],
        forYouTweets: [testTweet1],
        followingTweets: [testTweet2],
        isLoading: true,
        error: 'Error',
        isRefreshing: true,
        currentFeed: FeedType.following,
      );

      final updated = original.copyWith(isLoading: false);

      expect(updated.tweets.length, 1);
      expect(updated.forYouTweets.length, 1);
      expect(updated.followingTweets.length, 1);
      expect(updated.isLoading, false); // changed
      expect(updated.error, 'Error'); // preserved
      expect(updated.isRefreshing, true); // preserved
      expect(updated.currentFeed, FeedType.following); // preserved
    });
  });

  group('FeedType Tests', () {
    test('FeedType enum has correct values', () {
      expect(FeedType.values.length, 2);
      expect(FeedType.values, contains(FeedType.forYou));
      expect(FeedType.values, contains(FeedType.following));
    });

    test('FeedType can be compared', () {
      expect(FeedType.forYou == FeedType.forYou, true);
      expect(FeedType.forYou == FeedType.following, false);
    });
  });
}
