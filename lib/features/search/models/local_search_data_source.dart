import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/search/models/search_history_hive_model.dart';
import './search_result_model.dart';

class LocalSearchDataSource {
  final Box<SearchHistoryHiveModel> _box;

  LocalSearchDataSource(this._box);

  Future<List<SearchResultModel>> readHistory() async {
    return _box.values
        .toList()
        .reversed
        .map((e) => SearchResultModel(
              id: e.id,
              name: e.name,
              username: e.username,
              isVerified: e.isVerified,
              avatarUrl: e.avatarUrl,
            ))
        .toList();
  }

  Future<void> saveToHistory(SearchResultModel item) async {
    await deleteFromHistory(item.id);
    await _box.add(SearchHistoryHiveModel(
      id: item.id,
      name: item.name,
      username: item.username,
      isVerified: item.isVerified,
      avatarUrl: item.avatarUrl,
    ));
  }

  Future<void> deleteFromHistory(String id) async {
    final keysToDelete = _box.keys.where((key) {
      final entry = _box.get(key);
      return entry?.id == id;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  Future<void> clearHistory() async {
    await _box.clear();
  }
}
