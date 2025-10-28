/// Notification type enumeration
/// Follows SOLID principles - Single Responsibility
enum NotificationType {
  like,
  repost,
  follow,
  mention,
  reply,
}

/// User model for notifications
/// Follows SOLID principles - Single Responsibility
class User {
  final String id;
  final String username;
  final String name;
  final String avatarUrl;
  final bool isVerified;

  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarUrl,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? avatarUrl,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, isVerified: $isVerified)';
  }
}

/// App notification model for UI display
/// Follows SOLID principles - Single Responsibility
class AppNotification {
  final String id;
  final NotificationType type;
  final User user;
  final String content;
  final String timestamp;
  final bool isRead;
  final String? postSnippet;
  final String? tweetId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.user,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.postSnippet,
    this.tweetId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: _parseNotificationType(json['type']),
      user: User.fromJson(json['user'] ?? {}),
      content: json['content']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      isRead: json['isRead'] == true,
      postSnippet: json['postSnippet']?.toString(),
      tweetId: json['tweetId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'user': user.toJson(),
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'postSnippet': postSnippet,
      'tweetId': tweetId,
    };
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    User? user,
    String? content,
    String? timestamp,
    bool? isRead,
    String? postSnippet,
    String? tweetId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      user: user ?? this.user,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      postSnippet: postSnippet ?? this.postSnippet,
      tweetId: tweetId ?? this.tweetId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, user: $user, isRead: $isRead)';
  }

  static NotificationType _parseNotificationType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'repost':
        return NotificationType.repost;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'reply':
        return NotificationType.reply;
      default:
          return NotificationType.like;
      }
    }
    return NotificationType.like;
  }
}

/// Backend notification model matching Prisma schema
/// Follows SOLID principles - Single Responsibility
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  final String? tweetId;
  final String? actorId;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
    this.tweetId,
    this.actorId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] == true,
      tweetId: json['tweetId']?.toString(),
      actorId: json['actorId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRead': isRead,
      if (tweetId != null) 'tweetId': tweetId!,
      if (actorId != null) 'actorId': actorId!,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
    String? tweetId,
    String? actorId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      tweetId: tweetId ?? this.tweetId,
      actorId: actorId ?? this.actorId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, type: $type, isRead: $isRead)';
  }
}

/// Notification input model for creating new notifications
/// Follows SOLID principles - Single Responsibility
class NotificationInputModel {
  final String userId;
  final String type;
  final String content;
  final String? tweetId;
  final String? actorId;

  const NotificationInputModel({
    required this.userId,
    required this.type,
    required this.content,
    this.tweetId,
    this.actorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'content': content,
      if (tweetId != null) 'tweetId': tweetId!,
      if (actorId != null) 'actorId': actorId!,
    };
  }

  NotificationInputModel copyWith({
    String? userId,
    String? type,
    String? content,
    String? tweetId,
    String? actorId,
  }) {
    return NotificationInputModel(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      tweetId: tweetId ?? this.tweetId,
      actorId: actorId ?? this.actorId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationInputModel &&
        other.userId == userId &&
        other.type == type &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(userId, type, content);

  @override
  String toString() {
    return 'NotificationInputModel(userId: $userId, type: $type, content: $content)';
  }
}

/// Notification state model for managing UI state
/// Follows SOLID principles - Single Responsibility
class NotificationState {
  final List<AppNotification> notifications;
  final int unseenCount;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const NotificationState({
    this.notifications = const [],
    this.unseenCount = 0,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unseenCount,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unseenCount: unseenCount ?? this.unseenCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// Initial state
  factory NotificationState.initial() => const NotificationState();

  /// Loading state
  NotificationState loading() => copyWith(isLoading: true, error: null);

  /// Success state
  NotificationState success({
    required List<AppNotification> notifications,
    int? unseenCount,
  }) {
    return copyWith(
      notifications: notifications,
      unseenCount: unseenCount ?? this.unseenCount,
      isLoading: false,
      error: null,
      isInitialized: true,
    );
  }

  /// Error state
  NotificationState failure(String error) => copyWith(
        isLoading: false,
        error: error,
      );

  @override
  String toString() {
    return 'NotificationState(notifications: ${notifications.length}, unseenCount: $unseenCount, isLoading: $isLoading, error: $error)';
  }
}
