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
  final num quotesCount;
  final String userId;
  final String userUserName;
  final String userDisplayName;
  final String profileMediaId;
  final bool verified;
  final bool protectedAccount;
  // final List<String> mediaUrls;
  final TweetType type;
  final List<String> mediaIds;
  final String parentId;
  final String retweeterName;
  final String retweeterUserName;
  final List<Map<String, String>> hashtags;

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
    // required this.mediaUrls,
    required this.quotesCount,
    required this.profileMediaId,
    required this.protectedAccount,
    required this.userId,
    required this.userDisplayName,
    required this.userUserName,
    required this.verified,
    required this.type,
    required this.mediaIds,
    required this.parentId,
    required this.retweeterName,
    required this.retweeterUserName,
    required this.hashtags,
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
    else if (typeString.toLowerCase() == "reply")
      type = TweetType.Reply;
    final List<dynamic> mediaIdsRes = json["tweetMedia"] ?? [];
    // final List<String> meidaIds = mediaIdsRes.map((json) {
    //   return json["mediaId"] as String;
    // }).toList();
    final hashtagsList = json["hashtags"];
    final List<Map<String, String>> hashtagsModelList = hashtagsList
        .map((h) {
          final String id = h["hash"]?["id"] ?? "";
          final String tag_name = h["hash"]?["tag_text"] ?? "";
          return ({"hashtagName": tag_name, "id": id});
        })
        .toList()
        .cast<Map<String, String>>();
    return ProfileTweetModel(
      id: json['id'] ?? "",
      text: json['content'] ?? "",
      timeAgo: json['timeAgo'] ?? "",
      likes: json['likesCount'] ?? 0,
      retweets: json['retweetCount'] ?? 0,
      replies: json['repliesCount'] ?? 0,
      quotesCount: json["quotesCount"] ?? 0,
      isLikedByMe: json['isLiked'] ?? false,
      isRepostedWithMe: json['isRetweeted'] ?? false,
      activityNumber: json['activityNumber'] ?? 0,
      isSavedByMe: json['isBookmarked'] ?? false,
      mediaIds: json['mediaIds'] ?? [],
      type: type,
      userDisplayName: json["user"]?["name"] ?? "",
      userId: json["user"]?["id"] ?? "",
      userUserName: json["user"]?["username"] ?? "",
      profileMediaId: json["profileMediaId"] ?? "",
      protectedAccount: json["user"]?["protectedAccount"] ?? false,
      verified: json["user"]?["verified"] ?? false,
      parentId: json["parentId"] ?? "",
      retweeterName: json["retweeter"]?["name"] ?? "",
      retweeterUserName: json["retweeter"]?["username"] ?? "",
      hashtags: hashtagsModelList,
    );
  }
  // ------------------------------------------
}
