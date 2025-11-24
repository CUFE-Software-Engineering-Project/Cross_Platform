import '../models/search_result_model.dart';

class SearchState {
  final bool isLoading;
  final List<SearchResultModel> results;
  final List<SearchResultModel> history;
  final String? error;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.history = const [],
    this.error,
  });

  /// Creates a new instance with updated fields
  SearchState copyWith({
    bool? isLoading,
    List<SearchResultModel>? results,
    List<SearchResultModel>? history,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      history: history ?? this.history,
      error: error,
    );
  }

  /// Initial state factory
  factory SearchState.initial() => const SearchState();

  /// Loading state factory
  SearchState loading() => copyWith(isLoading: true, error: null);

  /// Error state factory
  SearchState failure(String message) => copyWith(isLoading: false, error: message);

  /// Success state factory
  SearchState success({
    List<SearchResultModel>? results,
    List<SearchResultModel>? history,
  }) {
    return copyWith(
      isLoading: false,
      results: results ?? this.results,
      history: history ?? this.history,
      error: null,
    );
  }
}
