// lib/features/home/view_model/home_state.dart
import 'package:lite_x/features/home/models/tweet_model.dart';

class HomeState {
  final List<TweetModel> tweets;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const HomeState({
    this.tweets = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  HomeState copyWith({
    List<TweetModel>? tweets,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return HomeState(
      tweets: tweets ?? this.tweets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
