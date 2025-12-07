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

class EmbeddedTweetUser {
  final String id;
  final String name;
  final String username;
  final String profileMediaId;
  final bool verified;
  final bool protectedAccount;

  EmbeddedTweetUser({
    required this.id,
    required this.name,
    required this.username,
    required this.profileMediaId,
    required this.verified,
    required this.protectedAccount,
  });

  factory EmbeddedTweetUser.fromJson(Map<String, dynamic> json) {
    return EmbeddedTweetUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileMediaId: (json['profileMedia'] is Map
              ? (json['profileMedia']['id']?.toString())
              : json['profileMedia']?.toString()) ??
          '',
      verified: json['verified'] as bool? ?? false,
      protectedAccount: json['protectedAccount'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'EmbeddedTweetUser(id: $id, name: $name, username: $username, profileMediaId: $profileMediaId, verified: $verified, protectedAccount: $protectedAccount)';
}

class EmbeddedTweet {
  final String id;
  final String content;
  final String createdAt;
  final int likesCount;
  final int retweetCount;
  final int repliesCount;
  final int quotesCount;
  final String replyControl;
  final String? parentId;
  final String tweetType;
  final EmbeddedTweetUser user;
  final List<String> mediaIds;
  final bool isLiked;
  final bool isRetweeted;
  final bool isBookmarked;

  EmbeddedTweet({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.retweetCount,
    required this.repliesCount,
    required this.quotesCount,
    required this.replyControl,
    required this.parentId,
    required this.tweetType,
    required this.user,
    required this.mediaIds,
    required this.isLiked,
    required this.isRetweeted,
    required this.isBookmarked,
  });

  factory EmbeddedTweet.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] is Map)
        ? (json['user'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final mediaIdsRaw = json['mediaIds'];
    final mediaIds = <String>[];
    if (mediaIdsRaw is List) {
      for (final m in mediaIdsRaw) {
        mediaIds.add(m.toString());
      }
    }

    return EmbeddedTweet(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      retweetCount: (json['retweetCount'] as num?)?.toInt() ?? 0,
      repliesCount: (json['repliesCount'] as num?)?.toInt() ?? 0,
      quotesCount: (json['quotesCount'] as num?)?.toInt() ?? 0,
      replyControl: json['replyControl']?.toString() ?? 'EVERYONE',
      parentId: json['parentId']?.toString(),
      tweetType: json['tweetType']?.toString() ?? 'TWEET',
      user: EmbeddedTweetUser.fromJson(userJson),
      mediaIds: mediaIds,
      isLiked: json['isLiked'] as bool? ?? false,
      isRetweeted: json['isRetweeted'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'EmbeddedTweet(id: $id, content: $content, likesCount: $likesCount, retweetCount: $retweetCount, repliesCount: $repliesCount, isLiked: $isLiked, isRetweeted: $isRetweeted, isBookmarked: $isBookmarked)';
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
  final bool isBookmarked;
  final EmbeddedTweet? tweet;

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
    this.isBookmarked = false,
    this.tweet,
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
    bool? isBookmarked,
    EmbeddedTweet? tweet,
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
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tweet: tweet ?? this.tweet,
    );
  }

  @override
  String toString() =>
      'NotificationItem(title: $title, body: $body, isRead: $isRead, mediaUrl: $mediaUrl, tweetId: $tweetId, actor: $actor, targetUsername: $targetUsername, isLiked: $isLiked, isRetweeted: $isRetweeted, tweet: $tweet)';
}
