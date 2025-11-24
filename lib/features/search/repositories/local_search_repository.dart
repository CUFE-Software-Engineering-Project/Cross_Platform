import '../models/local_search_data_source.dart';
import '../models/search_result_model.dart';

class LocalSearchRepository {
  final LocalSearchDataSource _localDataSource;

  LocalSearchRepository(this._localDataSource);

  Future<List<SearchResultModel>> readHistory() =>
      _localDataSource.readHistory();

  Future<void> saveToHistory(SearchResultModel item) =>
      _localDataSource.saveToHistory(item);

  Future<void> deleteFromHistory(String id) =>
      _localDataSource.deleteFromHistory(id);

  Future<void> clearHistory() => _localDataSource.clearHistory();
}
