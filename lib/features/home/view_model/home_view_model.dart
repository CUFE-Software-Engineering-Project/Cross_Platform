// lib/features/home/view_model/home_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/home/view_model/home_state.dart';

// Provider for HomeRepository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

// StateNotifier for managing home page state
class HomeViewModel extends Notifier<HomeState> {
  late HomeRepository _repository;

  @override
  HomeState build() {
    _repository = ref.read(homeRepositoryProvider);

    // Provide sample tweets immediately
    final sampleTweets = _repository.getSampleTweets();
    return HomeState(tweets: sampleTweets, isLoading: false);
  }

  // Load tweets from local storage or create sample data
  Future<void> loadTweets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // First try to get local tweets
      List<TweetModel> tweets = _repository.getLocalTweets();

      // If no local tweets, create sample tweets
      if (tweets.isEmpty) {
        tweets = _repository.getSampleTweets();
        await _repository.saveTweetsLocally(tweets);
      }

      state = state.copyWith(tweets: tweets, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tweets: $e',
      );
    }
  }

  // Refresh tweets (pull to refresh)
  Future<void> refreshTweets() async {
    state = state.copyWith(isRefreshing: true);

    try {
      // In a real app, this would fetch from API
      // For now, we'll just reload local data
      await loadTweets();
      state = state.copyWith(isRefreshing: false);
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh tweets: $e',
      );
    }
  }

  // Like/unlike a tweet
  Future<void> toggleLike(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final updatedTweet = tweet.copyWith(
          isLiked: !tweet.isLiked,
          likes: tweet.isLiked ? tweet.likes - 1 : tweet.likes + 1,
        );

        // Update in memory
        final updatedTweets = List<TweetModel>.from(tweets);
        updatedTweets[tweetIndex] = updatedTweet;

        state = state.copyWith(tweets: updatedTweets);

        // Update in local storage
        await _repository.updateTweetLocally(updatedTweet);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update like: $e');
    }
  }

  // Retweet/unretweet a tweet
  Future<void> toggleRetweet(String tweetId) async {
    try {
      final tweets = state.tweets;
      final tweetIndex = tweets.indexWhere((tweet) => tweet.id == tweetId);

      if (tweetIndex != -1) {
        final tweet = tweets[tweetIndex];
        final updatedTweet = tweet.copyWith(
          isRetweeted: !tweet.isRetweeted,
          retweets: tweet.isRetweeted ? tweet.retweets - 1 : tweet.retweets + 1,
        );

        // Update in memory
        final updatedTweets = List<TweetModel>.from(tweets);
        updatedTweets[tweetIndex] = updatedTweet;

        state = state.copyWith(tweets: updatedTweets);

        // Update in local storage
        await _repository.updateTweetLocally(updatedTweet);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update retweet: $e');
    }
  }
}

// Provider for HomeViewModel
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel(); // Creates a new HomeViewModel instance
});
