import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/search_result_model.dart';
import '../repositories/remote_search_repository.dart';
import '../repositories/local_search_repository.dart';
import 'search_state.dart';
import '../providers.dart';

part 'search_view_model.g.dart';
@Riverpod(keepAlive: true)
class SearchViewModel extends _$SearchViewModel {
  late final RemoteSearchRepository _remoteRepo;
  late final LocalSearchRepository _localRepo;

  @override
  SearchState build() {
    // Read repositories from Riverpod
    _remoteRepo = ref.read(remoteSearchRepositoryProvider);
    _localRepo = ref.read(localSearchRepositoryProvider);

    _loadHistory();
    return SearchState.initial();
  }

  Future<void> _loadHistory() async {
    final history = await _localRepo.readHistory();
    state = state.copyWith(history: history);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _remoteRepo.search(query);
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveToHistory(SearchResultModel item) async {
    await _localRepo.saveToHistory(item);
    final history = await _localRepo.readHistory();
    state = state.copyWith(history: history);
  }

  Future<void> deleteFromHistory(String id) async {
    await _localRepo.deleteFromHistory(id);
    final history = await _localRepo.readHistory();
    state = state.copyWith(history: history);
  }

  Future<void> clearHistory() async {
    await _localRepo.clearHistory();
    state = state.copyWith(history: []);
  }
}
