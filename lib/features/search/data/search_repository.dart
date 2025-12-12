import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';

enum SearchTab { TOP, LATEST, PEOPLE, MEDIA }

class SearchSuggestionUser {
  final String id;
  final String name;
  final String userName;
  final String? bio;
  final String? avatarUrl;
  final int followers;
  final bool verified;
  final bool isFollowing;
  final bool isFollower;

  const SearchSuggestionUser({
    required this.id,
    required this.name,
    required this.userName,
    required this.bio,
    required this.avatarUrl,
    required this.followers,
    required this.verified,
    required this.isFollowing,
    required this.isFollower,
  });

  factory SearchSuggestionUser.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    final profileMedia = json['profileMedia'];
    String? avatar;
    if (profileMedia is Map<String, dynamic>) {
      avatar = profileMedia['id']?.toString();
    } else if (profileMedia is String) {
      avatar = profileMedia;
    }

    return SearchSuggestionUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userName: json['username']?.toString() ?? '',
      bio: json['bio']?.toString(),
      avatarUrl: avatar,
      followers: (count?['followers'] as num?)?.toInt() ?? 0,
      verified: json['verified'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollower: json['isFollower'] as bool? ?? false,
    );
  }
}

class TweetSearchPage {
  final List<TweetModel> tweets;
  final String? nextCursor;

  const TweetSearchPage({
    required this.tweets,
    required this.nextCursor,
  });
}

class UserSearchPage {
  final List<SearchSuggestionUser> users;
  final String? nextCursor;

  const UserSearchPage({
    required this.users,
    required this.nextCursor,
  });
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref);
});

class SearchRepository {
  final Ref _ref;

  SearchRepository(this._ref);

  Dio get _dio => _ref.read(dioProvider);
  HomeRepository get _homeRepo => _ref.read(homeRepositoryProvider);

  Future<UserSearchPage> searchUsers(String query,
      {String? cursor, int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const UserSearchPage(users: [], nextCursor: null);
    }

    try {
      final response = await _dio.get(
        'api/users/search',
        queryParameters: {
          'query': trimmed,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor
        },
      );

      dynamic data = response.data;
      String? nextCursor;
      List<dynamic> rawUsers;

      if (data is List) {
        rawUsers = data;
      } else if (data is Map<String, dynamic>) {
        nextCursor = data['nextCursor']?.toString();
        final usersField = data['users'] ?? data['data'] ?? data['items'];
        if (usersField is List) {
          rawUsers = usersField;
        } else {
          rawUsers = const [];
        }
      } else {
        rawUsers = const [];
      }

      final users = rawUsers
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map(SearchSuggestionUser.fromJson)
          .toList();

      return UserSearchPage(users: users, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetSearchPage> searchTweets({
    required String query,
    required SearchTab tab,
    String peopleFilter = 'ANYONE',
    String? cursor,
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const TweetSearchPage(tweets: [], nextCursor: null);
    }

    try {
      final response = await _dio.get(
        'api/tweets/search',
        queryParameters: {
          'query': trimmed,
          'searchTab': _mapTabToBackend(tab),
          'peopleFilter': peopleFilter,
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );

      dynamic data = response.data;
      String? nextCursor;
      List<dynamic> rawTweets;

      if (data is List) {
        rawTweets = data;
      } else if (data is Map<String, dynamic>) {
        nextCursor = data['nextCursor']?.toString();
        final tweetsField =
            data['data'] ?? data['tweets'] ?? data['items'] ?? data['results'];
        if (tweetsField is List) {
          rawTweets = tweetsField;
        } else {
          rawTweets = const [];
        }
      } else {
        rawTweets = const [];
      }

      final tweets = rawTweets
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map(TweetModel.fromJson)
          .toList();

      return TweetSearchPage(tweets: tweets, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TweetModel> toggleLike(String tweetId, bool isCurrentlyLiked) {
    return _homeRepo.toggleLike(tweetId, isCurrentlyLiked);
  }

  String _mapTabToBackend(SearchTab tab) {
    switch (tab) {
      case SearchTab.TOP:
        return 'TOP';
      case SearchTab.LATEST:
        return 'LATEST';
      case SearchTab.MEDIA:
        return 'MEDIA';
      case SearchTab.PEOPLE:
        return 'TOP';
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Unknown error';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is Map && data['error'] != null) {
        message = data['error'].toString();
      } else if (data is String) {
        message = data;
      }

      return 'Error $statusCode: $message';
    }

    return error.message ?? 'Network error';
  }
}
