// lib/data/mock_api_data.dart
// This file simulates all backend API responses
// TODO: Replace with actual API calls after backend deployment

import 'package:lite_x/features/home/models/tweet_model.dart';

/// Temporary current user ID - Replace with actual auth service
const String CURRENT_USER_ID = "current_user_temp_id";
const String CURRENT_USER_NAME = "Current User";
const String CURRENT_USER_USERNAME = "currentuser";
const String CURRENT_USER_AVATAR = "https://i.pravatar.cc/150?img=10";

/// Mock API Data Manager - Simulates backend responses
class MockApiData {
  // In-memory storage simulating database
  static final Set<String> _likedTweets = {}; // User's liked tweets
  static final Set<String> _bookmarkedTweets = {}; // User's bookmarked tweets
  static final Set<String> _retweetedTweets = {}; // User's retweeted tweets
  static final Map<String, List<String>> _tweetLikers =
      {}; // Tweet ID -> User IDs who liked
  static final Map<String, List<String>> _tweetRetweeters =
      {}; // Tweet ID -> User IDs who retweeted

  // Simulates GET /api/tweets/{id}/likes - Get tweet likes
  static Future<List<Map<String, dynamic>>> getTweetLikes(
    String tweetId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Return mock user data who liked the tweet
    final likerIds = _tweetLikers[tweetId] ?? [];
    return likerIds
        .map(
          (userId) => {
            'id': userId,
            'name': 'User $userId',
            'username': 'user$userId',
            'profilePhoto':
                'https://i.pravatar.cc/150?img=${userId.hashCode % 70}',
            'verified': false,
            'protectedAccount': false,
          },
        )
        .toList();
  }

