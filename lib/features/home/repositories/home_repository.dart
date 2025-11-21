import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/models/tweet_summary.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref);
});

class HomeRepository {
  final Ref _ref;

  HomeRepository(this._ref);

  Dio get _dio => _ref.read(dioProvider);

  Future<List<TweetModel>> fetchForYouTweets({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'api/home/for-you',
        queryParameters: {'page': page, 'limit': limit},
      );

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
          final tweet = TweetModel.fromJson(json);
          tweets.add(tweet);
        } catch (e) {
          // Silently handle error
        }
      }

      return _filterTimelineTweets(tweets);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TweetModel>> fetchFollowingTweets({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'api/home/timeline',
        queryParameters: {'page': page, 'limit': limit},
      );

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
          final tweet = TweetModel.fromJson(json);
          tweets.add(tweet);
        } catch (e) {
          // Silently handle error
        }
      }

      return _filterTimelineTweets(tweets);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TweetModel>> fetchTweets({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        'api/tweets',
        queryParameters: {'page': page, 'limit': limit},
      );

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
      final response = await _dio.get('api/tweets/$tweetId');

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return TweetModel.fromJson(tweetData);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<TweetModel> toggleLike(String tweetId, bool isCurrentlyLiked) async {
    try {
      if (isCurrentlyLiked) {
        await _dio.delete('api/tweets/$tweetId/likes');
      } else {
        await _dio.post('api/tweets/$tweetId/likes');
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
        await _dio.delete('api/tweets/$tweetId/retweets');
      } else {
        await _dio.post('api/tweets/$tweetId/retweets');
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
        await _dio.delete('api/tweets/$tweetId/bookmark');
      } else {
        await _dio.post('api/tweets/$tweetId/bookmark');
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

      final response = await _dio.post('api/tweets', data: data);

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

      return TweetModel.fromJson(tweetData);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePost(String tweetId) async {
    try {
      await _dio.delete('api/tweets/$tweetId');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getReplies(String tweetId) async {
    try {
      final response = await _dio.get('api/tweets/$tweetId/replies');

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
          final reply = TweetModel.fromJson(json);
          replies.add(reply);
        } catch (e) {
          // Silently handle error
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

      final response = await _dio.post(
        'api/tweets/$tweetId/replies',
        data: data,
      );

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

      return TweetModel.fromJson(replyData);
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
      // Silently handle error
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

      final response = await _dio.post(
        'api/tweets/$quotedTweetId/quotes',
        data: data,
      );

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

  List<TweetModel> _filterTimelineTweets(List<TweetModel> tweets) {
    return tweets.where((tweet) {
      final type = tweet.tweetType.toUpperCase();

      if (type == 'TWEET' || type == 'QUOTE') {
        return true;
      }

      if (type == 'REPLY') {
        return false;
      }

      return tweet.replyToId == null;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getTweetLikes(String tweetId) async {
    try {
      final response = await _dio.get('api/tweets/$tweetId/likes');
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
      final response = await _dio.get('api/tweets/likedtweets');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final List<TweetModel> tweets = [];
      for (var json in (data as List)) {
        try {
          final tweet = TweetModel.fromJson(json);
          tweets.add(tweet);
        } catch (e) {
          // Silently handle error
        }
      }
      return tweets;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getMentionedTweets(String username) async {
    try {
      final response = await _dio.get('api/tweets/users/$username/mentioned');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final List<TweetModel> tweets = [];
      for (var json in (data as List)) {
        try {
          final tweet = TweetModel.fromJson(json);
          tweets.add(tweet);
        } catch (e) {
          // Silently handle error
        }
      }
      return tweets;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getQuotes(String tweetId) async {
    try {
      final response = await _dio.get('api/tweets/$tweetId/quotes');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final List<TweetModel> tweets = [];
      for (var json in (data as List)) {
        try {
          final tweet = TweetModel.fromJson(json);
          tweets.add(tweet);
        } catch (e) {
          // Silently handle error
        }
      }
      return tweets;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getRetweets(String tweetId) async {
    try {
      final response = await _dio.get('api/tweets/$tweetId/retweets');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetSummary> getTweetSummary(String tweetId) async {
    try {
      final response = await _dio.get('api/tweets/$tweetId/summary');
      final data = _extractMap(response.data);
      return TweetSummary.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> searchTweets(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        'api/tweets/search',
        queryParameters: {'query': trimmedQuery, 'page': page, 'limit': limit},
      );

      final tweetsData = _extractList(response.data);
      return tweetsData.map(TweetModel.fromJson).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TweetModel>> getUserTweets(
    String username, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'api/tweets/users/$username',
        queryParameters: {'page': page, 'limit': limit},
      );

      final tweetsData = _extractList(response.data);
      return tweetsData.map(TweetModel.fromJson).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetModel> updateTweet(
    String tweetId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('api/tweets/$tweetId', data: data);

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      return TweetModel.fromJson(tweetData);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
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

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((map) => Map<String, dynamic>.from(map))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((map) => Map<String, dynamic>.from(map))
          .toList();
    }

    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }

    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return Map<String, dynamic>.from(first);
      }
      if (first is Map) {
        return first.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    return <String, dynamic>{};
  }
}
