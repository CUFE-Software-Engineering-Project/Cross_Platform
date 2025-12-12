import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';

final hashtagServiceProvider = Provider<HashtagService>((ref) {
  return HashtagService(ref.read(dioProvider));
});

class HashtagSuggestion {
  final String hashtag;
  final int tweetCount;

  HashtagSuggestion({required this.hashtag, required this.tweetCount});

  factory HashtagSuggestion.fromJson(Map<String, dynamic> json) {
    return HashtagSuggestion(
      hashtag: json['hashtag'] ?? '',
      tweetCount: json['tweetCount'] ?? 0,
    );
  }
}

class HashtagService {
  final Dio _dio;

  HashtagService(this._dio);

  /// Fetch trending hashtags from the API
  /// [query] parameter filters hashtags if provided (optional)
  /// [limit] specifies the maximum number of results to return
  /// [category] filters by category (e.g., 'sports', 'entertainment')
  Future<List<HashtagSuggestion>> fetchTrendingHashtags({
    String? query,
    int limit = 10,
    String? category,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        if (limit > 0) 'limit': limit.toString(),
        if (query != null && query.isNotEmpty) 'q': query,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await _dio
          .get(
            'api/hashtags/trends',
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
          )
          .timeout(const Duration(seconds: 10));

      final data = response.data;

      // Handle both array response and object with trends array
      List<dynamic> trendsData;
      if (data is List) {
        trendsData = data;
      } else if (data is Map && data.containsKey('trends')) {
        trendsData = data['trends'] as List;
      } else {
        return [];
      }

      return trendsData
          .map((item) {
            // Handle different response formats
            if (item is Map<String, dynamic>) {
              // Extract hashtag text (might be in 'hashtag', 'title', or 'name' field)
              final hashtagText =
                  item['hashtag'] ?? item['title'] ?? item['name'] ?? '';
              final count =
                  item['tweetCount'] ?? item['postCount'] ?? item['count'] ?? 0;

              return HashtagSuggestion(
                hashtag: hashtagText.toString().replaceFirst('#', ''),
                tweetCount: count is int ? count : 0,
              );
            }
            return null;
          })
          .where((item) => item != null)
          .cast<HashtagSuggestion>()
          .toList();
    } on DioException catch (e) {
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Search hashtags with a specific query (debounced for typing)
  Future<List<HashtagSuggestion>> searchHashtags(String query) async {
    if (query.isEmpty) return [];

    // Remove # if user typed it
    final cleanQuery = query.replaceFirst('#', '');

    return fetchTrendingHashtags(query: cleanQuery, limit: 5);
  }
}
