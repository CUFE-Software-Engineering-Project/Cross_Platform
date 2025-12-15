import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class TrendsViewModel extends ChangeNotifier {
  // Placeholder state and methods mirroring profile view model
  List<dynamic> trends = [];

  void loadTrends() {
    // TODO: implement loading logic
    trends = [];
    notifyListeners();
  }
}

class ExploreCategoryState {
  final List<ProfileTweetModel> tweets;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final bool didInitialLoadAttempt;

  ExploreCategoryState({
    required this.tweets,
    required this.nextCursor,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasError,
    this.didInitialLoadAttempt = false,
  });

  ExploreCategoryState copyWith({
    List<ProfileTweetModel>? tweets,
    String? nextCursor,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    bool? didInitialLoadAttempt,
  }) {
    return ExploreCategoryState(
      tweets: tweets ?? this.tweets,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      didInitialLoadAttempt:
          didInitialLoadAttempt ?? this.didInitialLoadAttempt,
    );
  }
}

final exploreCategoryProvider =
    StateNotifierProvider.family<
      ExploreCategoryNotifier,
      ExploreCategoryState,
      String
    >((ref, categoryName) {
      return ExploreCategoryNotifier(ref, categoryName);
    });

class ExploreCategoryNotifier extends StateNotifier<ExploreCategoryState> {
  final Ref ref;
  final String categoryName;

  ExploreCategoryNotifier(this.ref, this.categoryName)
    : super(
        ExploreCategoryState(
          tweets: [],
          nextCursor: null,
          isLoading: false,
          isLoadingMore: false,
          hasError: false,
        ),
      );

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      tweets: [],
      nextCursor: null,
      didInitialLoadAttempt: true,
    );

    try {
      final repo = ref.read(profileRepoProvider);
      final result = await repo.getTweetsForExploreCategory(categoryName);

      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, hasError: true);
        },
        (paginatedTweets) {
          state = state.copyWith(
            tweets: paginatedTweets.tweets,
            nextCursor: paginatedTweets.nextCursor,
            isLoading: false,
            hasError: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> loadMore() async {
    // Don't load more if already loading, no more data, or has error
    if (state.isLoadingMore || state.nextCursor == null || state.hasError) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(profileRepoProvider);
      final result = await repo.getTweetsForExploreCategory(
        categoryName,
        cursor: state.nextCursor,
      );

      result.fold(
        (failure) {
          state = state.copyWith(isLoadingMore: false, hasError: true);
        },
        (paginatedTweets) {
          final existingTweets = [...state.tweets];
          final newTweets = paginatedTweets.tweets;

          // Avoid duplicates by tweet ID
          final existingIds = existingTweets.map((t) => t.id).toSet();
          final uniqueNewTweets = newTweets
              .where((tweet) => !existingIds.contains(tweet.id))
              .toList();

          state = state.copyWith(
            tweets: [...existingTweets, ...uniqueNewTweets],
            nextCursor: paginatedTweets.nextCursor,
            isLoadingMore: false,
            hasError: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, hasError: true);
    }
  }

  void refresh() {
    state = ExploreCategoryState(
      tweets: [],
      nextCursor: null,
      isLoading: false,
      isLoadingMore: false,
      hasError: false,
      didInitialLoadAttempt: false,
    );
    loadInitial();
  }
}
