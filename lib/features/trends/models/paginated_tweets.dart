import 'package:lite_x/features/profile/models/profile_tweet_model.dart';

class PaginatedTweets {
  final List<ProfileTweetModel> tweets;
  final String? nextCursor;

  PaginatedTweets({required this.tweets, required this.nextCursor});
}
