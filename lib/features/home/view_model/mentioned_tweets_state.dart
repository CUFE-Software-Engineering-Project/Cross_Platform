import '../models/tweet_model.dart';

class MentionedTweetsState {
  final String username;
  final List<TweetModel> tweets;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const MentionedTweetsState({
    required this.username,
    this.tweets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });

  MentionedTweetsState copyWith({
    String? username,
    List<TweetModel>? tweets,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    String? error,
  }) {
    return MentionedTweetsState(
      username: username ?? this.username,
      tweets: tweets ?? this.tweets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: error ?? this.error,
    );
  }
}
