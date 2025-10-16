// lib/features/home/repositories/home_repository.dart
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:uuid/uuid.dart';

class HomeRepository {
  // For demo purposes, we'll store tweets in memory
  static List<TweetModel> _tweets = [];
  static bool _isInitialized = false;

  // Get tweets (initialize if needed)
  List<TweetModel> getLocalTweets() {
    if (!_isInitialized) {
      _tweets = getSampleTweets();
      _isInitialized = true;
    }
    return List.from(_tweets)..sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ); // Sort by newest first
  }

  // Save tweets to memory
  Future<void> saveTweetsLocally(List<TweetModel> tweets) async {
    _tweets = List.from(tweets);
  }

  // Add a single tweet to memory
  Future<void> addTweetLocally(TweetModel tweet) async {
    _tweets.add(tweet);
  }

  // Update tweet (for like/retweet actions)
  Future<void> updateTweetLocally(TweetModel tweet) async {
    final index = _tweets.indexWhere((t) => t.id == tweet.id);
    if (index != -1) {
      _tweets[index] = tweet;
    }
  }

  // Create sample tweets (for testing)
  List<TweetModel> getSampleTweets() {
    const uuid = Uuid();
    return [
      TweetModel(
        id: uuid.v4(),
        content:
            "Just shipped a new feature! 🚀 Flutter development is amazing. The hot reload makes everything so fast and enjoyable. #Flutter #MobileDev",
        authorName: "Alex Johnson",
        authorUsername: "alexdev",
        authorAvatar: "https://i.pravatar.cc/150?img=1",
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 42,
        retweets: 12,
        replies: 8,
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "Beautiful sunset today! 🌅 Sometimes you need to step away from the code and enjoy nature.",
        authorName: "Sarah Miller",
        authorUsername: "sarahm",
        authorAvatar: "https://i.pravatar.cc/150?img=2",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 128,
        retweets: 24,
        replies: 15,
        images: ["https://picsum.photos/600/400?random=1"],
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "Working on a new project with clean architecture. MVVM pattern with Riverpod is a game changer! 💪",
        authorName: "Mike Chen",
        authorUsername: "mikechen",
        authorAvatar: "https://i.pravatar.cc/150?img=3",
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 89,
        retweets: 31,
        replies: 22,
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "Coffee ☕ + Code = Perfect Morning! Starting the day with some TypeScript refactoring. Who else is coding early today?",
        authorName: "Emma Watson",
        authorUsername: "emmacodes",
        authorAvatar: "https://i.pravatar.cc/150?img=4",
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 67,
        retweets: 18,
        replies: 12,
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "AI is transforming the way we think about software development. Excited to see what the future holds! 🤖 #AI #MachineLearning #TechTrends",
        authorName: "David Rodriguez",
        authorUsername: "davidtech",
        authorAvatar: "https://i.pravatar.cc/150?img=5",
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        likes: 203,
        retweets: 45,
        replies: 28,
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "Just deployed our new app to production! 🎉 Three months of hard work finally paying off. Team effort at its best! #ProductLaunch #TeamWork",
        authorName: "Lisa Kim",
        authorUsername: "lisakim_dev",
        authorAvatar: "https://i.pravatar.cc/150?img=6",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 156,
        retweets: 34,
        replies: 19,
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "Learning Rust has been an incredible journey. The memory safety features are mind-blowing! 🦀 Anyone else diving into systems programming?",
        authorName: "James Wilson",
        authorUsername: "rustacean_james",
        authorAvatar: "https://i.pravatar.cc/150?img=7",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 98,
        retweets: 27,
        replies: 15,
      ),
      TweetModel(
        id: uuid.v4(),
        content:
            "Remote work has changed everything. Working from a café in Barcelona today! 🌍 #DigitalNomad #RemoteWork #WorkLifeBalance",
        authorName: "Maria Garcia",
        authorUsername: "maria_nomad",
        authorAvatar: "https://i.pravatar.cc/150?img=8",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likes: 234,
        retweets: 56,
        replies: 32,
        images: ["https://picsum.photos/600/400?random=2"],
      ),
    ];
  }
}
