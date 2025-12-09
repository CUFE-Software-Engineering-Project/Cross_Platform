import 'package:lite_x/features/explore/models/trend_model.dart';
import 'package:lite_x/features/profile/models/follower_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';

class TrendCategory {
  final String categoryName;
  final List<ProfileTweetModel> viralTweets;
  final List<TrendModel> trends;

  TrendCategory({
    required this.categoryName,
    required this.viralTweets,
    required this.trends,
  });

  factory TrendCategory.fromJson(Map<String, dynamic> json) {
    final viralTweets = convertJsonListToTweetList(json["viralTweets"] ?? []);
    final trendsJson = json["trends"] ?? [];
    final trends = trendsJson.map((t) => TrendModel.fromJson(t)).toList();
    return TrendCategory(
      categoryName: json['categoryName'] ?? "",
      viralTweets: viralTweets,
      trends: trends,
    );
  }
}
