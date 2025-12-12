class RepostedByUserModel {
  final String id;
  final String username;
  final String name;
  final String avatarId;
  final bool verified;
  final bool protectedAccount;
  final bool isFollowed;

  const RepostedByUserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarId,
    required this.verified,
    required this.protectedAccount,
    required this.isFollowed,
  });

  RepostedByUserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? avatarId,
    bool? verified,
    bool? protectedAccount,
    bool? isFollowed,
  }) {
    return RepostedByUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      verified: verified ?? this.verified,
      protectedAccount: protectedAccount ?? this.protectedAccount,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  factory RepostedByUserModel.fromJson(Map<String, dynamic> json) {
    final profileMedia = json['profileMedia'];
    final profileMediaId = json['profileMediaId'];

    String avatarId = '';
    if (profileMediaId is String) {
      avatarId = profileMediaId;
    } else if (profileMedia is Map<String, dynamic>) {
      avatarId = profileMedia['id']?.toString() ?? '';
    }

    final isFollowed = (json['isFollowed'] ?? json['isFollowing']) == true;

    return RepostedByUserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarId: avatarId,
      verified: json['verified'] == true,
      protectedAccount: json['protectedAccount'] == true,
      isFollowed: isFollowed,
    );
  }
}
