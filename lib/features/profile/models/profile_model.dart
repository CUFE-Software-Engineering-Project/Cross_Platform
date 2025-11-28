import 'package:lite_x/features/profile/models/shared.dart';

class ProfileModel {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String bannerUrl;
  final int followersCount;
  final int followingCount;
  final int tweetsCount;
  final bool isVerified;
  final String joinedDate;
  final String website;
  final String location;
  final int postCount;
  final String birthDate;
  final bool isFollowing;
  final bool isFollower;
  final bool protectedAccount;
  final bool isBlockedByMe;
  final bool isMutedByMe;
  final String email;
  final String avatarId;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.followersCount,
    required this.followingCount,
    required this.tweetsCount,
    required this.isVerified,
    required this.joinedDate,
    required this.website,
    required this.location,
    required this.postCount,
    required this.birthDate,
    required this.isFollowing,
    required this.isFollower,
    required this.protectedAccount,
    required this.isBlockedByMe,
    required this.isMutedByMe,
    required this.email,
    required this.avatarId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String joinedDateFormated;
    String birthDateFormated;

    if (json['joinDate'] != null) {
      DateTime joinedDate = DateTime.parse(json['joinDate']);
      joinedDateFormated = formatDate(joinedDate, DateFormatType.fullDate);
    } else {
      joinedDateFormated = "";
    }

    if (json['dateOfBirth'] != null) {
      DateTime birthDate = DateTime.parse(json['dateOfBirth']);
      birthDateFormated = formatDate(birthDate, DateFormatType.fullDate);
    } else {
      birthDateFormated = "";
    }

    return ProfileModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['name'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['profileMedia'] ?? '',
      bannerUrl: json['coverMedia'] ?? '',
      followersCount: json['_count'] != null
          ? json['_count']['followers'] ?? 0
          : 0,
      followingCount: json['_count'] != null
          ? json['_count']['followings'] ?? 0
          : 0,
      tweetsCount: json['tweetsCount'] ?? 0,
      isVerified: json['verified'] ?? false,
      joinedDate: joinedDateFormated,
      website: json['website'] ?? '',
      location: json['address'] ?? '',
      postCount: json['postCount'] ?? 0,
      birthDate: birthDateFormated,
      isFollowing: json['isFollowing'] ?? false,
      isFollower: json['isFollower'] ?? false,
      protectedAccount: json['protectedAccount'] ?? false,
      isBlockedByMe: json['blocked'] ?? false,
      isMutedByMe: json['muted'] ?? false,
      email: json["email"] ?? "",
      avatarId: json["avatarId"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    String? joinedDateIso;
    String? birthDateIso;

    if (joinedDate.isNotEmpty) {
      try {
        DateTime jd = DateTime.parse(joinedDate);
        joinedDateIso = jd.toIso8601String();
      } catch (_) {
        joinedDateIso = joinedDate;
      }
    }

    if (birthDate.isNotEmpty) {
      try {
        DateTime bd = DateTime.parse(birthDate);
        birthDateIso = bd.toIso8601String();
      } catch (_) {
        birthDateIso = birthDate;
      }
    }

    return {
      'id': id,
      'username': username,
      'name': displayName,
      'bio': bio,
      'profilePhoto': avatarUrl,
      'cover': bannerUrl,
      'verified': isVerified,
      'website': website,
      'address': location,
      'protectedAccount': true,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    int? followersCount,
    int? followingCount,
    int? tweetsCount,
    bool? isVerified,
    String? joinedDate,
    String? website,
    String? location,
    int? postCount,
    String? birthDate,
    bool? isFollowing,
    bool? isFollower,
    bool? protectedAccount,
    bool? isBlockedByMe,
    bool? isMutedByMe,
    String? email,
    String? avatarId,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tweetsCount: tweetsCount ?? this.tweetsCount,
      isVerified: isVerified ?? this.isVerified,
      joinedDate: joinedDate ?? this.joinedDate,
      website: website ?? this.website,
      location: location ?? this.location,
      postCount: postCount ?? this.postCount,
      birthDate: birthDate ?? this.birthDate,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      protectedAccount: protectedAccount ?? this.protectedAccount,
      isBlockedByMe: isBlockedByMe ?? this.isBlockedByMe,
      isMutedByMe: isMutedByMe ?? this.isMutedByMe,
      email: email ?? this.email,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}

String mapMonth(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  if (month < 1 || month > 12) return '';
  return months[month - 1];
}
