import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/search/data/search_repository.dart';

class SearchParams {
  final String query;
  final SearchTab tab;

  const SearchParams({required this.query, required this.tab});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams &&
        other.query == query &&
        other.tab == tab;
  }

  @override
  int get hashCode => Object.hash(query, tab);
}

class SearchResultsState {
  final List<TweetModel> tweets;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? nextCursor;

  const SearchResultsState({
    required this.tweets,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.nextCursor,
  });

  factory SearchResultsState.initial() {
    return const SearchResultsState(
      tweets: [],
      isLoading: false,
      isLoadingMore: false,
      error: null,
      nextCursor: null,
    );
  }

  SearchResultsState copyWith({
    List<TweetModel>? tweets,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? nextCursor,
  }) {
    return SearchResultsState(
      tweets: tweets ?? this.tweets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }
}

class SearchResultsNotifier extends StateNotifier<SearchResultsState> {
  final SearchRepository _repository;
  final SearchParams _params;

  SearchResultsNotifier(this._repository, this._params)
      : super(SearchResultsState.initial()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final query = _params.query.trim();
    if (query.isEmpty) {
      state = SearchResultsState.initial();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, nextCursor: null);

    try {
      final page = await _repository.searchTweets(
        query: query,
        tab: _params.tab,
      );
      state = state.copyWith(
        tweets: page.tweets,
        isLoading: false,
        nextCursor: page.nextCursor,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadInitial();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore) return;
    if (state.nextCursor == null || state.nextCursor!.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _repository.searchTweets(
        query: _params.query,
        tab: _params.tab,
        cursor: state.nextCursor,
      );

      final updatedTweets = List<TweetModel>.from(state.tweets)
        ..addAll(page.tweets);

      state = state.copyWith(
        tweets: updatedTweets,
        isLoadingMore: false,
        nextCursor: page.nextCursor,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleLike(String tweetId) async {
    final index = state.tweets.indexWhere((t) => t.id == tweetId);
    if (index == -1) return;

    final current = state.tweets[index];
    final currentlyLiked = current.isLiked;
    final updatedTweet = current.copyWith(
      isLiked: !currentlyLiked,
      likes: currentlyLiked ? current.likes - 1 : current.likes + 1,
    );

    final updatedTweets = List<TweetModel>.from(state.tweets)
      ..[index] = updatedTweet;
    state = state.copyWith(tweets: updatedTweets);

    try {
      final serverTweet =
          await _repository.toggleLike(tweetId, currentlyLiked);
      final serverIndex =
          state.tweets.indexWhere((element) => element.id == serverTweet.id);
      if (serverIndex != -1) {
        final copy = List<TweetModel>.from(state.tweets)
          ..[serverIndex] = serverTweet;
        state = state.copyWith(tweets: copy);
      }
    } catch (_) {}
  }
}

final searchResultsProvider = StateNotifierProvider.family<
    SearchResultsNotifier, SearchResultsState, SearchParams>((ref, params) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchResultsNotifier(repository, params);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super(const []);

  void add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final lower = trimmed.toLowerCase();
    final filtered = state.where((q) => q.toLowerCase() != lower).toList();
    state = [trimmed, ...filtered].take(20).toList();
  }

  void remove(String query) {
    final lower = query.toLowerCase();
    state = state.where((q) => q.toLowerCase() != lower).toList();
  }

  void clear() {
    state = const [];
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

final suggestionsProvider =
    FutureProvider.family<List<SearchSuggestionUser>, String>((ref, query) async {
  final repository = ref.watch(searchRepositoryProvider);
  final trimmed = query.trim();
  if (trimmed.isEmpty) return const [];
  final page = await repository.searchUsers(trimmed, limit: 20);
  return page.users;
});
