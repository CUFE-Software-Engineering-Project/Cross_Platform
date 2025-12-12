import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/trends/models/trend_model.dart';

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
    final viralTweets = convertJsonListToTweetList(
      json["viralTweets"] ?? [],
      true,
    );

    final trendsJson = json["trends"] ?? [];
    final trends = trendsJson
        .map((t) => TrendModel.fromJson(t))
        .toList()
        .cast<TrendModel>();
    return TrendCategory(
      categoryName: json['category'] ?? "",
      viralTweets: viralTweets,
      trends: trends,
    );
  }
}
