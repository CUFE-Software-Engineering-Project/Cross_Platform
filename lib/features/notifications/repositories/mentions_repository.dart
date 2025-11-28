import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import '../mentions_model.dart';

class MentionsRepository {
  final Ref ref;

  MentionsRepository(this.ref);

  Future<List<MentionItem>> fetchMentions() async {
    final dio = ref.read(dioProvider);
    
    // Get current user to fetch their mentions
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.username.isEmpty) {
      throw Exception('User not logged in or username not available');
    }

    try {
      // 1. Fetch mentions
      final resp = await dio.get('/api/tweets/users/${currentUser.username}/mentioned');

      if (resp.statusCode != 200) {
        throw Exception("Failed to load mentions");
      }

      // Handle both List and Map responses
      List<dynamic> data;
      if (resp.data is List) {
        data = resp.data as List<dynamic>;
      } else if (resp.data is Map) {
        final mapData = resp.data as Map<String, dynamic>;
        // Try common keys for the tweets array
        if (mapData.containsKey('tweets')) {
          data = mapData['tweets'] as List<dynamic>;
        } else if (mapData.containsKey('data')) {
          data = mapData['data'] as List<dynamic>;
        } else if (mapData.containsKey('items')) {
          data = mapData['items'] as List<dynamic>;
        } else {
          // If no common key found, try to get the first list value
          final listValue = mapData.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No tweets array found in response'),
          );
          data = listValue as List<dynamic>;
        }
      } else {
        throw Exception('Unexpected response type: ${resp.data.runtimeType}');
      }

      // 2. Parse tweets and resolve media URLs
      List<MentionItem> mentionItems = [];

      for (var tweetData in data) {
        try {
          // Parse the tweet
          final tweet = Tweet.fromJson(tweetData);

          // 3. Resolve profile media URL if exists
          // Note: TweetMedia.id will store the resolved URL (not the original ID)
          TweetMedia? resolvedProfileMedia;
          if (tweet.user.profileMedia != null) {
            try {
              final profileMediaResp = await dio.get(
                '/api/media/download-request/${tweet.user.profileMedia!.id}',
              );

              if (profileMediaResp.statusCode == 200) {
                final media = MediaInfo.fromJson(profileMediaResp.data);
                // Store the resolved URL in TweetMedia.id for UI consumption
                resolvedProfileMedia = TweetMedia(id: media.url);
              } else {
                // Keep original if fetch fails
                resolvedProfileMedia = tweet.user.profileMedia;
              }
            } catch (e) {
              // If profile media fetch fails, keep original
              resolvedProfileMedia = tweet.user.profileMedia;
            }
          }

          // 4. Resolve all media URLs for tweet media
          List<MediaInfo> mediaUrls = [];
          for (var mediaId in tweet.mediaIds) {
            try {
              final mediaResp = await dio.get(
                '/api/media/download-request/$mediaId',
              );

              if (mediaResp.statusCode == 200) {
                final media = MediaInfo.fromJson(mediaResp.data);
                mediaUrls.add(media);
              }
            } catch (e) {
              // If media fetch fails, skip this media
            }
          }

          // 5. Create MentionItem with resolved URLs
          // Update user with resolved profile media (URL stored in id field)
          final updatedUser = tweet.user.copyWith(
            profileMedia: resolvedProfileMedia,
          );

          final mentionItem = MentionItem(
            id: tweet.id,
            content: tweet.content,
            createdAt: tweet.createdAt,
            likesCount: tweet.likesCount,
            retweetCount: tweet.retweetCount,
            repliesCount: tweet.repliesCount,
            quotesCount: tweet.quotesCount,
            replyControl: tweet.replyControl,
            parentId: tweet.parentId,
            tweetType: tweet.tweetType,
            user: updatedUser,
            mediaIds: tweet.mediaIds,
            mediaUrls: mediaUrls,
            isLiked: tweet.isLiked,
            isRetweeted: tweet.isRetweeted,
            isBookmarked: tweet.isBookmarked,
          );

          mentionItems.add(mentionItem);
        } catch (e) {
          // If parsing fails for one tweet, skip it and continue
          continue;
        }
      }

      return mentionItems;
    } catch (e) {
      rethrow;
    }
  }
}
