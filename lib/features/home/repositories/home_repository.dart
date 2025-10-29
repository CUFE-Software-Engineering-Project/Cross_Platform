// lib/features/home/repositories/home_repository.dart
import 'package:lite_x/data/mock_tweets.dart';
import 'package:lite_x/data/mock_for_you_tweets.dart';
import 'package:lite_x/data/mock_following_tweets.dart';
import 'package:lite_x/data/mock_api_data.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:uuid/uuid.dart';

class HomeRepository {
  // For demo purposes, we'll store tweets in memory
  static List<TweetModel> _tweets = [];
  static List<TweetModel> _forYouTweets = [];
  static List<TweetModel> _followingTweets = [];
  static bool _isInitialized = false;
  static bool _isForYouInitialized = false;
  static bool _isFollowingInitialized = false;

  // Initialize repository with mock data (simulating database/API data)
  Future<void> _initializeIfNeeded() async {
    if (!_isInitialized) {
      // TODO: Replace with actual API call
      // Example: final response = await dio.get('/api/tweets');

      // For now, load from mock data source
      _tweets = await _fetchMockTweetsFromDataSource();
      _isInitialized = true;
    }
  }

  // Simulates fetching tweets from an API or database
  Future<List<TweetModel>> _fetchMockTweetsFromDataSource() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Convert mock data map to list (simulating API response)
    // Update with user's interaction state (liked, bookmarked, retweeted)
    return mockTweets.values.map((tweet) {
      return tweet.copyWith(
        isLiked: MockApiData.isLiked(tweet.id),
        isBookmarked: MockApiData.isBookmarked(tweet.id),
        isRetweeted: MockApiData.isRetweeted(tweet.id),
      );
    }).toList();
  }

  // Fetch "For You" tweets (simulates API GET /tweets/for-you)
  Future<List<TweetModel>> fetchForYouTweets() async {
    // TODO: Replace with actual API call

    /*
    final response = await dio.get('/api/tweets/for-you');
    return (response.data as List)
        .map((json) => TweetModel.fromJson(json))
        .toList();
    */

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Ensure main tweets list is initialized (for newly created posts)
    await _initializeIfNeeded();

    if (!_isForYouInitialized) {
      // Load from "For You" mock data source
      _forYouTweets = mockForYouTweets.values.map((tweet) {
        return tweet.copyWith(
          isLiked: MockApiData.isLiked(tweet.id),
          isBookmarked: MockApiData.isBookmarked(tweet.id),
          isRetweeted: MockApiData.isRetweeted(tweet.id),
        );
      }).toList();
      _isForYouInitialized = true;
    }

    // Combine newly created tweets with mock "For You" tweets
    // In real app, the API would return combined results from database
    final allTweets = [..._tweets, ..._forYouTweets];

    // Return sorted tweets (newest first), filtering out replies (only show parent tweets)
    final parentTweets = allTweets
        .where((tweet) => tweet.replyToId == null)
        .toList();
    parentTweets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return parentTweets;
  }

  // Fetch "Following" tweets (simulates API GET /tweets/following)
  Future<List<TweetModel>> fetchFollowingTweets() async {
    // TODO: Replace with actual API call
    /*
    final response = await dio.get('/api/tweets/following');
    return (response.data as List)
        .map((json) => TweetModel.fromJson(json))
        .toList();
    */

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Ensure main tweets list is initialized (for newly created posts)
    await _initializeIfNeeded();

    if (!_isFollowingInitialized) {
      // Load from "Following" mock data source
      _followingTweets = mockFollowingTweets.values.map((tweet) {
        return tweet.copyWith(
          isLiked: MockApiData.isLiked(tweet.id),
          isBookmarked: MockApiData.isBookmarked(tweet.id),
          isRetweeted: MockApiData.isRetweeted(tweet.id),
        );
      }).toList();
      _isFollowingInitialized = true;
    }

    // Combine newly created tweets with mock "Following" tweets
    // In real app, the API would return combined results from database
    final allTweets = [..._tweets, ..._followingTweets];

    // Return sorted tweets (newest first), filtering out replies (only show parent tweets)
    final parentTweets = allTweets
        .where((tweet) => tweet.replyToId == null)
        .toList();
    parentTweets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return parentTweets;
  }

  // Fetch all tweets (simulates API GET /tweets)
  // This is a fallback method, prefer using fetchForYouTweets or fetchFollowingTweets
  Future<List<TweetModel>> fetchTweets() async {
    // TODO: Replace with actual API call
    // Example: final response = await dio.get('/api/tweets');
    // return (response.data as List).map((json) => TweetModel.fromJson(json)).toList();

    await _initializeIfNeeded();

    // Return sorted tweets (newest first)
    return List.from(_tweets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get tweet by ID (simulates API GET /api/tweets/{id})
  // API Response Format:
  // {
  //   "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  //   "content": "string",
  //   "createdAt": "2025-10-16",
  //   "likeCount": 0,
  //   "retweetCount": 0,
  //   "repliesCount": 0,
  //   "replyControl": "EVERYONE",
  //   "parentId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  //   "tweetType": "TWEET",
  //   "user": {
  //     "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  //     "name": "string",
  //     "username": "string",
  //     "profilePhoto": "string",
  //     "isVerified": true,
  //     "isProtectedAccount": true
  //   }
  // }
  Future<TweetModel?> getTweetById(String tweetId) async {
    // TODO: Replace with actual API call
    /*
    final response = await dio.get('/api/tweets/$tweetId');
    // Parse response to match our TweetModel
    final data = response.data;
    return TweetModel(
      id: data['id'],
      content: data['content'],
      authorName: data['user']['name'],
      authorUsername: data['user']['username'],
      authorAvatar: data['user']['profilePhoto'],
      createdAt: DateTime.parse(data['createdAt']),
      likes: data['likeCount'],
      retweets: data['retweetCount'],
      replies: data['repliesCount'],
      replyToId: data['parentId'],
      // Additional fields from your model...
    );
    */

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Initialize all data sources
    await _initializeIfNeeded();
    if (!_isForYouInitialized) {
      _forYouTweets = mockForYouTweets.values.toList();
      _isForYouInitialized = true;
    }
    if (!_isFollowingInitialized) {
      _followingTweets = mockFollowingTweets.values.toList();
      _isFollowingInitialized = true;
    }

    // Search in all available tweet sources (including replies)
    final allTweets = [..._tweets, ..._forYouTweets, ..._followingTweets];

    try {
      return allTweets.firstWhere((t) => t.id == tweetId);
    } catch (e) {
      return null;
    }
  }

  // Update tweet - Like/Unlike (simulates API POST/DELETE /api/tweets/{id}/likes)
  Future<TweetModel> toggleLike(String tweetId, bool isLiked) async {
    // TODO: Replace with actual API call
    /*
    if (isLiked) {
      await dio.post('/api/tweets/$tweetId/likes');
    } else {
      await dio.delete('/api/tweets/$tweetId/likes');
    }
    */

    // Call mock API
    if (isLiked) {
      await MockApiData.likeTweet(tweetId);
    } else {
      await MockApiData.unlikeTweet(tweetId);
    }

    await _initializeIfNeeded();

    // Find and update tweet in all collections
    final tweet = await _findAndUpdateTweet(tweetId, (t) {
      return t.copyWith(
        isLiked: isLiked,
        likes: isLiked ? t.likes + 1 : t.likes - 1,
      );
    });

    if (tweet == null) {
      throw Exception('Tweet not found');
    }

    return tweet;
  }

  // Helper method to find and update tweet in all collections
  Future<TweetModel?> _findAndUpdateTweet(
    String tweetId,
    TweetModel Function(TweetModel) updater,
  ) async {
    TweetModel? updatedTweet;

    // Update in _tweets
    final index = _tweets.indexWhere((t) => t.id == tweetId);
    if (index != -1) {
      updatedTweet = updater(_tweets[index]);
      _tweets[index] = updatedTweet;
    }

    // Update in _forYouTweets
    final forYouIndex = _forYouTweets.indexWhere((t) => t.id == tweetId);
    if (forYouIndex != -1) {
      updatedTweet = updater(_forYouTweets[forYouIndex]);
      _forYouTweets[forYouIndex] = updatedTweet;
    }

    // Update in _followingTweets
    final followingIndex = _followingTweets.indexWhere((t) => t.id == tweetId);
    if (followingIndex != -1) {
      updatedTweet = updater(_followingTweets[followingIndex]);
      _followingTweets[followingIndex] = updatedTweet;
    }

    return updatedTweet;
  }

  // Update tweet - Retweet/Unretweet (simulates API POST/DELETE /api/tweets/{id}/retweets)
  Future<TweetModel> toggleRetweet(String tweetId, bool isRetweeted) async {
    // TODO: Replace with actual API call
    /*
    if (isRetweeted) {
      await dio.post('/api/tweets/$tweetId/retweets');
    } else {
      await dio.delete('/api/tweets/$tweetId/retweets');
    }
    */

    // Call mock API
    if (isRetweeted) {
      await MockApiData.retweetTweet(tweetId);
    } else {
      await MockApiData.unretweetTweet(tweetId);
    }

    await _initializeIfNeeded();

    // Find and update tweet in all collections
    final tweet = await _findAndUpdateTweet(tweetId, (t) {
      return t.copyWith(
        isRetweeted: isRetweeted,
        retweets: isRetweeted ? t.retweets + 1 : t.retweets - 1,
      );
    });

    if (tweet == null) {
      throw Exception('Tweet not found');
    }

    return tweet;
  }

  // Update tweet - Bookmark/Unbookmark (simulates API POST/DELETE /api/tweets/{id}/bookmark)
  Future<TweetModel> toggleBookmark(String tweetId, bool isBookmarked) async {
    // TODO: Replace with actual API call
    /*
    if (isBookmarked) {
      await dio.post('/api/tweets/$tweetId/bookmark');
    } else {
      await dio.delete('/api/tweets/$tweetId/bookmark');
    }
    */

    // Call mock API
    if (isBookmarked) {
      await MockApiData.bookmarkTweet(tweetId);
    } else {
      await MockApiData.unbookmarkTweet(tweetId);
    }

    await _initializeIfNeeded();

    // Find and update tweet in all collections
    final tweet = await _findAndUpdateTweet(tweetId, (t) {
      return t.copyWith(isBookmarked: isBookmarked);
    });

    if (tweet == null) {
      throw Exception('Tweet not found');
    }

    return tweet;
  }

  // Create a new post (simulates API POST /api/tweets)
  // API Request Format:
  // {
  //   "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  //   "content": "string",
  //   "replyControl": "EVERYONE"  // or "FOLLOWING" or "MENTIONED"
  // }
  // API Response: 201 - Tweet created successfully
  Future<TweetModel> createPost({
    required String content,
    String replyControl = "EVERYONE", // EVERYONE, FOLLOWING, MENTIONED
    List<String> images = const [],
    String? replyToId,
  }) async {
    // TODO: Replace with actual API call
    /*
    final response = await dio.post(
      '/api/tweets',
      data: {
        'userId': currentUserId, // Get from auth service
        'content': content,
        'replyControl': replyControl, // EVERYONE, FOLLOWING, or MENTIONED
      },
    );
    // API returns 201 on success
    // Parse response to create TweetModel
    return TweetModel(
      id: response.data['id'], // Server generates UUID
      content: response.data['content'],
      authorName: response.data['user']['name'],
      authorUsername: response.data['user']['username'],
      authorAvatar: response.data['user']['profilePhoto'],
      createdAt: DateTime.parse(response.data['createdAt']),
      likes: 0,
      retweets: 0,
      replies: 0,
      // ... other fields
    );
    */

    // Simulate network delay (like real API call)
    await Future.delayed(const Duration(milliseconds: 800));

    // Ensure data is initialized
    await _initializeIfNeeded();

    // Generate new tweet (simulating server-side creation)
    const uuid = Uuid();
    final newTweet = TweetModel(
      id: uuid.v4(), // Server would generate this UUID
      content: content,
      authorName: CURRENT_USER_NAME,
      authorUsername: CURRENT_USER_USERNAME,
      authorAvatar: CURRENT_USER_AVATAR,
      createdAt: DateTime.now(), // Server timestamp
      images: images,
      replyToId: replyToId,
      likes: 0,
      retweets: 0,
      replies: 0,
    );

    // Add to mock database (simulating server persisting data)
    _tweets.add(newTweet);

    // If it's a reply, update parent tweet (server would do this)
    if (replyToId != null) {
      final parentTweetIndex = _tweets.indexWhere((t) => t.id == replyToId);
      if (parentTweetIndex != -1) {
        final parentTweet = _tweets[parentTweetIndex];
        final updatedParent = parentTweet.copyWith(
          replies: parentTweet.replies + 1,
          replyIds: [...parentTweet.replyIds, newTweet.id],
        );
        _tweets[parentTweetIndex] = updatedParent;
      }
    }

    // Return the created tweet (like API 201 response)
    return newTweet;
  }

  // Get replies for a tweet (simulates API GET /api/tweets/{id}/replies)
  Future<List<TweetModel>> getReplies(String tweetId) async {
    // TODO: Replace with actual API call
    /*
    final response = await dio.get('/api/tweets/$tweetId/replies');
    return (response.data as List)
        .map((json) => TweetModel.fromJson(json))
        .toList();
    */

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    await _initializeIfNeeded();

    // Get all replies to this tweet from all sources
    final allTweets = [..._tweets, ..._forYouTweets, ..._followingTweets];
    final replies = allTweets
        .where((tweet) => tweet.replyToId == tweetId)
        .map(
          (tweet) => tweet.copyWith(
            isLiked: MockApiData.isLiked(tweet.id),
            isBookmarked: MockApiData.isBookmarked(tweet.id),
            isRetweeted: MockApiData.isRetweeted(tweet.id),
          ),
        )
        .toList();

    // Sort by newest first
    replies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return replies;
  }

  // Create a quote tweet (simulates API POST /api/tweets with quotedTweetId)
  Future<TweetModel> createQuoteTweet({
    required String content,
    required String quotedTweetId,
    required TweetModel quotedTweet,
    String replyControl = "EVERYONE",
    List<String> images = const [],
  }) async {
    // TODO: Replace with actual API call
    /*
    final response = await dio.post(
      '/api/tweets',
      data: {
        'userId': currentUserId,
        'content': content,
        'quotedTweetId': quotedTweetId,
        'replyControl': replyControl,
      },
    );
    return TweetModel.fromJson(response.data);
    */

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    await _initializeIfNeeded();

    // Generate new quote tweet with quoted tweet reference
    const uuid = Uuid();
    final quoteTweetModel = TweetModel(
      id: uuid.v4(),
      content: content,
      authorName: CURRENT_USER_NAME,
      authorUsername: CURRENT_USER_USERNAME,
      authorAvatar: CURRENT_USER_AVATAR,
      createdAt: DateTime.now(),
      images: images,
      likes: 0,
      retweets: 0,
      replies: 0,
      quotedTweetId: quotedTweetId,
      quotedTweet: quotedTweet,
    );

    // Add to mock database
    _tweets.add(quoteTweetModel);

    // Update quoted tweet's quote count (if we had that field)
    // This would be handled by the backend

    return quoteTweetModel;
  }

  // Delete a post (simulates API DELETE /tweets/:id)
  Future<bool> deletePost(String tweetId) async {
    // TODO: Replace with actual API call
    /*
    final response = await dio.delete('/api/tweets/$tweetId');
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to delete tweet');
    */

    // Simulate network delay (like real API call)
    await Future.delayed(const Duration(milliseconds: 600));

    // Ensure data is initialized
    await _initializeIfNeeded();

    try {
      // Find the tweet to delete (server would validate ownership)
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) {
        throw Exception('Tweet not found');
      }

      final tweet = _tweets[tweetIndex];

      // Server would handle cascade operations:
      // 1. If it's a reply, update parent tweet's reply count
      if (tweet.replyToId != null) {
        final parentTweetIndex = _tweets.indexWhere(
          (t) => t.id == tweet.replyToId,
        );
        if (parentTweetIndex != -1) {
          final parentTweet = _tweets[parentTweetIndex];
          final updatedParent = parentTweet.copyWith(
            replies: parentTweet.replies > 0 ? parentTweet.replies - 1 : 0,
            replyIds: parentTweet.replyIds
                .where((id) => id != tweetId)
                .toList(),
          );
          _tweets[parentTweetIndex] = updatedParent;
        }
      }

      // 2. Delete all replies to this tweet (cascade delete)
      _tweets.removeWhere((t) => t.replyToId == tweetId);

      // 3. Delete the tweet itself
      _tweets.removeAt(tweetIndex);

      // Return success (like API response)
      return true;
    } catch (e) {
      throw Exception('Failed to delete tweet: $e');
    }
  }
}
