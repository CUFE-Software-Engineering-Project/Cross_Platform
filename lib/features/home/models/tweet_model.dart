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
    };
  }

  factory TweetModel.fromJson(Map<String, dynamic> json) {
    return TweetModel(
      id: json['id'],
      content: json['content'],
      authorName: json['authorName'],
      authorUsername: json['authorUsername'],
      authorAvatar: json['authorAvatar'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      retweets: json['retweets'] ?? 0,
      replies: json['replies'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      isLiked: json['isLiked'] ?? false,
      isRetweeted: json['isRetweeted'] ?? false,
      replyToId: json['replyToId'],
      replyIds: List<String>.from(json['replyIds'] ?? []),
    );
  }
}