  // Simulates POST /api/tweets/{id}/likes - Like a tweet
  static Future<bool> likeTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _likedTweets.add(tweetId);
    _tweetLikers[tweetId] = [...(_tweetLikers[tweetId] ?? []), CURRENT_USER_ID];
    return true; // Success
  }

  // Simulates DELETE /api/tweets/{id}/likes - Unlike a tweet
  static Future<bool> unlikeTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _likedTweets.remove(tweetId);
    _tweetLikers[tweetId] = (_tweetLikers[tweetId] ?? [])
        .where((id) => id != CURRENT_USER_ID)
        .toList();
    return true; // Success
  }

  // Check if current user liked a tweet
  static bool isLiked(String tweetId) {
    return _likedTweets.contains(tweetId);
  }

  // Simulates POST /api/tweets/{id}/bookmark - Bookmark a tweet
  static Future<bool> bookmarkTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _bookmarkedTweets.add(tweetId);
    return true; // Success (200)
  }

  // Simulates DELETE /api/tweets/{id}/bookmark - Remove bookmark
  static Future<bool> unbookmarkTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _bookmarkedTweets.remove(tweetId);
    return true; // Success (200)
  }

  // Check if current user bookmarked a tweet
  static bool isBookmarked(String tweetId) {
    return _bookmarkedTweets.contains(tweetId);
  }

  // Simulates GET /api/tweets/{id}/retweets - Get tweet retweets
  static Future<List<Map<String, dynamic>>> getTweetRetweets(
    String tweetId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final retweeterIds = _tweetRetweeters[tweetId] ?? [];
    return retweeterIds
        .map(
          (userId) => {
            'id': userId,
            'name': 'User $userId',
            'username': 'user$userId',
            'profilePhoto':
                'https://i.pravatar.cc/150?img=${userId.hashCode % 70}',
            'verified': false,
            'protectedAccount': false,
          },
        )
        .toList();
  }

  // Simulates POST /api/tweets/{id}/retweets - Retweet
  static Future<bool> retweetTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _retweetedTweets.add(tweetId);
    _tweetRetweeters[tweetId] = [
      ...(_tweetRetweeters[tweetId] ?? []),
      CURRENT_USER_ID,
    ];
    return true; // Success (201)
  }

  // Simulates DELETE /api/tweets/{id}/retweets - Delete retweet
  static Future<bool> unretweetTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _retweetedTweets.remove(tweetId);
    _tweetRetweeters[tweetId] = (_tweetRetweeters[tweetId] ?? [])
        .where((id) => id != CURRENT_USER_ID)
        .toList();
    return true; // Success (200)
  }

  // Check if current user retweeted a tweet
  static bool isRetweeted(String tweetId) {
    return _retweetedTweets.contains(tweetId);
  }

  // Simulates GET /api/tweets/{id} - Get tweet by ID
  static Future<Map<String, dynamic>> getTweetById(
    String tweetId,
    TweetModel tweet,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'id': tweet.id,
      'content': tweet.content,
      'createdAt': tweet.createdAt.toIso8601String(),
      'likeCount': tweet.likes,
      'retweetCount': tweet.retweets,
      'repliesCount': tweet.replies,
      'replyControl': 'EVERYONE',
      'parentId': tweet.replyToId,
      'tweetType': tweet.replyToId != null ? 'REPLY' : 'TWEET',
      'user': {
        'id': '${tweet.authorUsername}_id',
        'name': tweet.authorName,
        'username': tweet.authorUsername,
        'profilePhoto': tweet.authorAvatar,
        'isVerified': true,
        'isProtectedAccount': false,
      },
    };
  }

  // Simulates GET /api/tweets/{id}/summary - Get tweet summary
  static Future<Map<String, dynamic>> getTweetSummary(
    String tweetId,
    TweetModel tweet,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'id': tweet.id,
      'tweetId': tweet.id,
      'summary': _generateSummary(tweet.content),
    };
  }

  // Helper to generate mock summary
  static String _generateSummary(String content) {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  // Simulates GET /api/tweets/{id}/replies - Get tweet replies
  static Future<List<Map<String, dynamic>>> getTweetReplies(
    String tweetId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // This would return reply data from backend
    // For now, replies are handled in the repository layer
    return [];
  }

  // Simulates POST /api/tweets/{id}/replies - Reply to tweet
  static Future<Map<String, dynamic>> replyToTweet(
    String tweetId,
    String content,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Backend would create the reply and return it
    // For now, this is handled in repository.createPost()
    return {'content': content, 'replyControl': 'EVERYONE'};
  }

  // Simulates POST /api/tweets - Create tweet
  static Future<Map<String, dynamic>> createTweet(
    String content,
    String replyControl,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Backend would create and return the tweet
    return {
      'userId': CURRENT_USER_ID,
      'content': content,
      'replyControl': replyControl,
    };
  }

  // Simulates DELETE /api/tweets/{id} - Delete tweet
  static Future<bool> deleteTweet(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Remove from all user's collections
    _likedTweets.remove(tweetId);
    _bookmarkedTweets.remove(tweetId);
    _retweetedTweets.remove(tweetId);
    _tweetLikers.remove(tweetId);
    _tweetRetweeters.remove(tweetId);

    return true; // Success (204)
  }

  // Simulates PATCH /api/tweets/{id} - Update tweet (edit)
  static Future<Map<String, dynamic>> updateTweet(
    String tweetId,
    String content,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {'content': content};
  }

  // Simulates GET /api/tweets - Get timeline tweets
  static Future<List<Map<String, dynamic>>> getTimelineTweets({
    int limit = 20,
    String? cursor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // This would return paginated tweets from backend
    // For now, handled in repository layer
    return [];
  }

  // Initialize mock data for specific tweet (for testing)
  static void initializeTweetState(
    String tweetId, {
    bool liked = false,
    bool bookmarked = false,
    bool retweeted = false,
  }) {
    if (liked) _likedTweets.add(tweetId);
    if (bookmarked) _bookmarkedTweets.add(tweetId);
    if (retweeted) _retweetedTweets.add(tweetId);
  }

  // Clear all mock data (for testing/reset)
  static void clearAll() {
    _likedTweets.clear();
    _bookmarkedTweets.clear();
    _retweetedTweets.clear();
    _tweetLikers.clear();
    _tweetRetweeters.clear();
  }

  // Get all bookmarked tweets
  static Set<String> getBookmarkedTweets() {
    return Set.from(_bookmarkedTweets);
  }

  // Get all liked tweets
  static Set<String> getLikedTweets() {
    return Set.from(_likedTweets);
  }

  // Get all retweeted tweets
  static Set<String> getRetweetedTweets() {
    return Set.from(_retweetedTweets);
  }

  // Simulates GET /api/tweets/{id}/replies - Get tweet replies
  static Future<List<Map<String, dynamic>>> getReplies(String tweetId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // This would return reply data from backend
    // For now, replies are handled in the repository layer
    return [];
  }

  // Simulates GET /api/user/timeline - Get user timeline tweets
  static Future<List<Map<String, dynamic>>> getUserTimeline({
    int limit = 20,
    String? cursor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // This would return paginated tweets from backend
    return [];
  }
}
