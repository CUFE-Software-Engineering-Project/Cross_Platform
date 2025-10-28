import '../../../core/models/usermodel.dart';

class FollowerModel {
  final UserModel user;
  final bool isFollowing; // You are following this user
  final bool isFollower;  // This user is following you
  final DateTime? followedAt;

  FollowerModel({
    required this.user,
    required this.isFollowing,
    required this.isFollower,
    this.followedAt,
  });

  // JSON serialization
  factory FollowerModel.fromJson(Map<String, dynamic> json) {
    return FollowerModel(
      user: UserModel.fromJson(json['user'] ?? UserModel(name: "", email: "", dob: "", username: "")),
      isFollowing: json['isFollowing'] ?? false,
      isFollower: json['isFollower'] ?? false,
      followedAt: json['followedAt'] != null
          ? DateTime.parse(json['followedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'isFollowing': isFollowing,
      'isFollower': isFollower,
      'followedAt': followedAt?.toIso8601String(),
    };
  }

  // Copy with method for easy updates
  FollowerModel copyWith({
    UserModel? user,
    bool? isFollowing,
    bool? isFollower,
    DateTime? followedAt,
  }) {
    return FollowerModel(
      user: user ?? this.user,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollower: isFollower ?? this.isFollower,
      followedAt: followedAt ?? this.followedAt,
    );
  }


  // Empty follower
  static FollowerModel empty() {
    return FollowerModel(
      user: UserModel(name: '', email: '', dob: '', username: ''),
      isFollowing: false,
      isFollower: false,
    );
  }


}