import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/remote_search_data_source.dart';
import 'models/local_search_data_source.dart';
import 'repositories/remote_search_repository.dart';
import 'repositories/local_search_repository.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/core/models/search_history_hive_model.dart';

/// DataSource Providers
final remoteSearchDataSourceProvider = Provider<RemoteSearchDataSource>((ref) {
  return RemoteSearchDataSource();
});

final localSearchDataSourceProvider = Provider<LocalSearchDataSource>((ref) {
  final box = Hive.box<SearchHistoryHiveModel>('search_history');
  return LocalSearchDataSource(box);
});

/// Repository Providers
final remoteSearchRepositoryProvider = Provider<RemoteSearchRepository>((ref) {
  final dataSource = ref.read(remoteSearchDataSourceProvider);
  return RemoteSearchRepository(dataSource);
});

final localSearchRepositoryProvider = Provider<LocalSearchRepository>((ref) {
  final dataSource = ref.read(localSearchDataSourceProvider);
  return LocalSearchRepository(dataSource);
});
