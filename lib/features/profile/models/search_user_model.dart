class SearchUserModel {
  final String id;
  final String username;
  final String name;
  final bool verified;
  final String bio;
  final String profileMedia;
  final String profileMediaId;
  final num followers;
  final num score;
  final bool isFollowing;
  final bool isFollower;

  SearchUserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.verified,
    required this.bio,
    required this.profileMedia,
    required this.followers,
    required this.score,
    required this.isFollowing,
    required this.isFollower,
    required this.profileMediaId,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      verified: json['verified'] ?? false,
      bio: json['bio'] ?? '',
      profileMedia: json['profileMedia'] ?? "",
      followers: json['_count']?['followers'] ?? 0,
      score: json['score'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
      isFollower: json['isFollower'] ?? false,
      profileMediaId: json["profileMediaId"] ?? "",
    );
  }

  SearchUserModel copyWith({
    String? id,
    String? username,
    String? name,
    bool? verified,
    String? bio,
    String? profileMedia,
    num? followers,
    num? score,
    bool? isFollowing,
    bool? isFollower,
    String? profileMediaId,
  }) {
    return SearchUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
      profileMedia: profileMedia ?? this.profileMedia,
      followers: followers ?? this.followers,
      score: score ?? this.score,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      profileMediaId: profileMedia ?? this.profileMedia,
    );
  }
}
