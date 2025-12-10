// Model representing a single trend item in the Trends screen
class TrendModel {
  final String id;
  final String title;
  final num postCount;
  final num rank;
  final num likesCount;

  const TrendModel({
    required this.id,
    required this.title,
    required this.postCount,
    required this.rank,
    required this.likesCount,
  });

  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
      id: json["id"] ?? "",
      title: json["hashtag"],
      postCount: json["tweetCount"],
      rank: json["rank"],
      likesCount: json["likesCount"],
    );
  }
}
