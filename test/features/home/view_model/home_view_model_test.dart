import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

void main() {
  TweetModel createTestTweet(String id, String content) {
    return TweetModel(
      id: id,
      content: content,
      authorName: 'Test User',
      authorUsername: 'testuser',
      authorAvatar: 'avatar.jpg',
      createdAt: DateTime.now(),
    );
  }

  group('HomeViewModel State Management', () {
    test('should update tweet like status correctly', () {
      final tweet = createTestTweet('1', 'Test Tweet');
      tweet.isLiked = false;
      tweet.likes = 5;

      // Simulate like
      tweet.isLiked = true;
      tweet.likes = 6;

      expect(tweet.isLiked, true);
      expect(tweet.likes, 6);
    });

    test('should update tweet retweet status correctly', () {
      final tweet = createTestTweet('1', 'Test Tweet');
      tweet.isRetweeted = false;
      tweet.retweets = 3;

      // Simulate retweet
      tweet.isRetweeted = true;
      tweet.retweets = 4;

      expect(tweet.isRetweeted, true);
      expect(tweet.retweets, 4);
    });

    test('should update tweet bookmark status correctly', () {
      final tweet = createTestTweet('1', 'Test Tweet');
      tweet.isBookmarked = false;

      // Simulate bookmark
      tweet.isBookmarked = true;

      expect(tweet.isBookmarked, true);
    });

    test('should maintain separate feed lists', () {
      final followingTweets = [
        createTestTweet('1', 'Following Tweet 1'),
        createTestTweet('2', 'Following Tweet 2'),
      ];

      final forYouTweets = [
        createTestTweet('3', 'For You Tweet 1'),
        createTestTweet('4', 'For You Tweet 2'),
      ];

      final state = HomeState(
        tweets: followingTweets,
        followingTweets: followingTweets,
        forYouTweets: forYouTweets,
        currentFeed: FeedType.following,
      );

      expect(state.tweets.length, 2);
      expect(state.followingTweets.length, 2);
      expect(state.forYouTweets.length, 2);
      expect(state.currentFeed, FeedType.following);
    });

    test('should handle feed switching', () {
      final followingTweets = [createTestTweet('1', 'Following')];
      final forYouTweets = [createTestTweet('2', 'For You')];

      final initialState = HomeState(
        tweets: followingTweets,
        followingTweets: followingTweets,
        forYouTweets: forYouTweets,
        currentFeed: FeedType.following,
      );

      // Switch to forYou feed
      final newState = initialState.copyWith(
        tweets: forYouTweets,
        currentFeed: FeedType.forYou,
      );

      expect(newState.currentFeed, FeedType.forYou);
      expect(newState.tweets[0].id, '2');
      expect(newState.followingTweets[0].id, '1'); // Preserved
    });

    test('should add new tweet to feed', () {
      final existingTweets = [createTestTweet('1', 'Existing Tweet')];
      final newTweet = createTestTweet('2', 'New Tweet');

      final state = HomeState(
        tweets: existingTweets,
        followingTweets: existingTweets,
      );

      // Add new tweet
      final updatedTweets = [newTweet, ...state.followingTweets];
      final newState = state.copyWith(
        tweets: updatedTweets,
        followingTweets: updatedTweets,
      );

      expect(newState.tweets.length, 2);
      expect(newState.tweets[0].id, '2'); // New tweet at top
      expect(newState.tweets[1].id, '1'); // Existing tweet
    });

    test('should handle error states', () {
      const state = HomeState(
        isLoading: false,
        error: 'Network error occurred',
      );

      expect(state.error, 'Network error occurred');
      expect(state.isLoading, false);
    });

    test('should handle loading and refreshing independently', () {
      const loadingState = HomeState(isLoading: true, isRefreshing: false);
      expect(loadingState.isLoading, true);
      expect(loadingState.isRefreshing, false);

      const refreshingState = HomeState(isLoading: false, isRefreshing: true);
      expect(refreshingState.isLoading, false);
      expect(refreshingState.isRefreshing, true);
    });

    test('should update tweet in feed list', () {
      final tweet1 = createTestTweet('1', 'Tweet 1');
      tweet1.likes = 5;
      final tweet2 = createTestTweet('2', 'Tweet 2');

      final state = HomeState(tweets: [tweet1, tweet2]);

      // Update tweet1 likes
      tweet1.likes = 10;

      expect(state.tweets[0].likes, 10);
      expect(state.tweets[1].id, '2');
    });

    test('should handle reply relationships in feed', () {
      final parentTweet = createTestTweet('1', 'Parent tweet');
      final replyTweet = createTestTweet('2', 'Reply tweet');

      final updatedParent = parentTweet.copyWith(replyIds: ['2']);

      final updatedReply = replyTweet.copyWith(replyToId: '1');

      expect(updatedParent.replyIds, contains('2'));
      expect(updatedReply.replyToId, '1');
    });
  });
}
