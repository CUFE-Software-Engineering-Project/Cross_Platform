import '../models/trend_model.dart';
import '../models/suggested_tweet_model.dart';
import '../models/who_to_follow_model.dart';

enum ExploreCategory {
  forYou,
  trending,
  news,
  entertainment,
  sports,
}

class ExploreState {
  final bool isLoading;
  final ExploreCategory selectedCategory;
  final List<TrendModel> trends;
  final List<TrendModel> todaysNews; // For "For You" tab - Today's News section
  final List<TrendModel> trendingInCountry; // For "For You" tab - Trending in Country
  final List<SuggestedTweetModel> suggestedTweets;
  final List<WhoToFollowModel> whoToFollow;
  final Map<String, List<SuggestedTweetModel>> categoryNews; // Category-based news (Business, Sports, Entertainment)
  final String? error;

  const ExploreState({
    this.isLoading = false,
    this.selectedCategory = ExploreCategory.forYou,
    this.trends = const [],
    this.todaysNews = const [],
    this.trendingInCountry = const [],
    this.suggestedTweets = const [],
    this.whoToFollow = const [],
    this.categoryNews = const {},
    this.error,
  });

  ExploreState copyWith({
    bool? isLoading,
    ExploreCategory? selectedCategory,
    List<TrendModel>? trends,
    List<TrendModel>? todaysNews,
    List<TrendModel>? trendingInCountry,
    List<SuggestedTweetModel>? suggestedTweets,
    List<WhoToFollowModel>? whoToFollow,
    Map<String, List<SuggestedTweetModel>>? categoryNews,
    String? error,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      trends: trends ?? this.trends,
      todaysNews: todaysNews ?? this.todaysNews,
      trendingInCountry: trendingInCountry ?? this.trendingInCountry,
      suggestedTweets: suggestedTweets ?? this.suggestedTweets,
      whoToFollow: whoToFollow ?? this.whoToFollow,
      categoryNews: categoryNews ?? this.categoryNews,
      error: error ?? this.error,
    );
  }
}

