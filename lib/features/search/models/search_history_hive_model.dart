// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:hive_ce/hive.dart';

part 'search_history_hive_model.g.dart';

@HiveType(typeId: 4)
class SearchHistoryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final bool isVerified;

  @HiveField(4)
  final String avatarUrl;

  SearchHistoryHiveModel({
    required this.id,
    required this.name,
    required this.username,
    required this.isVerified,
    required this.avatarUrl,
  });

  SearchHistoryHiveModel copyWith({
    String? id,
    String? name,
    String? username,
    bool? isVerified,
    String? avatarUrl,
  }) {
    return SearchHistoryHiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
    };
  }

  factory SearchHistoryHiveModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryHiveModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      username: map['username'] ?? "",
      isVerified: map['isVerified'] ?? false,
      avatarUrl: map['avatarUrl'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchHistoryHiveModel.fromJson(String source) =>
      SearchHistoryHiveModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SearchHistoryHiveModel(id: $id, name: $name, username: $username, isVerified: $isVerified, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(covariant SearchHistoryHiveModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.username == username &&
        other.isVerified == isVerified &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        isVerified.hashCode ^
        avatarUrl.hashCode;
  }
}