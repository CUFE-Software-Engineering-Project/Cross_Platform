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

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'keyName': keyName,
    };
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

class Tweet {
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
  final TweetUser user;
  final List<String> mediaIds;
  final bool isLiked;
  final bool isRetweeted;
  final bool isBookmarked;

  Tweet({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.retweetCount,
    required this.repliesCount,
    required this.quotesCount,
    required this.replyControl,
    this.parentId,
    required this.tweetType,
    required this.user,
    required this.mediaIds,
    required this.isLiked,
    required this.isRetweeted,
    required this.isBookmarked,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'],
      content: json['content'],
      createdAt: json['createdAt'],
      likesCount: json['likesCount'],
      retweetCount: json['retweetCount'],
      repliesCount: json['repliesCount'],
      quotesCount: json['quotesCount'],
      replyControl: json['replyControl'],
      parentId: json['parentId'],
      tweetType: json['tweetType'],
      user: TweetUser.fromJson(json['user']),
      mediaIds: List<String>.from(json['mediaIds'] ?? []),
      isLiked: json['isLiked'],
      isRetweeted: json['isRetweeted'],
      isBookmarked: json['isBookmarked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'retweetCount': retweetCount,
      'repliesCount': repliesCount,
      'quotesCount': quotesCount,
      'replyControl': replyControl,
      'parentId': parentId,
      'tweetType': tweetType,
      'user': user.toJson(),
      'mediaIds': mediaIds,
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'isBookmarked': isBookmarked,
    };
  }

  Tweet copyWith({
    String? id,
    String? content,
    String? createdAt,
    int? likesCount,
    int? retweetCount,
    int? repliesCount,
    int? quotesCount,
    String? replyControl,
    String? parentId,
    String? tweetType,
    TweetUser? user,
    List<String>? mediaIds,
    bool? isLiked,
    bool? isRetweeted,
    bool? isBookmarked,
  }) {
    return Tweet(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      retweetCount: retweetCount ?? this.retweetCount,
      repliesCount: repliesCount ?? this.repliesCount,
      quotesCount: quotesCount ?? this.quotesCount,
      replyControl: replyControl ?? this.replyControl,
      parentId: parentId ?? this.parentId,
      tweetType: tweetType ?? this.tweetType,
      user: user ?? this.user,
      mediaIds: mediaIds ?? this.mediaIds,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class TweetUser {
  final String id;
  final String name;
  final String username;
  final TweetMedia? profileMedia;
  final bool verified;
  final bool protectedAccount;

  TweetUser({
    required this.id,
    required this.name,
    required this.username,
    this.profileMedia,
    required this.verified,
    required this.protectedAccount,
  });

  factory TweetUser.fromJson(Map<String, dynamic> json) {
    return TweetUser(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      profileMedia: json['profileMedia'] != null
          ? TweetMedia.fromJson(json['profileMedia'])
          : null,
      verified: json['verified'],
      protectedAccount: json['protectedAccount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profileMedia': profileMedia?.toJson(),
      'verified': verified,
      'protectedAccount': protectedAccount,
    };
  }

  TweetUser copyWith({
    String? id,
    String? name,
    String? username,
    TweetMedia? profileMedia,
    bool? verified,
    bool? protectedAccount,
  }) {
    return TweetUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      profileMedia: profileMedia ?? this.profileMedia,
      verified: verified ?? this.verified,
      protectedAccount: protectedAccount ?? this.protectedAccount,
    );
  }
}

class TweetMedia {
  final String id;

  TweetMedia({required this.id});

  factory TweetMedia.fromJson(Map<String, dynamic> json) {
    return TweetMedia(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  TweetMedia copyWith({String? id}) {
    return TweetMedia(id: id ?? this.id);
  }
}

class MentionItem {
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
  final TweetUser user;
  final List<String> mediaIds;      // original media IDs
  final List<MediaInfo> mediaUrls;  // list of MediaInfo objects with actual URLs
  final bool isLiked;
  final bool isRetweeted;
  final bool isBookmarked;

  MentionItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.retweetCount,
    required this.repliesCount,
    required this.quotesCount,
    required this.replyControl,
    this.parentId,
    required this.tweetType,
    required this.user,
    required this.mediaIds,
    required this.mediaUrls,
    required this.isLiked,
    required this.isRetweeted,
    required this.isBookmarked,
  });

  factory MentionItem.fromJson(Map<String, dynamic> json) {
    return MentionItem(
      id: json['id'],
      content: json['content'],
      createdAt: json['createdAt'],
      likesCount: json['likesCount'],
      retweetCount: json['retweetCount'],
      repliesCount: json['repliesCount'],
      quotesCount: json['quotesCount'],
      replyControl: json['replyControl'],
      parentId: json['parentId'],
      tweetType: json['tweetType'],
      user: TweetUser.fromJson(json['user']),
      mediaIds: List<String>.from(json['mediaIds'] ?? []),
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => MediaInfo.fromJson(e))
              .toList() ??
          [],
      isLiked: json['isLiked'],
      isRetweeted: json['isRetweeted'],
      isBookmarked: json['isBookmarked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'retweetCount': retweetCount,
      'repliesCount': repliesCount,
      'quotesCount': quotesCount,
      'replyControl': replyControl,
      'parentId': parentId,
      'tweetType': tweetType,
      'user': user.toJson(),
      'mediaIds': mediaIds,
      'mediaUrls': mediaUrls.map((e) => e.toJson()).toList(),
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'isBookmarked': isBookmarked,
    };
  }

  MentionItem copyWith({
    String? id,
    String? content,
    String? createdAt,
    int? likesCount,
    int? retweetCount,
    int? repliesCount,
    int? quotesCount,
    String? replyControl,
    String? parentId,
    String? tweetType,
    TweetUser? user,
    List<String>? mediaIds,
    List<MediaInfo>? mediaUrls,
    bool? isLiked,
    bool? isRetweeted,
    bool? isBookmarked,
  }) {
    return MentionItem(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      retweetCount: retweetCount ?? this.retweetCount,
      repliesCount: repliesCount ?? this.repliesCount,
      quotesCount: quotesCount ?? this.quotesCount,
      replyControl: replyControl ?? this.replyControl,
      parentId: parentId ?? this.parentId,
      tweetType: tweetType ?? this.tweetType,
      user: user ?? this.user,
      mediaIds: mediaIds ?? this.mediaIds,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }


}
