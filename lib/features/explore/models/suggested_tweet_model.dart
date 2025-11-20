class SuggestedTweetModel {
  final String id;
  final String username;
  final String handle;
  final String avatarUrl;
  final bool isVerified;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final int replyCount;
  final int repostCount;
  final int likeCount;
  final int shareCount;
  final String timestamp;
  final String? trendContext; // Context like "People also tweeting about this"

  const SuggestedTweetModel({
    required this.id,
    required this.username,
    required this.handle,
    required this.avatarUrl,
    this.isVerified = false,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.replyCount,
    required this.repostCount,
    required this.likeCount,
    required this.shareCount,
    required this.timestamp,
    this.trendContext,
  });

  factory SuggestedTweetModel.fromJson(Map<String, dynamic> json) {
    return SuggestedTweetModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      handle: json['handle'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isVerified: json['isVerified'] ?? false,
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      replyCount: json['replyCount'] ?? 0,
      repostCount: json['repostCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      trendContext: json['trendContext'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'handle': handle,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'replyCount': replyCount,
      'repostCount': repostCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'timestamp': timestamp,
      'trendContext': trendContext,
    };
  }

  SuggestedTweetModel copyWith({
    String? id,
    String? username,
    String? handle,
    String? avatarUrl,
    bool? isVerified,
    String? content,
    String? imageUrl,
    String? videoUrl,
    int? replyCount,
    int? repostCount,
    int? likeCount,
    int? shareCount,
    String? timestamp,
    String? trendContext,
  }) {
    return SuggestedTweetModel(
      id: id ?? this.id,
      username: username ?? this.username,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      replyCount: replyCount ?? this.replyCount,
      repostCount: repostCount ?? this.repostCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      timestamp: timestamp ?? this.timestamp,
      trendContext: trendContext ?? this.trendContext,
    );
  }
}

