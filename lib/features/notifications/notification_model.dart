class MediaInfo {
  final String url;
  final String keyName;

  MediaInfo({required this.url, required this.keyName});

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(url: json['url'], keyName: json['keyName']);
  }

  MediaInfo copyWith({String? url, String? keyName}) {
    return MediaInfo(url: url ?? this.url, keyName: keyName ?? this.keyName);
  }

  @override
  String toString() => 'MediaInfo(url: $url, keyName: $keyName)';
}

class Actor {
  final String name;
  final String username;
  final String profileMediaId;
  final MediaInfo? media;

  Actor({
    required this.name,
    required this.username,
    required this.profileMediaId,
    this.media,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'] ?? '',
      username: json['username']?.toString() ?? '',
      profileMediaId: json['profileMediaId']?.toString() ?? '',
    );
  }

  Actor copyWith({
    String? name,
    String? username,
    String? profileMediaId,
    MediaInfo? media,
  }) {
    return Actor(
      name: name ?? this.name,
      username: username ?? this.username,
      profileMediaId: profileMediaId ?? this.profileMediaId,
      media: media ?? this.media,
    );
  }

  @override
  String toString() =>
      'Actor(name: $name, username: $username, profileMediaId: $profileMediaId, media: $media)';
}

class Notification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final String userId;
  final String? tweetId;
  final String actorId;
  final Actor actor;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.userId,
    this.tweetId,
    required this.actorId,
    required this.actor,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      tweetId: json['tweetId']?.toString(),
      actorId: json['actorId']?.toString() ?? '',
      actor: Actor.fromJson(json['actor'] ?? {}),
    );
  }

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    String? createdAt,
    String? userId,
    String? tweetId,
    String? actorId,
    Actor? actor,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      tweetId: tweetId,
      actorId: actorId ?? this.actorId,
      actor: actor ?? this.actor,
    );
  }

  @override
  String toString() =>
      'Notification(id: $id, title: $title, isRead: $isRead, actor: $actor)';
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String mediaUrl;
  final String? tweetId;
  final String createdAt;
  final Actor actor;
  final String? targetUsername;
  final String? quotedAuthor;
  final String? quotedContent;
  final int repliesCount;
  final int repostsCount;
  final int likesCount;
  final bool isLiked;
  final bool isRetweeted;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.mediaUrl,
    this.tweetId,
    required this.createdAt,
    required this.actor,
    this.targetUsername,
    this.quotedAuthor,
    this.quotedContent,
    this.repliesCount = 0,
    this.repostsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.isRetweeted = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    String? mediaUrl,
    String? tweetId,
    String? createdAt,
    Actor? actor,
    String? targetUsername,
    String? quotedAuthor,
    String? quotedContent,
    int? repliesCount,
    int? repostsCount,
    int? likesCount,
    bool? isLiked,
    bool? isRetweeted,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      tweetId: tweetId ?? this.tweetId,
      createdAt: createdAt ?? this.createdAt,
      actor: actor ?? this.actor,
      targetUsername: targetUsername ?? this.targetUsername,
      quotedAuthor: quotedAuthor ?? this.quotedAuthor,
      quotedContent: quotedContent ?? this.quotedContent,
      repliesCount: repliesCount ?? this.repliesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
    );
  }

  @override
  String toString() =>
      'NotificationItem(title: $title, body: $body, isRead: $isRead, mediaUrl: $mediaUrl, tweetId: $tweetId, actor: $actor, targetUsername: $targetUsername, isLiked: $isLiked, isRetweeted: $isRetweeted)';
}
