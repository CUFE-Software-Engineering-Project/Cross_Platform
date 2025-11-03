import 'package:lite_x/features/home/models/tweet_model.dart';

enum FeedType { forYou, following }

class HomeState {
  final List<TweetModel> tweets; // Currently displayed tweets
  final List<TweetModel> forYouTweets; // Cached For You feed
  final List<TweetModel> followingTweets; // Cached Following feed
  final bool isLoading;
  final String? error;
  final bool isRefreshing;
  final FeedType currentFeed;

  const HomeState({
    this.tweets = const [],
    this.forYouTweets = const [],
    this.followingTweets = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
    this.currentFeed = FeedType.forYou,
  });

  HomeState copyWith({
    List<TweetModel>? tweets,
    List<TweetModel>? forYouTweets,
    List<TweetModel>? followingTweets,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
    FeedType? currentFeed,
  }) {
    return HomeState(
      tweets: tweets ?? this.tweets,
      forYouTweets: forYouTweets ?? this.forYouTweets,
      followingTweets: followingTweets ?? this.followingTweets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentFeed: currentFeed ?? this.currentFeed,
    );
  }
}
