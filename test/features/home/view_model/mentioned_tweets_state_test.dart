import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/mentioned_tweets_state.dart';

void main() {
  group('MentionedTweetsState Tests', () {
    final testDate = DateTime(2024, 1, 1);

    final testTweet1 = TweetModel(
      id: '1',
      content: 'Test mention @testuser',
      authorName: 'User 1',
      authorUsername: 'user1',
      authorAvatar: 'avatar1',
      createdAt: testDate,
    );

    final testTweet2 = TweetModel(
      id: '2',
      content: 'Another mention @testuser',
      authorName: 'User 2',
      authorUsername: 'user2',
      authorAvatar: 'avatar2',
      createdAt: testDate,
    );

    test('creates MentionedTweetsState with default values', () {
      const state = MentionedTweetsState(username: 'testuser');

      expect(state.username, 'testuser');
      expect(state.tweets, isEmpty);
      expect(state.isLoading, false);
      expect(state.isLoadingMore, false);
      expect(state.hasMore, true);
      expect(state.nextCursor, isNull);
      expect(state.error, isNull);
    });

    test('creates MentionedTweetsState with custom values', () {
      final state = MentionedTweetsState(
        username: 'testuser',
        tweets: [testTweet1],
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        nextCursor: 'cursor_123',
        error: 'Test error',
      );

      expect(state.username, 'testuser');
      expect(state.tweets.length, 1);
      expect(state.isLoading, true);
      expect(state.isLoadingMore, false);
      expect(state.hasMore, true);
      expect(state.nextCursor, 'cursor_123');
      expect(state.error, 'Test error');
    });

    test('copyWith creates new state with updated username', () {
      const original = MentionedTweetsState(username: 'user1');

      final updated = original.copyWith(username: 'user2');

      expect(updated.username, 'user2');
      expect(updated.tweets, isEmpty); // unchanged
    });

    test('copyWith updates tweets', () {
      const original = MentionedTweetsState(username: 'testuser');

      final updated = original.copyWith(tweets: [testTweet1, testTweet2]);

      expect(updated.tweets.length, 2);
      expect(updated.tweets[0].id, '1');
      expect(updated.tweets[1].id, '2');
      expect(updated.username, 'testuser'); // unchanged
    });

    test('copyWith updates isLoading', () {
      const original = MentionedTweetsState(
        username: 'testuser',
        isLoading: false,
      );

      final updated = original.copyWith(isLoading: true);

      expect(updated.isLoading, true);
    });

    test('copyWith updates isLoadingMore', () {
      const original = MentionedTweetsState(
        username: 'testuser',
        isLoadingMore: false,
      );

      final updated = original.copyWith(isLoadingMore: true);

      expect(updated.isLoadingMore, true);
    });

    test('copyWith updates hasMore', () {
      const original = MentionedTweetsState(
        username: 'testuser',
        hasMore: true,
      );

      final updated = original.copyWith(hasMore: false);

      expect(updated.hasMore, false);
    });

    test('copyWith updates nextCursor', () {
      const original = MentionedTweetsState(username: 'testuser');

      final updated = original.copyWith(nextCursor: 'cursor_456');

      expect(updated.nextCursor, 'cursor_456');
    });

    test('copyWith updates error', () {
      const original = MentionedTweetsState(username: 'testuser');

      final updated = original.copyWith(error: 'Network error');

      expect(updated.error, 'Network error');
    });

    test('copyWith updates multiple fields at once', () {
      const original = MentionedTweetsState(username: 'testuser');

      final updated = original.copyWith(
        tweets: [testTweet1],
        isLoading: false,
        hasMore: false,
        nextCursor: 'cursor_123',
        error: null,
      );

      expect(updated.tweets.length, 1);
      expect(updated.isLoading, false);
      expect(updated.hasMore, false);
      expect(updated.nextCursor, 'cursor_123');
      expect(updated.error, isNull);
    });

    test('copyWith preserves unspecified fields', () {
      final original = MentionedTweetsState(
        username: 'testuser',
        tweets: [testTweet1],
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        nextCursor: 'cursor_123',
        error: 'Error',
      );

      final updated = original.copyWith(isLoading: false);

      expect(updated.username, 'testuser'); // preserved
      expect(updated.tweets.length, 1); // preserved
      expect(updated.isLoading, false); // changed
      expect(updated.isLoadingMore, false); // preserved
      expect(updated.hasMore, true); // preserved
      expect(updated.nextCursor, 'cursor_123'); // preserved
      expect(updated.error, 'Error'); // preserved
    });

    test('copyWith does not support explicitly setting to null', () {
      // Note: copyWith uses ?? operator, so passing null won't clear fields
      const original = MentionedTweetsState(
        username: 'testuser',
        error: 'Some error',
        nextCursor: 'cursor_123',
      );

      // Attempting to set to null won't actually clear the value due to ?? operator
      final updated = original.copyWith(error: null);

      // The error will remain because copyWith uses: error ?? this.error
      expect(updated.error, 'Some error');
    });

    test('copyWith preserves null when updating other fields', () {
      // When original field is null and we don't update it, it stays null
      const original = MentionedTweetsState(
        username: 'testuser',
        nextCursor: null,
      );

      final updated = original.copyWith(username: 'newuser');

      expect(updated.nextCursor, isNull);
    });

    test('transitions from loading to loaded state', () {
      const initial = MentionedTweetsState(
        username: 'testuser',
        isLoading: true,
      );

      final loaded = initial.copyWith(
        tweets: [testTweet1, testTweet2],
        isLoading: false,
        nextCursor: 'cursor_123',
        hasMore: true,
      );

      expect(loaded.isLoading, false);
      expect(loaded.tweets.length, 2);
      expect(loaded.hasMore, true);
      expect(loaded.nextCursor, 'cursor_123');
    });

    test('transitions from loaded to loadingMore state', () {
      final initial = MentionedTweetsState(
        username: 'testuser',
        tweets: [testTweet1],
        hasMore: true,
        nextCursor: 'cursor_123',
      );

      final loadingMore = initial.copyWith(isLoadingMore: true);

      expect(loadingMore.isLoadingMore, true);
      expect(loadingMore.tweets.length, 1); // preserved
    });

    test('transitions to error state', () {
      const initial = MentionedTweetsState(
        username: 'testuser',
        isLoading: true,
      );

      final error = initial.copyWith(
        isLoading: false,
        error: 'Failed to load tweets',
      );

      expect(error.isLoading, false);
      expect(error.error, 'Failed to load tweets');
    });

    test('can append more tweets', () {
      final initial = MentionedTweetsState(
        username: 'testuser',
        tweets: [testTweet1],
        nextCursor: 'cursor_123',
      );

      final updated = initial.copyWith(
        tweets: [...initial.tweets, testTweet2],
        nextCursor: 'cursor_456',
        isLoadingMore: false,
      );

      expect(updated.tweets.length, 2);
      expect(updated.tweets[0].id, '1');
      expect(updated.tweets[1].id, '2');
      expect(updated.nextCursor, 'cursor_456');
    });
  });
}
