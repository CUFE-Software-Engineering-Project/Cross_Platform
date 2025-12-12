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
  final bool isLoadingMore; // Loading more tweets
  final String? forYouCursor; // Next cursor for For You feed
  final String? followingCursor; // Next cursor for Following feed
  final bool hasMoreForYou; // More tweets available in For You
  final bool hasMoreFollowing; // More tweets available in Following

  const HomeState({
    this.tweets = const [],
    this.forYouTweets = const [],
    this.followingTweets = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
    this.currentFeed = FeedType.forYou, // Default to For You feed
    this.isLoadingMore = false,
    this.forYouCursor,
    this.followingCursor,
    this.hasMoreForYou = true,
    this.hasMoreFollowing = true,
  });

  HomeState copyWith({
    List<TweetModel>? tweets,
    List<TweetModel>? forYouTweets,
    List<TweetModel>? followingTweets,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
    FeedType? currentFeed,
    bool? isLoadingMore,
    String? forYouCursor,
    String? followingCursor,
    bool? hasMoreForYou,
    bool? hasMoreFollowing,
  }) {
    return HomeState(
      tweets: tweets ?? this.tweets,
      forYouTweets: forYouTweets ?? this.forYouTweets,
      followingTweets: followingTweets ?? this.followingTweets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentFeed: currentFeed ?? this.currentFeed,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      forYouCursor: forYouCursor ?? this.forYouCursor,
      followingCursor: followingCursor ?? this.followingCursor,
      hasMoreForYou: hasMoreForYou ?? this.hasMoreForYou,
      hasMoreFollowing: hasMoreFollowing ?? this.hasMoreFollowing,
    );
  }
}
