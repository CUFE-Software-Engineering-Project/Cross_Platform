import 'package:hive_ce/hive.dart';

part "usersearchmodel.g.dart";

@HiveType(typeId: 4)
class UserSearchModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? bio;

  @HiveField(4)
  final String? profileMedia;

  @HiveField(5)
  final int followers;

  UserSearchModel({
    required this.id,
    required this.username,
    required this.name,
    required this.bio,
    required this.profileMedia,
    required this.followers,
  });

  factory UserSearchModel.fromMap(Map<String, dynamic> map) {
    String? profileImage;
    if (map["profileMedia"] != null) {
      if (map["profileMedia"] is Map) {
        profileImage = map["profileMedia"]["keyName"];
      } else if (map["profileMedia"] is String) {
        profileImage = map["profileMedia"];
      }
    }

    return UserSearchModel(
      id: map["id"] ?? "",
      username: map["username"] ?? "",
      name: map["name"] ?? "",
      bio: map["bio"],
      profileMedia: profileImage,
      followers: (map["_count"] != null && map["_count"]["followers"] != null)
          ? map["_count"]["followers"]
          : 0,
    );
  }
}
