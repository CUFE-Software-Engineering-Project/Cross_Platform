class MediaInfo {
  final String url;
  final String keyName;

  MediaInfo({required this.url, required this.keyName});

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      url: json['url'],
      keyName: json['keyName'],
    );
  }

  MediaInfo copyWith({
    String? url,
    String? keyName,
  }) {
    return MediaInfo(
      url: url ?? this.url,
      keyName: keyName ?? this.keyName,
    );
  }

  @override
  String toString() => 'MediaInfo(url: $url, keyName: $keyName)';
}

class Actor {
  final String name;
  final String profileMediaId;
  final MediaInfo? media;

  Actor({
    required this.name,
    required this.profileMediaId,
    this.media,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'] ?? '',
      profileMediaId: json['profileMediaId']?.toString() ?? '',
    );
  }

  Actor copyWith({
    String? name,
    String? profileMediaId,
    MediaInfo? media,
  }) {
    return Actor(
      name: name ?? this.name,
      profileMediaId: profileMediaId ?? this.profileMediaId,
      media: media ?? this.media,
    );
  }

  @override
  String toString() =>
      'Actor(name: $name, profileMediaId: $profileMediaId, media: $media)';
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

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.mediaUrl,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    String? mediaUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  String toString() =>
      'NotificationItem(title: $title, body: $body, isRead: $isRead, mediaUrl: $mediaUrl)';
}
