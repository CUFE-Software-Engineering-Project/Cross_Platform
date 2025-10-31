import 'package:lite_x/core/services/api_service.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:dio/dio.dart';

class HomeRepository {
  final ApiService apiService;
  final Map<String, Map<String, dynamic>> _userCache = {};

  HomeRepository(this.apiService);

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {

      final response = await apiService.getCurrentUser();

      Map<String, dynamic> userData;

      if (response.data is Map) {

        if (response.data['User'] != null) {
          userData = response.data['User'] as Map<String, dynamic>;

        }

        else if (response.data['data'] != null) {
          userData = response.data['data'] as Map<String, dynamic>;

        }

        else {
          userData = response.data as Map<String, dynamic>;

        }
      } else {
        throw Exception('Unexpected response format');
      }

      return userData;
    } catch (e) {

      throw Exception('Failed to fetch current user: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {

      return _userCache[userId]!;
    }

    try {

      final response = await apiService.getUserById(userId);

      final userData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      _userCache[userId] = userData;
      return userData;
    } catch (e) {

      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<TweetModel> _enrichTweetWithUserData(
    Map<String, dynamic> tweetJson,
  ) async {

    if (tweetJson['user'] == null && tweetJson['userId'] != null) {

      final userId = tweetJson['userId'];
      try {
        final userData = await _getUserData(userId);
        tweetJson['user'] = userData;

      } catch (e) {

      }
    } else if (tweetJson['user'] != null) {

    }

    return TweetModel.fromJson(tweetJson);
  }

  Future<List<TweetModel>> fetchForYouTweets() async {
    try {
      final response = await apiService.getForYouTweets();

      final List tweetsData;
      if (response.data is List) {
        tweetsData = response.data as List;

      } else if (response.data is Map && response.data['data'] != null) {
        tweetsData = response.data['data'] as List;

      } else {

        return [];
      }

      if (tweetsData.isEmpty) {

        return [];
      }

      final List<TweetModel> tweets = [];
      for (var json in tweetsData) {
        try {
          final tweet = await _enrichTweetWithUserData(json);
          tweets.add(tweet);
        } catch (e) {

        }
      }

      return tweets.where((tweet) => tweet.replyToId == null).toList();
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<List<TweetModel>> fetchFollowingTweets() async {
    try {
      final response = await apiService.getFollowingTweets();

      final List tweetsData;
      if (response.data is List) {
        tweetsData = response.data as List;

      } else if (response.data is Map && response.data['data'] != null) {
        tweetsData = response.data['data'] as List;

      } else {

        return [];
      }

      if (tweetsData.isEmpty) {

        return [];
      }

      final List<TweetModel> tweets = [];
      for (var json in tweetsData) {
        try {
          final tweet = await _enrichTweetWithUserData(json);
          tweets.add(tweet);
        } catch (e) {

        }
      }

      return tweets.where((tweet) => tweet.replyToId == null).toList();
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<List<TweetModel>> fetchTweets() async {
    try {
      final response = await apiService.getTweets();

      final List tweetsData;
      if (response.data is List) {
        tweetsData = response.data as List;
      } else if (response.data is Map && response.data['data'] != null) {
        tweetsData = response.data['data'] as List;
      } else {

        return [];
      }

      return tweetsData.map((json) => TweetModel.fromJson(json)).toList();
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<TweetModel> getTweetById(String tweetId) async {
    try {

      final response = await apiService.getTweetById(tweetId);

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final enrichedTweet = await _enrichTweetWithUserData(tweetData);

      return enrichedTweet;
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<TweetModel> toggleLike(String tweetId, bool isCurrentlyLiked) async {
    try {
      if (isCurrentlyLiked) {
        await apiService.unlikeTweet(tweetId);
      } else {
        await apiService.likeTweet(tweetId);
      }
      return await getTweetById(tweetId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetModel> toggleRetweet(
    String tweetId,
    bool isCurrentlyRetweeted,
  ) async {
    try {
      if (isCurrentlyRetweeted) {
        await apiService.unretweetTweet(tweetId);
      } else {
        await apiService.retweetTweet(tweetId);
      }
      return await getTweetById(tweetId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetModel> toggleBookmark(
    String tweetId,
    bool isCurrentlyBookmarked,
  ) async {
    try {
      if (isCurrentlyBookmarked) {
        await apiService.unbookmarkTweet(tweetId);
      } else {
        await apiService.bookmarkTweet(tweetId);
      }
      return await getTweetById(tweetId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetModel> createPost({
    required String content,
    String replyControl = "EVERYONE",
    List<String> images = const [],
    String? replyToId,
  }) async {
    try {

      if (replyToId != null) {

        return await createReply(
          tweetId: replyToId,
          content: content,
          replyControl: replyControl,
          images: images,
        );
      }

      final data = {
        'content': content,
        'replyControl': replyControl,
        if (images.isNotEmpty) 'images': images,
      };

      final response = await apiService.createTweet(data);

      Map<String, dynamic> tweetData;

      if (response.data is Map) {

        if (response.data['data'] != null) {
          tweetData = response.data['data'] as Map<String, dynamic>;

        } else {
          tweetData = response.data as Map<String, dynamic>;

        }
      } else if (response.data is List) {

        final list = response.data as List;
        if (list.isNotEmpty) {
          tweetData = list.first as Map<String, dynamic>;

        } else {
          throw Exception('Empty list response when creating tweet');
        }
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      return await _enrichTweetWithUserData(tweetData);
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<bool> deletePost(String tweetId) async {
    try {
      await apiService.deleteTweet(tweetId);
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getReplies(String tweetId) async {
    try {
      final response = await apiService.getReplies(tweetId);

      final List repliesData;
      if (response.data is List) {
        repliesData = response.data as List;
      } else if (response.data is Map && response.data['data'] != null) {
        repliesData = response.data['data'] as List;
      } else {

        return [];
      }

      final List<TweetModel> replies = [];
      for (var json in repliesData) {
        try {
          final reply = await _enrichTweetWithUserData(json);
          replies.add(reply);
        } catch (e) {

        }
      }

      return replies;
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<TweetModel> createReply({
    required String tweetId,
    required String content,
    String replyControl = "EVERYONE",
    List<String> images = const [],
  }) async {
    try {
      final data = {
        'content': content,
        'replyControl': replyControl,
        if (images.isNotEmpty) 'images': images,
      };

      final response = await apiService.createReply(tweetId, data);

      Map<String, dynamic> replyData;

      if (response.data is Map) {

        if (response.data['data'] != null) {
          replyData = response.data['data'] as Map<String, dynamic>;

        } else {
          replyData = response.data as Map<String, dynamic>;

        }
      } else if (response.data is List) {

        final list = response.data as List;
        if (list.isNotEmpty) {
          replyData = list.first as Map<String, dynamic>;

        } else {
          throw Exception('Empty list response when creating reply');
        }
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      return await _enrichTweetWithUserData(replyData);
    } on DioException catch (e) {

      final errorMessage = _handleError(e);

      throw errorMessage;
    } catch (e) {

      rethrow;
    }
  }

  Future<Map<String, TweetModel>> getTweetWithNestedReplies(
    String tweetId,
  ) async {
    try {

      final Map<String, TweetModel> tweetMap = {};

      final mainTweet = await getTweetById(tweetId);
      tweetMap[tweetId] = mainTweet;

      await _fetchRepliesRecursively(tweetId, tweetMap);

      return tweetMap;
    } catch (e) {

      rethrow;
    }
  }

  Future<void> _fetchRepliesRecursively(
    String tweetId,
    Map<String, TweetModel> tweetMap,
  ) async {
    try {
      final replies = await getReplies(tweetId);

      for (var reply in replies) {
        if (!tweetMap.containsKey(reply.id)) {
          tweetMap[reply.id] = reply;

          await _fetchRepliesRecursively(reply.id, tweetMap);
        }
      }
    } catch (e) {

    }
  }

  Future<TweetModel> createQuoteTweet({
    required String content,
    required String quotedTweetId,
    required TweetModel quotedTweet,
    String replyControl = "EVERYONE",
    List<String> images = const [],
  }) async {
    try {
      final data = {
        'content': content,
        'quotedTweetId': quotedTweetId,
        'replyControl': replyControl,
        if (images.isNotEmpty) 'images': images,
      };

      final response = await apiService.createQuoteTweet(data);

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final newTweet = TweetModel.fromJson(tweetData);

      return newTweet.copyWith(
        quotedTweetId: quotedTweetId,
        quotedTweet: quotedTweet,
      );
    } on DioException catch (e) {

      throw _handleError(e);
    } catch (e) {

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTweetLikes(String tweetId) async {
    try {
      final response = await apiService.getTweetLikes(tweetId);
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {

      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getLikedTweets() async {
    try {
      final response = await apiService.getLikedTweets();
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final List<TweetModel> tweets = [];
      for (var json in (data as List)) {
        try {
          final tweet = await _enrichTweetWithUserData(json);
          tweets.add(tweet);
        } catch (e) {

        }
      }
      return tweets;
    } on DioException catch (e) {

      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getMentionedTweets(String username) async {
    try {
      final response = await apiService.getMentionedTweets(username);
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final List<TweetModel> tweets = [];
      for (var json in (data as List)) {
        try {
          final tweet = await _enrichTweetWithUserData(json);
          tweets.add(tweet);
        } catch (e) {

        }
      }
      return tweets;
    } on DioException catch (e) {

      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Unknown error';
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      }

      switch (statusCode) {
        case 400:
          return 'Bad request: $message';
        case 401:
          return 'Unauthorized: Please log in again';
        case 403:
          return 'Forbidden: You don\'t have permission';
        case 404:
          return 'Not found: $message';
        case 500:
          return 'Server error: Please try again later';
        default:
          return 'Error: $message';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout: Please check your internet connection';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout: Server is taking too long to respond';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Connection error: Please check your internet connection';
    } else {
      return 'Network error: ${error.message}';
    }
  }
}
