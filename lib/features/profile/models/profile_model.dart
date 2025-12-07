import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/profile/models/shared.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 15)
class ProfileModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String displayName;
  @HiveField(3)
  final String bio;
  @HiveField(4)
  final int followersCount;
  @HiveField(5)
  final int followingCount;
  @HiveField(6)
  final int tweetsCount;
  @HiveField(7)
  final bool isVerified;
  @HiveField(8)
  final String joinedDate;
  @HiveField(9)
  final String website;
  @HiveField(10)
  final String location;
  @HiveField(11)
  final int postCount;
  @HiveField(12)
  final String birthDate;
  @HiveField(13)
  final bool isFollowing;
  @HiveField(14)
  final bool isFollower;
  @HiveField(15)
  final bool protectedAccount;
  @HiveField(16)
  final bool isBlockedByMe;
  @HiveField(17)
  final bool isMutedByMe;
  @HiveField(18)
  final String email;
  @HiveField(19)
  final String avatarId;
  @HiveField(20)
  final String bannerId;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    // required this.avatarUrl,
    // required this.bannerUrl,
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
    required this.bannerId,
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
      // avatarUrl: json['f'] ?? '',
      // bannerUrl: json['f'] ?? '',
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
      avatarId: json["profileMediaId"] ?? "",
      bannerId: json["coverMediaId"] ?? "",
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
      // 'profilePhoto': avatarUrl,
      // 'cover': bannerUrl,
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
    String? bannerId,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
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
      bannerId: bannerId ?? this.bannerId,
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
