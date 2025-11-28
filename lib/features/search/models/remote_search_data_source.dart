import 'dart:async';
import 'search_result_model.dart';

/// A mock data source that simulates backend search read & write operations.
class RemoteSearchDataSource {
  /// Local mock dataset representing users in the system.
  final List<SearchResultModel> _mockUsers = [
    SearchResultModel(
      id: '1',
      name: 'Elon Musk',
      username: '@elonmusk',
      isVerified: true,
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    SearchResultModel(
      id: '2',
      name: 'Jane Doe',
      username: '@janedoe',
      isVerified: false,
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    SearchResultModel(
      id: '3',
      name: 'TechCrunch',
      username: '@TechCrunch',
      isVerified: true,
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    SearchResultModel(
      id: '4',
      name: 'John Appleseed',
      username: '@johnapple',
      isVerified: false,
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    SearchResultModel(
      id: '5',
      name: 'Flutter Devs',
      username: '@flutterdev',
      isVerified: true,
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    SearchResultModel(
      id: '6',
      name: 'Dart Lang',
      username: '@dart_lang',
      isVerified: true,
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
    ),
  ];

  /// Mock writable storage (like backend persistence or local cache)
  final List<SearchResultModel> _savedItems = [];

  /// Simulates reading data from a remote backend.
  Future<List<SearchResultModel>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();

    return _mockUsers
        .where((user) =>
            user.name.toLowerCase().contains(lowerQuery) ||
            user.username.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Simulates writing/saving an item (e.g., adding to search history).
  Future<void> saveItem(SearchResultModel item) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // avoid duplicates
    final exists = _savedItems.any((u) => u.id == item.id);
    if (!exists) {
      _savedItems.add(item);
    }
  }

  /// Simulates reading saved items (like from cache or database)
  Future<List<SearchResultModel>> readSavedItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_savedItems);
  }

  /// Simulates deleting a saved item
  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedItems.removeWhere((u) => u.id == id);
  }

  /// Clears all saved items (like clearing search history)
  Future<void> clearSaved() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedItems.clear();
  }
}
