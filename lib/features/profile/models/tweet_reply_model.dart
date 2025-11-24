class TweetReplyModel {
  final String id;
  final String userId;
  final String content;
  final String createdAt;
  final String lastActivityAt;
  final int likesCount;
  final int retweetCount;
  final int repliesCount;
  final int quotesCount;
  final String replyControl;
  final String parentId; 
  final String tweetType;
  final UserReplyModel user;

  TweetReplyModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.lastActivityAt,
    required this.likesCount,
    required this.retweetCount,
    required this.repliesCount,
    required this.quotesCount,
    required this.replyControl,
    required this.parentId,
    required this.tweetType,
    required this.user,
  });

  factory TweetReplyModel.fromJson(Map<String, dynamic> json) {
    return TweetReplyModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      lastActivityAt: json['lastActivityAt'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      retweetCount: json['retweetCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      quotesCount: json['quotesCount'] ?? 0,
      replyControl: json['replyControl'] ?? '',
      parentId: json['parentId'] ?? '',
      tweetType: json['tweetType'] ?? '',
      user: UserReplyModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'lastActivityAt': lastActivityAt,
      'likesCount': likesCount,
      'retweetCount': retweetCount,
      'repliesCount': repliesCount,
      'quotesCount': quotesCount,
      'replyControl': replyControl,
      'parentId': parentId,
      'tweetType': tweetType,
      'user': user.toJson(),
    };
  }
}

class UserReplyModel {
  final String id;
  final String name;
  final String username;
  final String? profileMedia;
  final bool protectedAccount;
  final bool verified;

  UserReplyModel({
    required this.id,
    required this.name,
    required this.username,
    required this.profileMedia,
    required this.protectedAccount,
    required this.verified,
  });

  factory UserReplyModel.fromJson(Map<String, dynamic> json) {
    return UserReplyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profileMedia: json['profileMedia'],
      protectedAccount: json['protectedAccount'] ?? false,
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profileMedia': profileMedia,
      'protectedAccount': protectedAccount,
      'verified': verified,
    };
  }
}
