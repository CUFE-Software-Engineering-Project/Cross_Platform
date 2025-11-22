class TweetSummary {
  final int views;
  final int likes;
  final int replies;
  final int retweets;
  final int quotes;
  final int bookmarks;

  const TweetSummary({
    this.views = 0,
    this.likes = 0,
    this.replies = 0,
    this.retweets = 0,
    this.quotes = 0,
    this.bookmarks = 0,
  });

  factory TweetSummary.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    int coalesceInts(List<String> keys) {
      for (final key in keys) {
        final value = readInt(key);
        if (value != 0) {
          return value;
        }
      }
      return 0;
    }

    return TweetSummary(
      views: coalesceInts(['views', 'viewCount', 'viewsCount']),
      likes: coalesceInts(['likes', 'likesCount']),
      replies: coalesceInts(['replies', 'repliesCount']),
      retweets: coalesceInts(['retweets', 'retweetCount']),
      quotes: coalesceInts(['quotes', 'quotesCount']),
      bookmarks: coalesceInts(['bookmarks', 'bookmarksCount']),
    );
  }
}
