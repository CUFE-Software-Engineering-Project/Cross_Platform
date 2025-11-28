import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/models/tweet_summary.dart';
import 'package:lite_x/features/home/models/user_profile_model.dart';
import 'package:lite_x/features/media/download_media.dart';

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

      final tweets = await _deserializeTweets(tweetsData);
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

      final tweets = await _deserializeTweets(tweetsData);
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

      return await _deserializeTweets(tweetsData);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<TweetModel> getTweetById(
    String tweetId, {
    bool fetchParent = true,
  }) async {
    try {
      final response = await _dio.get('api/tweets/$tweetId');

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final tweet = await _deserializeTweet(tweetData);
      if (tweet == null) {
        throw Exception('Failed to parse tweet data');
      }

      // Fetch parent tweet if it's a quote tweet and parent is not already loaded
      if (fetchParent &&
          tweet.tweetType == 'QUOTE' &&
          tweet.quotedTweetId != null &&
          tweet.quotedTweet == null) {
        try {
          print('🔄 Fetching parent tweet: ${tweet.quotedTweetId}');
          final parentTweet = await getTweetById(
            tweet.quotedTweetId!,
            fetchParent: false,
          );
          print('✅ Parent tweet fetched successfully');
          return tweet.copyWith(quotedTweet: parentTweet);
        } catch (e) {
          print('⚠️ Failed to fetch parent tweet: $e');
          // Return original tweet even if parent fetch fails
        }
      }

      return tweet;
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
    List<String> mediaIds = const [],
    String? replyToId,
  }) async {
    try {
      if (replyToId != null) {
        return await createReply(
          tweetId: replyToId,
          content: content,
          replyControl: replyControl,
          mediaIds: mediaIds,
        );
      }

      final data = {
        'content': content,
        'replyControl': replyControl,
        'mediaIds': mediaIds,
      };

      print('📤 Creating post with data: $data'); // Debug log

      final response = await _dio.post('api/tweets', data: data);

      print('📥 Post created response: ${response.statusCode}'); // Debug log

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

      final createdTweetId = tweetData['id']?.toString() ?? '';
      if (mediaIds.isNotEmpty && createdTweetId.isNotEmpty) {
        await _attachMediaToTweet(createdTweetId, mediaIds);
        final attachedMedia = await _fetchTweetMediaIds(createdTweetId);
        if (attachedMedia.isNotEmpty) {
          tweetData['media'] = attachedMedia;
        }
      }

      final tweet = await _deserializeTweet(tweetData);
      if (tweet == null) {
        throw Exception('Failed to parse tweet data');
      }
      return tweet;
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

      return await _deserializeTweets(repliesData);
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
    List<String> mediaIds = const [],
  }) async {
    try {
      final data = {
        'content': content,
        'replyControl': replyControl,
        'mediaIds': mediaIds,
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

      final newReplyId = replyData['id']?.toString() ?? '';
      if (mediaIds.isNotEmpty && newReplyId.isNotEmpty) {
        await _attachMediaToTweet(newReplyId, mediaIds);
        final attachedMedia = await _fetchTweetMediaIds(newReplyId);
        if (attachedMedia.isNotEmpty) {
          replyData['media'] = attachedMedia;
        }
      }

      final reply = await _deserializeTweet(replyData);
      if (reply == null) {
        throw Exception('Failed to parse reply data');
      }
      return reply;
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
    List<String> mediaIds = const [],
  }) async {
    try {
      final data = {
        'content': content,
        'quotedTweetId': quotedTweetId,
        'replyControl': replyControl,
        'mediaIds': mediaIds,
      };

      final response = await _dio.post(
        'api/tweets/$quotedTweetId/quotes',
        data: data,
      );

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final tweetId = tweetData['id']?.toString() ?? '';
      if (mediaIds.isNotEmpty && tweetId.isNotEmpty) {
        await _attachMediaToTweet(tweetId, mediaIds);
        final attachedMedia = await _fetchTweetMediaIds(tweetId);
        if (attachedMedia.isNotEmpty) {
          tweetData['media'] = attachedMedia;
        }
      }

      final parsedTweet = await _deserializeTweet(tweetData);
      if (parsedTweet == null) {
        throw Exception('Failed to parse quote tweet data');
      }

      return parsedTweet.copyWith(
        quotedTweetId: quotedTweetId,
        quotedTweet: quotedTweet,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TweetModel>> _deserializeTweets(List<dynamic> data) async {
    final futures = data.map(_deserializeTweet).toList();
    final results = await Future.wait(futures);
    return results.whereType<TweetModel>().toList();
  }

  Future<TweetModel?> _deserializeTweet(dynamic raw) async {
    if (raw is! Map) return null;
    try {
      final map = Map<String, dynamic>.from(raw);
      final tweet = TweetModel.fromJson(map);
      return await _hydrateTweet(tweet);
    } catch (_) {
      return null;
    }
  }

  Future<TweetModel> _hydrateTweet(TweetModel tweet) async {
    String avatar = tweet.authorAvatar;
    if (_shouldDownloadMedia(avatar)) {
      final resolved = await _resolveSingleMedia(avatar);
      if (resolved.isNotEmpty) {
        avatar = resolved;
      }
    }

    List<String> images = tweet.images;
    if (images.isNotEmpty && _shouldDownloadMedia(images.first)) {
      final resolved = await getMediaUrls(images);
      final filtered = resolved.where((url) => url.isNotEmpty).toList();
      if (filtered.isNotEmpty) {
        images = filtered;
      }
    }

    TweetModel? quoted = tweet.quotedTweet;
    // If it's a quote tweet but quoted tweet is not loaded, try to fetch it
    if (quoted == null &&
        tweet.tweetType == 'QUOTE' &&
        tweet.quotedTweetId != null &&
        tweet.quotedTweetId!.isNotEmpty) {
      try {
        print(
          '🔄 Hydrating quote tweet - fetching parent: ${tweet.quotedTweetId}',
        );
        quoted = await getTweetById(tweet.quotedTweetId!, fetchParent: false);
        print('✅ Parent tweet hydrated successfully');
      } catch (e) {
        print('⚠️ Failed to fetch parent tweet for quote: $e');
        // Continue without parent tweet
      }
    } else if (quoted != null) {
      quoted = await _hydrateTweet(quoted);
    }

    return tweet.copyWith(
      authorAvatar: avatar,
      images: images,
      quotedTweet: quoted,
    );
  }

  Future<void> _attachMediaToTweet(
    String tweetId,
    List<String> mediaIds,
  ) async {
    final filteredIds = mediaIds.where((id) => id.isNotEmpty).toList();
    if (tweetId.isEmpty || filteredIds.isEmpty) return;

    try {
      await _dio.post(
        'api/media/add-media-to-tweet',
        data: {'tweetId': tweetId, 'mediaIds': filteredIds},
      );
    } on DioException catch (e) {
      final errorMsg = _handleError(e).toLowerCase();
      // Suppress duplicate media errors as the media is already attached
      if (errorMsg.contains('duplicate') || errorMsg.contains('already')) {
        print('⚠️ Media already attached to tweet (suppressing error)');
        return;
      }
      throw Exception(_handleError(e));
    }
  }

  Future<List<String>> _fetchTweetMediaIds(String tweetId) async {
    if (tweetId.isEmpty) return const [];
    try {
      final response = await _dio.get('api/media/tweet-media/$tweetId');
      final entries = _extractDynamicList(response.data);
      return entries.map(_extractMediaId).where((id) => id.isNotEmpty).toList();
    } on DioException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  List<dynamic> _extractDynamicList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) {
      return data['data'] as List;
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List;
    }
    return const [];
  }

  String _extractMediaId(dynamic entry) {
    if (entry is String) return entry;
    if (entry is Map) {
      final map = entry.map((key, value) => MapEntry(key.toString(), value));
      final candidates = [
        map['mediaId'],
        map['media_id'],
        map['media'] is Map
            ? (map['media'] as Map)['id'] ?? (map['media'] as Map)['mediaId']
            : null,
        map['id'],
      ];

      for (final candidate in candidates) {
        if (candidate == null) continue;
        final value = candidate.toString();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return '';
  }

  Future<String> _resolveSingleMedia(String id) async {
    if (id.isEmpty) return '';
    final urls = await getMediaUrls([id]);
    return urls.isNotEmpty ? urls.first : '';
  }

  bool _shouldDownloadMedia(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    return !(lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('data:'));
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

      // Handle both direct response and nested data structure
      final Map<String, dynamic> data;
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('data')) {
          data = response.data['data'] as Map<String, dynamic>;
        } else {
          data = response.data as Map<String, dynamic>;
        }
      } else {
        data = _extractMap(response.data);
      }

      return TweetSummary.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to parse tweet summary: $e');
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
    Map<String, dynamic> data, {
    List<String> mediaIds = const [],
  }) async {
    try {
      final response = await _dio.patch('api/tweets/$tweetId', data: data);

      final tweetData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;

      final updatedTweetId = tweetData['id']?.toString() ?? tweetId;
      if (mediaIds.isNotEmpty && updatedTweetId.isNotEmpty) {
        await _attachMediaToTweet(updatedTweetId, mediaIds);
        final attachedMedia = await _fetchTweetMediaIds(updatedTweetId);
        if (attachedMedia.isNotEmpty) {
          tweetData['media'] = attachedMedia;
        }
      }

      // Try to deserialize, but if it fails due to type issues,
      // fetch the tweet fresh from the server
      TweetModel? tweet;
      try {
        tweet = await _deserializeTweet(tweetData);
      } catch (typeError) {
        // If deserialization fails (likely due to type conversion),
        // fetch the updated tweet from server
        print('⚠️ Deserialization failed, fetching fresh: $typeError');
        final freshResponse = await _dio.get('api/tweets/$updatedTweetId');
        final freshData =
            freshResponse.data is Map && freshResponse.data['data'] != null
            ? freshResponse.data['data']
            : freshResponse.data;
        tweet = await _deserializeTweet(freshData);
      }

      if (tweet == null) {
        throw Exception('Failed to parse tweet data');
      }
      return tweet;
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

      print('❌ API Error: $statusCode - $data'); // Debug log

      String message = 'Unknown error';
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'].toString();
      } else if (data is String) {
        message = data;
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

  Future<UserProfileModel> getUserProfile(String username) async {
    try {
      print('📤 Fetching user profile for: $username');
      final response = await _dio.get('api/users/$username');

      print('📥 User profile response: ${response.data}');

      final Map<String, dynamic> userData = _extractMap(response.data);
      return UserProfileModel.fromJson(userData);
    } on DioException catch (e) {
      print('❌ Failed to fetch user profile: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('❌ Unexpected error fetching user profile: $e');
      rethrow;
    }
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
