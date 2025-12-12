import 'package:dio/dio.dart';
import '../models/tweet_model.dart';

class MentionedTweetsRepository {
  final Dio _dio;

  MentionedTweetsRepository(this._dio);

  /// Fetch tweets that mention a specific user
  /// [username] - The username to search mentions for (without @)
  /// [limit] - Number of tweets to fetch (default 20)
  /// [cursor] - Pagination cursor for next page
  Future<Map<String, dynamic>> fetchMentionedTweets({
    required String username,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      // Remove @ if user included it
      final cleanUsername = username.replaceFirst('@', '');

      final response = await _dio.get(
        'api/tweets/users/$cleanUsername/mentioned',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Parse tweets
        List<TweetModel> tweets = [];
        if (data['data'] != null) {
          tweets = (data['data'] as List)
              .map((tweetJson) => TweetModel.fromJson(tweetJson))
              .toList();
        }

        // Get next cursor for pagination
        final nextCursor = data['cursor'] as String?;

        return {
          'tweets': tweets,
          'nextCursor': nextCursor,
          'hasMore': nextCursor != null && nextCursor.isNotEmpty,
        };
      } else if (response.statusCode == 404) {
        // User not found or no mentions
        return {'tweets': <TweetModel>[], 'nextCursor': null, 'hasMore': false};
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Failed to load mentioned tweets: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'tweets': <TweetModel>[], 'nextCursor': null, 'hasMore': false};
      }
      throw Exception('Error fetching mentioned tweets: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching mentioned tweets: $e');
    }
  }
}
