import 'package:lite_x/features/profile/models/user_model.dart';

class MutedUsersResponse {
  final List<UserModel> users;
  final String? nextCursor;
  final bool hasMore;

  const MutedUsersResponse({
    required this.users,
    required this.nextCursor,
    required this.hasMore,
  });

  factory MutedUsersResponse.empty() => const MutedUsersResponse(
        users: [],
        nextCursor: null,
        hasMore: false,
      );

  factory MutedUsersResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['users'] as List<dynamic>? ?? [];
    return MutedUsersResponse(
      users: raw.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'users': users.map((e) => e.toJson()).toList(),
        'nextCursor': nextCursor,
        'hasMore': hasMore,
      };

  MutedUsersResponse copyWith({
    List<UserModel>? users,
    String? nextCursor,
    bool? hasMore,
  }) => MutedUsersResponse(
        users: users ?? this.users,
        nextCursor: nextCursor ?? this.nextCursor,
        hasMore: hasMore ?? this.hasMore,
      );
}
