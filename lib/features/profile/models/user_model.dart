class UserModel {
  final String displayName;
  final String userName;
  final String image;
  final String bio;
  final bool isFollowing;
  final bool isFollower;
  final bool isVerified;

  UserModel({
    required this.displayName,
    required this.userName,
    required this.image,
    required this.bio,
    this.isFollowing = false,
    this.isFollower = false,
    this.isVerified = false,
  });

  UserModel copyWith({
    String? displayName,
    String? userName,
    String? image,
    String? bio,
    bool? isFollowing,
    bool? isFollower,
    bool? isVerified,
  }) {
    return UserModel(
      displayName: displayName ?? this.displayName,
      userName: userName ?? this.userName,
      image: image ?? this.image,
      bio: bio ?? this.bio,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'userName': userName,
      'image': image,
      'bio': bio,
      'isFollowing': isFollowing,
      'isFollower': isFollower,
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      displayName: json['name'] ?? '',
      userName: json['username'] ?? '',
      image: json['photo'] ?? '',
      bio: json['bio'] ?? '',
      isFollowing: json['isFollowing'] ?? false,
      isFollower: json['isFollower'] ?? false,
      isVerified: json['verified'] ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(displayName: $displayName, userName: $userName, image: $image, bio: $bio, isFollowing: $isFollowing, isFollower: $isFollower, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.displayName == displayName &&
        other.userName == userName &&
        other.image == image &&
        other.bio == bio &&
        other.isFollowing == isFollowing &&
        other.isFollower == isFollower &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        userName.hashCode ^
        image.hashCode ^
        bio.hashCode ^
        isFollowing.hashCode ^
        isFollower.hashCode ^
        isVerified.hashCode;
  }
}
