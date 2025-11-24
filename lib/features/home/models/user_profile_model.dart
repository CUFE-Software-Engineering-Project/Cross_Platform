class MediaModel {
  final String id;
  final String name;
  final String keyName;
  final String type;

  MediaModel({
    required this.id,
    required this.name,
    required this.keyName,
    required this.type,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      keyName: json['keyName']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'keyName': keyName, 'type': type};
  }
}

class UserProfileModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? bio;
  final String? website;
  final bool verified;
  final String? address;
  final bool protectedAccount;
  final String joinDate;
  final String? profileMediaId;
  final MediaModel? profileMedia;
  final String? resolvedProfilePhotoUrl;
  final String? coverMediaId;
  final MediaModel? coverMedia;
  final int followersCount;
  final int followingCount;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.bio,
    this.website,
    required this.verified,
    this.address,
    required this.protectedAccount,
    required this.joinDate,
    this.profileMediaId,
    this.profileMedia,
    this.resolvedProfilePhotoUrl,
    this.coverMediaId,
    this.coverMedia,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  String? get profilePhotoUrl {
    if (resolvedProfilePhotoUrl != null &&
        resolvedProfilePhotoUrl!.isNotEmpty) {
      print('🖼️ Profile photo URL (resolved): $resolvedProfilePhotoUrl');
      return resolvedProfilePhotoUrl;
    }

    if (profileMedia != null && profileMedia!.keyName.isNotEmpty) {
      final url =
          'https://litex.siematworld.online/media/${profileMedia!.keyName}';
      print('🖼️ Profile photo URL (keyName): $url');
      return url;
    }
    print('⚠️ No profile media found');
    return null;
  }

  String? get coverPhotoUrl {
    if (coverMedia != null) {
      return 'https://litex.siematworld.online/media/${coverMedia!.keyName}';
    }
    return null;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    print('📋 Parsing user profile JSON...');
    print('  - profileMediaId: ${json['profileMediaId']}');
    print('  - profileMedia: ${json['profileMedia']}');

    // Parse followers and following counts from _count object or direct fields
    int followersCount = 0;
    int followingCount = 0;

    if (json['_count'] != null && json['_count'] is Map) {
      final countMap = json['_count'] as Map<String, dynamic>;
      followersCount = countMap['followers'] as int? ?? 0;
      followingCount = countMap['followings'] as int? ?? 0;
    } else {
      followersCount = json['followersCount'] as int? ?? 0;
      followingCount = json['followingCount'] as int? ?? 0;
    }

    final profileMedia = json['profileMedia'] != null
        ? MediaModel.fromJson(json['profileMedia'] as Map<String, dynamic>)
        : null;

    print('  - Parsed profileMedia: ${profileMedia?.keyName}');

    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      bio: json['bio']?.toString(),
      website: json['website']?.toString(),
      verified: json['verified'] as bool? ?? false,
      address: json['address']?.toString(),
      protectedAccount: json['protectedAccount'] as bool? ?? false,
      joinDate: json['joinDate']?.toString() ?? '',
      profileMediaId: json['profileMediaId']?.toString(),
      profileMedia: profileMedia,
      resolvedProfilePhotoUrl: null,
      coverMediaId: json['coverMediaId']?.toString(),
      coverMedia: json['coverMedia'] != null
          ? MediaModel.fromJson(json['coverMedia'] as Map<String, dynamic>)
          : null,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'website': website,
      'verified': verified,
      'address': address,
      'protectedAccount': protectedAccount,
      'joinDate': joinDate,
      'profileMediaId': profileMediaId,
      'profileMedia': profileMedia?.toJson(),
      'resolvedProfilePhotoUrl': resolvedProfilePhotoUrl,
      'coverMediaId': coverMediaId,
      'coverMedia': coverMedia?.toJson(),
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? bio,
    String? website,
    bool? verified,
    String? address,
    bool? protectedAccount,
    String? joinDate,
    String? profileMediaId,
    MediaModel? profileMedia,
    String? resolvedProfilePhotoUrl,
    String? coverMediaId,
    MediaModel? coverMedia,
    int? followersCount,
    int? followingCount,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      verified: verified ?? this.verified,
      address: address ?? this.address,
      protectedAccount: protectedAccount ?? this.protectedAccount,
      joinDate: joinDate ?? this.joinDate,
      profileMediaId: profileMediaId ?? this.profileMediaId,
      profileMedia: profileMedia ?? this.profileMedia,
      resolvedProfilePhotoUrl:
          resolvedProfilePhotoUrl ?? this.resolvedProfilePhotoUrl,
      coverMediaId: coverMediaId ?? this.coverMediaId,
      coverMedia: coverMedia ?? this.coverMedia,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
