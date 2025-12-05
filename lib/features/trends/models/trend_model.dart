// Model representing a single trend item in the Trends screen
class TrendModel {
  final int rank; // 1, 2, 3, ...
  final String
  contextLabel; // e.g. "Trending in Egypt" or "Only on X • Trending"
  final String title; // e.g. hashtag or trend title
  final String? postsCountLabel; // e.g. "17.4K posts" (optional)
  final bool hasMenu; // show kebab menu icon

  const TrendModel({
    required this.rank,
    required this.contextLabel,
    required this.title,
    this.postsCountLabel,
    this.hasMenu = true,
  });
}
