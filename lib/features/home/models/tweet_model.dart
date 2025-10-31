import 'package:hive_ce/hive.dart';

part 'tweet_model.g.dart';

@HiveType(typeId: 0)
class TweetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String authorName;

  @HiveField(3)
  final String authorUsername;

  @HiveField(4)
  final String authorAvatar;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  int likes;

  @HiveField(7)
  int retweets;

  @HiveField(8)
  final int replies;

  @HiveField(9)
  final List<String> images;

  @HiveField(10)
  bool isLiked;

  @HiveField(11)
  bool isRetweeted;

  @HiveField(12)
  final String? replyToId;

  @HiveField(13)
  List<String> replyIds;

  @HiveField(14)
  bool isBookmarked;

  @HiveField(15)
  final String? quotedTweetId;

  @HiveField(16)
  final TweetModel? quotedTweet;

  @HiveField(17)
  final int quotes;

  @HiveField(18)
  final int bookmarks;

  @HiveField(19)
  final String? userId;

  TweetModel({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.createdAt,
    this.likes = 0,
    this.retweets = 0,
    this.replies = 0,
    this.images = const [],
    this.isLiked = false,
    this.isRetweeted = false,
    this.replyToId,
    this.replyIds = const [],
    this.isBookmarked = false,
    this.quotedTweetId,
    this.quotedTweet,
    this.quotes = 0,
    this.bookmarks = 0,
    this.userId,
  });

  TweetModel copyWith({
    String? id,
    String? content,
    String? authorName,
    String? authorUsername,
    String? authorAvatar,
    DateTime? createdAt,
    int? likes,
    int? retweets,
    int? replies,
    List<String>? images,
    bool? isLiked,
    bool? isRetweeted,
    String? replyToId,
    List<String>? replyIds,
    bool? isBookmarked,
    String? quotedTweetId,
    TweetModel? quotedTweet,
    int? quotes,
    int? bookmarks,
    String? userId,
  }) {
    return TweetModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      retweets: retweets ?? this.retweets,
      replies: replies ?? this.replies,
      images: images ?? this.images,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      replyToId: replyToId ?? this.replyToId,
      replyIds: replyIds ?? this.replyIds,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      quotedTweetId: quotedTweetId ?? this.quotedTweetId,
      quotedTweet: quotedTweet ?? this.quotedTweet,
      quotes: quotes ?? this.quotes,
      bookmarks: bookmarks ?? this.bookmarks,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'retweets': retweets,
      'replies': replies,
      'images': images,
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'replyToId': replyToId,
      'replyIds': replyIds,
      'isBookmarked': isBookmarked,
      'quotedTweetId': quotedTweetId,
      'quotedTweet': quotedTweet?.toJson(),
      'quotes': quotes,
      'bookmarks': bookmarks,
      'userId': userId,
    };
  }

  factory TweetModel.fromJson(Map<String, dynamic> json) {

    final user = json['user'] as Map<String, dynamic>?;

    if (user != null) {

    } else {

    }

    return TweetModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',

      authorName:
          user?['name']?.toString() ??
          json['authorName']?.toString() ??
          'Unknown User',
      authorUsername:
          user?['username']?.toString() ??
          json['authorUsername']?.toString() ??
          'unknown',
      authorAvatar:
          user?['profileMedia']?.toString() ??
          user?['profilePicture']?.toString() ??
          json['authorAvatar']?.toString() ??
          '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: (json['likesCount'] ?? json['likes'] ?? 0) as int,
      retweets: (json['retweetCount'] ?? json['retweets'] ?? 0) as int,
      replies: (json['repliesCount'] ?? json['replies'] ?? 0) as int,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : (json['media'] != null ? List<String>.from(json['media']) : []),
      isLiked: json['isLiked'] as bool? ?? false,
      isRetweeted: json['isRetweeted'] as bool? ?? false,

      replyToId: json['parentId']?.toString() ?? json['replyToId']?.toString(),
      replyIds: json['replyIds'] != null
          ? List<String>.from(json['replyIds'])
          : [],
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      quotedTweetId: json['quotedTweetId']?.toString(),
      quotedTweet: json['quotedTweet'] != null
          ? TweetModel.fromJson(json['quotedTweet'] as Map<String, dynamic>)
          : null,

      quotes: (json['quotesCount'] ?? json['quotes'] ?? 0) as int,
      bookmarks: (json['bookmarksCount'] ?? json['bookmarks'] ?? 0) as int,

      userId: user?['id']?.toString() ?? json['userId']?.toString(),
    )..let((tweet) {

    });
  }
}

extension _LetExtension<T> on T {
  T let(void Function(T) block) {
    block(this);
    return this;
  }
}
