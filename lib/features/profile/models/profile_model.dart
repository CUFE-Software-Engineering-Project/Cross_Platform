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
  });

  // JSON serialization
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String joinedDateFormated;
    String birthDateFormated;
    if (json['joinedDate'] != null) {
      DateTime joinedDate = DateTime.parse(json['joinedDate']);
      joinedDateFormated =
          "${mapMonth(joinedDate.month)} ${joinedDate.day}, ${joinedDate.year}";
    } else
      joinedDateFormated = "";

    if (json['birthDate'] != null) {
      DateTime birthDate = DateTime.parse(json['birthDate']);
      birthDateFormated =
          "${mapMonth(birthDate.month)} ${birthDate.day}, ${birthDate.year}";
    } else
      birthDateFormated = "";

    return ProfileModel(
      id: json['id'] ?? '',
      username: '@' + (json['username'] ?? ''),
      displayName: json['displayName'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      tweetsCount: json['tweetsCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      joinedDate: joinedDateFormated,
      website: json['website'] ?? '',
      location: json['location'] ?? '',
      postCount: json['postCount'] ?? 0,
      birthDate: birthDateFormated,
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'username': username,
  //     'displayName': displayName,
  //     'bio': bio,
  //     'avatarUrl': avatarUrl,
  //     'bannerUrl': bannerUrl,
  //     'followersCount': followersCount,
  //     'followingCount': followingCount,
  //     'tweetsCount': tweetsCount,
  //     'isVerified': isVerified,
  //     'joinedDate': joinedDate,
  //     'website': website,
  //     'location': location,
  //   };
  // }

  // Helper method for empty profile
  static ProfileModel empty() {
    return ProfileModel(
      id: '',
      username: '',
      displayName: '',
      bio: '',
      avatarUrl: '',
      bannerUrl: '',
      followersCount: 0,
      followingCount: 0,
      tweetsCount: 0,
      isVerified: false,
      joinedDate: "",
      website: '',
      location: '',
      postCount: 0,
      birthDate: "",
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
