import 'package:lite_x/features/profile/models/shared.dart';

class ProfileTweetModel {
  final String id;
  final String text;
  final String timeAgo;
  final int likes;
  final int retweets;
  final int replies;
  final int activityNumber;
  final bool isLikedByMe;
  final bool isSavedByMe;
  final bool isRepostedWithMe;
  final List<dynamic> mediaUrls;
  final TweetType type;

  ProfileTweetModel({
    required this.id,
    required this.text,
    required this.timeAgo,
    required this.likes,
    required this.retweets,
    required this.isSavedByMe,
    required this.replies,
    required this.isRepostedWithMe,
    required this.isLikedByMe,
    required this.activityNumber,
    required this.mediaUrls,
    required this.type,
  });

  factory ProfileTweetModel.fromJson(Map<String, dynamic> json) {
    String? typeString = json['tweetType'];
    TweetType type = TweetType.Tweet;
    if (typeString == null)
      ;
    else if (typeString.toLowerCase() == "retweet")
      type = TweetType.ReTweet;
    else if (typeString.toLowerCase() == "quote")
      type = TweetType.Quote;
    return ProfileTweetModel(
      id: json['id'] ?? "",
      text: json['text'] ?? "",
      timeAgo: json['timeAgo'] ?? "",
      likes: json['likes'] ?? 0,
      retweets: json['retweets'] ?? 0,
      replies: json['replies'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
      isRepostedWithMe: json['isRepostedWithMe'] ?? false,
      activityNumber: json['activityNumber'] ?? 0,
      isSavedByMe: json['isSaveByMe'] ?? false,
      mediaUrls: json['mediaUrls'] ?? [],
      type: type,
    );
  }
  // ------------------------------------------
}
