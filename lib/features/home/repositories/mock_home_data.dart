import 'package:lite_x/features/home/models/tweet_model.dart';

/// Mock data for testing when endpoints are offline
class MockHomeData {
  static const bool useMockData = false; // Set to true to use mock data

  static List<TweetModel> getMockForYouTweets() {
    final now = DateTime.now();
    
    return [
      TweetModel(
        id: 'mock-foryou-1',
        content: ' Welcome to the For You feed! This is a mock tweet for testing purposes.',
        authorName: 'Test User',
        authorUsername: 'testuser',
        authorAvatar: '',
        userId: 'user-1',
        createdAt: now.subtract(const Duration(hours: 2)),
        likes: 42,
        retweets: 15,
        replies: 8,
        quotes: 3,
        bookmarks: 5,
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
        tweetType: 'TWEET',
        images: [],
        replyIds: [],
      ),
    ];
  }

  static List<TweetModel> getMockTimelineTweets() {
    final now = DateTime.now();
    
    return [
      TweetModel(
        id: 'mock-timeline-1',
        content: ' This is your Following/Timeline feed! Here you see tweets from people you follow.',
        authorName: 'Your Friend',
        authorUsername: 'yourfriend',
        authorAvatar: '',
        userId: 'user-10',
        createdAt: now.subtract(const Duration(minutes: 30)),
        likes: 25,
        retweets: 8,
        replies: 4,
        quotes: 1,
        bookmarks: 2,
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
        tweetType: 'TWEET',
        images: [],
        replyIds: [],
      ),
    ];
  }
}
