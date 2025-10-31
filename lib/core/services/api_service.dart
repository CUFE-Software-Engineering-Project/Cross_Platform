import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl =
      'https://app-fd6adf10-3923-46c1-83f7-08c318e4c982.cleverapps.io';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Temporary access token for testing (until auth is fully implemented)
          const tempAccessToken =
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VybmFtZSI6InlhcmEiLCJlbWFpbCI6InlhcmFmYXJvdWs5NjBAZ21haWwuY29tIiwiaWQiOiI2NTUyZDcyYy0zZjI3LTQ0NWQtOGFkOC1iYzIyY2RhOWRkZDkiLCJleHAiOjE3NjE5NDA0MTcsImlhdCI6MTc2MTkzNjgxNywidmVyc2lvbiI6MCwianRpIjoiNTBmOTQ2ZjgtNDNmZC00MjAzLThjYTgtN2U1ODU0YjQ4ZGYwIiwiZGV2aWQiOiJjM2FkNWI1Yy0wOTM5LTRkZDAtYjMyOC04YTg0MGIzOTM0YWUifQ.zw7jVnuR8PbpIopySEWLczwyZm53AhwK8gYODDIWojM';
          options.headers['Authorization'] = 'Bearer $tempAccessToken';

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Tweet endpoints
  Future<Response> getTweets({int page = 1, int limit = 20}) async {
    return await _dio.get(
      '/api/tweets',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Response> getForYouTweets({int page = 1, int limit = 20}) async {
    return await _dio.get(
      '/api/home/for-you',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Response> getFollowingTweets({int page = 1, int limit = 20}) async {
    return await _dio.get(
      '/api/home/timeline',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Response> getTweetById(String tweetId) async {
    return await _dio.get('/api/tweets/$tweetId');
  }

  Future<Response> createTweet(Map<String, dynamic> data) async {
    return await _dio.post('/api/tweets', data: data);
  }

  Future<Response> deleteTweet(String tweetId) async {
    return await _dio.delete('/api/tweets/$tweetId');
  }

  Future<Response> likeTweet(String tweetId) async {
    return await _dio.post('/api/tweets/$tweetId/like');
  }

  Future<Response> unlikeTweet(String tweetId) async {
    return await _dio.delete('/api/tweets/$tweetId/like');
  }

  Future<Response> retweetTweet(String tweetId) async {
    return await _dio.post('/api/tweets/$tweetId/retweet');
  }

  Future<Response> unretweetTweet(String tweetId) async {
    return await _dio.delete('/api/tweets/$tweetId/retweet');
  }

  Future<Response> bookmarkTweet(String tweetId) async {
    return await _dio.post('/api/tweets/$tweetId/bookmark');
  }

  Future<Response> unbookmarkTweet(String tweetId) async {
    return await _dio.delete('/api/tweets/$tweetId/bookmark');
  }

  Future<Response> getReplies(String tweetId) async {
    return await _dio.get('/api/tweets/$tweetId/replies');
  }

  Future<Response> createReply(
    String tweetId,
    Map<String, dynamic> data,
  ) async {
    return await _dio.post('/api/tweets/$tweetId/replies', data: data);
  }

  Future<Response> createQuoteTweet(Map<String, dynamic> data) async {
    return await _dio.post('/api/tweets/quote', data: data);
  }

  Future<Response> getQuotes(String tweetId) async {
    return await _dio.get('/api/tweets/$tweetId/quotes');
  }

  Future<Response> getRetweets(String tweetId) async {
    return await _dio.get('/api/tweets/$tweetId/retweets');
  }

  Future<Response> updateTweet(
    String tweetId,
    Map<String, dynamic> data,
  ) async {
    return await _dio.patch('/api/tweets/$tweetId', data: data);
  }

  Future<Response> getTweetLikes(String tweetId) async {
    return await _dio.get('/api/tweets/$tweetId/likes');
  }

  Future<Response> getLikedTweets() async {
    return await _dio.get('/api/tweets/likedtweets');
  }

  Future<Response> getMentionedTweets(String username) async {
    return await _dio.get('/api/tweets/user/$username/mentioned');
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get('/api/users/me');
  }

  Future<Response> getUserById(String userId) async {
    return await _dio.get('/api/users/$userId');
  }
}
