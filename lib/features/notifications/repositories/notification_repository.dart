import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import '../notification_model.dart';

class NotificationRepository {
  final Ref ref;

  NotificationRepository(this.ref);

  Future<List<NotificationItem>> fetchNotifications() async {

    final dio = ref.read(dioProvider);

    try {
      final resp = await dio.get('api/notifications');

      if (resp.statusCode != 200) {
        throw Exception("Failed to load notifications");
      }

      List<dynamic> data;
      if (resp.data is List) {
        data = resp.data as List<dynamic>;
      } else if (resp.data is Map) {
        final mapData = resp.data as Map<String, dynamic>;
        if (mapData.containsKey('notifications')) {
          data = mapData['notifications'] as List<dynamic>;
        } else if (mapData.containsKey('data')) {
          data = mapData['data'] as List<dynamic>;
        } else if (mapData.containsKey('items')) {
          data = mapData['items'] as List<dynamic>;
        } else {
          final listValue = mapData.values.firstWhere(
            (value) => value is List,
            orElse: () =>
                throw Exception('No notifications array found in response'),
          );
          data = listValue as List<dynamic>;
        }
      } else {
        throw Exception('Unexpected response type: ${resp.data.runtimeType}');
      }

      List<Notification> notifications = [];
      for (int i = 0; i < data.length; i++) {
        try {
          final notification = Notification.fromJson(
            (data[i] as Map<dynamic, dynamic>).cast<String, dynamic>(),
          );
          notifications.add(notification);
        } catch (e) {
          rethrow;
        }
      }

      List<NotificationItem> items = [];

      for (var notification in notifications) {
        String mediaUrl = '';
        final profileMediaId = notification.actor.profileMediaId;
        if (profileMediaId.isNotEmpty && profileMediaId != 'null') {
          try {
            final mediaResp = await dio.get(
              'api/media/download-request/$profileMediaId',
            );

            if (mediaResp.statusCode == 200) {
              final media = MediaInfo.fromJson(mediaResp.data);
              mediaUrl = media.url;
            }
          } catch (e) {
            // ignore media fetch errors for now
          }
        }

        int repliesCount = 0;
        int repostsCount = 0;
        int likesCount = 0;
        bool isLiked = false;
        bool isRetweeted = false;
        EmbeddedTweet? embeddedTweet;
        String? quotedAuthor;
        String? quotedContent;

        final tweetId = notification.tweetId;
        if (tweetId != null && tweetId.isNotEmpty) {
          try {
            final tweetResp = await dio.get('api/tweets/$tweetId');

            if (tweetResp.statusCode == 200 && tweetResp.data is Map) {
              final tweetJson =
                  (tweetResp.data as Map<dynamic, dynamic>).cast<String, dynamic>();

              embeddedTweet = EmbeddedTweet.fromJson(tweetJson);
              repliesCount = embeddedTweet.repliesCount;
              repostsCount = embeddedTweet.retweetCount;
              likesCount = embeddedTweet.likesCount;
              isLiked = embeddedTweet.isLiked;
              isRetweeted = embeddedTweet.isRetweeted;

              if (notification.title == 'QUOTE' &&
                  embeddedTweet.parentId != null &&
                  embeddedTweet.parentId!.isNotEmpty) {
                try {
                  final parentResp = await dio.get(
                    'api/tweets/${embeddedTweet.parentId}',
                  );

                  if (parentResp.statusCode == 200 && parentResp.data is Map) {
                    final parentJson = (parentResp.data as Map<dynamic, dynamic>)
                        .cast<String, dynamic>();
                    final parentTweet = EmbeddedTweet.fromJson(parentJson);
                    quotedAuthor = parentTweet.user.name;
                    quotedContent = parentTweet.content;
                  }
                } catch (_) {
                  // ignore parent tweet fetch errors for now
                }
              }
            }
          } catch (_) {
            // ignore tweet fetch errors for now
          }
        }

        final item = NotificationItem(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          isRead: notification.isRead,
          mediaUrl: mediaUrl,
          tweetId: notification.tweetId,
          createdAt: notification.createdAt,
          actor: notification.actor,
          targetUsername: null,
          quotedAuthor: quotedAuthor,
          quotedContent: quotedContent,
          repliesCount: repliesCount,
          repostsCount: repostsCount,
          likesCount: likesCount,
          isLiked: isLiked,
          isRetweeted: isRetweeted,
          isBookmarked: embeddedTweet?.isBookmarked ?? false,
          tweet: embeddedTweet,
        );

        items.add(item);
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }
}