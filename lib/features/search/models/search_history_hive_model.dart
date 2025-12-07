import 'package:hive_ce/hive.dart';

part 'search_history_hive_model.g.dart';

@HiveType(typeId: 3)
class SearchHistoryHiveModel extends HiveObject {
  @HiveField(0)
  String query;

  @HiveField(1)
  DateTime searchedAt;

  SearchHistoryHiveModel({
    required this.query,
    required this.searchedAt,
  });
}
