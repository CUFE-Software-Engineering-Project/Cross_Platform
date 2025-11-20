class WhoToFollowModel {
  final String id;
  final String displayName;
  final String username;
  final String? bio;
  final String avatarUrl;
  final bool isVerified;
  final bool isFollowing;

  const WhoToFollowModel({
    required this.id,
    required this.displayName,
    required this.username,
    this.bio,
    required this.avatarUrl,
    this.isVerified = false,
    this.isFollowing = false,
  });

  factory WhoToFollowModel.fromJson(Map<String, dynamic> json) {
    return WhoToFollowModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      username: json['username'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatarUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'isFollowing': isFollowing,
    };
  }

  WhoToFollowModel copyWith({
    String? id,
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    bool? isVerified,
    bool? isFollowing,
  }) {
    return WhoToFollowModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

