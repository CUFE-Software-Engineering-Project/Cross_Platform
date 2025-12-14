class UserSuggestion {
  final String id;
  final String username;
  final String name;
  final bool verified;
  final String? bio;
  final ProfileMedia? profileMedia;
  final UserCount count;
  final bool isFollower;
  final bool isFollowing;

  const UserSuggestion({
    required this.id,
    required this.username,
    required this.name,
    this.verified = false,
    this.bio,
    this.profileMedia,
    required this.count,
    this.isFollower = false,
    this.isFollowing = false,
  });

  factory UserSuggestion.fromJson(Map<String, dynamic> json) {
    return UserSuggestion(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      verified: json['verified'] == true,
      bio: json['bio']?.toString(),
      profileMedia: json['profileMedia'] != null
          ? ProfileMedia.fromJson(json['profileMedia'] as Map<String, dynamic>)
          : null,
      count: json['_count'] != null
          ? UserCount.fromJson(json['_count'] as Map<String, dynamic>)
          : const UserCount(followers: 0),
      isFollower: json['isFollower'] == true,
      isFollowing: json['isFollowing'] == true,
    );
  }

  String get profileImageUrl {
    if (profileMedia?.keyName != null) {
      return 'https://litex.siematworld.online/media/${profileMedia!.keyName}';
    }
    return '';
  }
}

class ProfileMedia {
  final String id;
  final String keyName;

  const ProfileMedia({required this.id, required this.keyName});

  factory ProfileMedia.fromJson(Map<String, dynamic> json) {
    return ProfileMedia(
      id: json['id']?.toString() ?? '',
      keyName: json['keyName']?.toString() ?? '',
    );
  }
}

class UserCount {
  final int followers;

  const UserCount({required this.followers});

  factory UserCount.fromJson(Map<String, dynamic> json) {
    final followersValue = json['followers'];
    int followers = 0;
    if (followersValue is int) {
      followers = followersValue;
    } else if (followersValue is double) {
      followers = followersValue.round();
    } else if (followersValue is String) {
      followers = int.tryParse(followersValue) ?? 0;
    }

    return UserCount(followers: followers);
  }
}
