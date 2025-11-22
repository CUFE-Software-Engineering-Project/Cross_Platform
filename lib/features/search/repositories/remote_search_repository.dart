import '../models/remote_search_data_source.dart';
import '../models/search_result_model.dart';

/// Repository that exposes remote search operations
class RemoteSearchRepository {
  final RemoteSearchDataSource _remoteDataSource;

  RemoteSearchRepository(this._remoteDataSource);

  /// Search users by query
  Future<List<SearchResultModel>> search(String query) {
    return _remoteDataSource.search(query);
  }

  /// Save an item to the remote "history" (simulated)
  Future<void> saveItem(SearchResultModel item) {
    return _remoteDataSource.saveItem(item);
  }

  /// Read saved items from remote (simulated backend cache)
  Future<List<SearchResultModel>> readSavedItems() {
    return _remoteDataSource.readSavedItems();
  }

  /// Delete a saved item by ID
  Future<void> deleteItem(String id) {
    return _remoteDataSource.deleteItem(id);
  }

  /// Clear all saved items
  Future<void> clearSaved() {
    return _remoteDataSource.clearSaved();
  }
}
