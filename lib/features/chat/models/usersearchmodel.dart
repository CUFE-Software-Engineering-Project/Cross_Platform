class UserSearchModel {
  final String id;
  final String username;
  final String name;
  final String? profileMedia;

  UserSearchModel({
    required this.id,
    required this.username,
    required this.name,
    required this.profileMedia,
  });

  factory UserSearchModel.fromMap(Map<String, dynamic> map) {
    return UserSearchModel(
      id: map["id"] ?? "",
      username: map["username"] ?? "",
      name: map["name"] ?? "",
      profileMedia: map["profileMedia"],
    );
  }
}
