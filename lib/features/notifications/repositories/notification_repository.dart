import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import '../notification_model.dart';

class NotificationRepository {
  final Ref ref;

  NotificationRepository(this.ref);

  Future<List<NotificationItem>> fetchNotifications() async {
    // Return mock data for now to match the desired UI reference.
    return _getMockNotifications();

    /*
    final dio = ref.read(dioProvider);

    try {
      final resp = await dio.get('/api/notifications');

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
          final notification = Notification.fromJson(data[i]);
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
              '/api/media/download-request/$profileMediaId',
            );

            if (mediaResp.statusCode == 200) {
              final media = MediaInfo.fromJson(mediaResp.data);
              mediaUrl = media.url;
            }
          } catch (e) {
            // ignore media fetch errors for now
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
          quotedAuthor: null,
          quotedContent: null,
          repliesCount: 0,
          repostsCount: 0,
          likesCount: 0,
        );

        items.add(item);
      }

      return items;
    } catch (e) {
      rethrow;
    }
    */
  }

  List<NotificationItem> _getMockNotifications() {
    final now = DateTime.now();

    return [
      NotificationItem(
        id: '1',
        title: 'REPOST',
        body:
            'pic.x.com/TchBxuAOMJ pic.x.com/TchBxuAOMJ pic.x.com/TchBxuAOMJ pic.x.com/TchBxuAOMJ',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=1',
        tweetId: 'tweet_001',
        createdAt: now.subtract(const Duration(minutes: 51)).toIso8601String(),
        actor: Actor(
          name: 'Abd El-Rhman Zakaria',
          username: 'TheMentorIo',
          profileMediaId: '1',
        ),
        targetUsername: 'abdalrhman_ziko',
        repliesCount: 0,
        repostsCount: 2,
        likesCount: 0,
      ),
      NotificationItem(
        id: '2',
        title: 'REPLY',
        body: 'lol',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=1',
        tweetId: 'tweet_002',
        createdAt: now.subtract(const Duration(minutes: 51)).toIso8601String(),
        actor: Actor(
          name: 'Abd El-Rhman Zakaria',
          username: 'TheMentorIo',
          profileMediaId: '1',
        ),
        targetUsername: 'abdalrhman_ziko',
        repliesCount: 0,
        repostsCount: 4,
        likesCount: 0,
      ),
      NotificationItem(
        id: '3',
        title: 'REPLY',
        body: 'league',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=1',
        tweetId: 'tweet_003',
        createdAt: now.subtract(const Duration(minutes: 53)).toIso8601String(),
        actor: Actor(
          name: 'Abd El-Rhman Zakaria',
          username: 'TheMentorIo',
          profileMediaId: '1',
        ),
        targetUsername: 'abdalrhman_ziko',
        quotedAuthor: 'Abd Alrhman Zakaria',
        quotedContent: '@TheMentorIo test test',
        repliesCount: 0,
        repostsCount: 3,
        likesCount: 0,
      ),
      NotificationItem(
        id: '4',
        title: 'REPLY',
        body: 'lol',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=1',
        tweetId: 'tweet_004',
        createdAt: now.subtract(const Duration(minutes: 53)).toIso8601String(),
        actor: Actor(
          name: 'Abd El-Rhman Zakaria',
          username: 'TheMentorIo',
          profileMediaId: '1',
        ),
        targetUsername: 'abdalrhman_ziko',
        repliesCount: 0,
        repostsCount: 4,
        likesCount: 0,
      ),
      NotificationItem(
        id: '5',
        title: 'ALERT',
        body:
            'There was a login to your account @abdalrhman_ziko from a new device on Nov 25, 2025. Review it now.',
        isRead: false,
        mediaUrl: '',
        tweetId: null,
        createdAt: now.subtract(const Duration(minutes: 54)).toIso8601String(),
        actor: Actor(name: 'System', username: 'X', profileMediaId: ''),
      ),
      NotificationItem(
        id: '6',
        title: 'REPLY',
        body:
            '@abdalrhman_ziko sssssssssssssssstttttttteeeeeeeeeeesssssssssssssttttttttteeeeeeeeeessssssssssttttttttttteeeeeeeeesssssss',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=1',
        tweetId: 'tweet_005',
        createdAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
        actor: Actor(
          name: 'Abd El-Rhman Zakaria',
          username: 'TheMentorIo',
          profileMediaId: '1',
        ),
        targetUsername: 'abdalrhman_ziko',
        repliesCount: 0,
        repostsCount: 0,
        likesCount: 0,
      ),
      NotificationItem(
        id: '7',
        title: 'LIKE',
        body: '“Working on the next version of the app, stay tuned.”',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=2',
        tweetId: 'tweet_006',
        createdAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
        actor: Actor(
          name: 'Laila Hussein',
          username: 'laila.codes',
          profileMediaId: '2',
        ),
        targetUsername: 'abdalrhman_ziko',
        repliesCount: 0,
        repostsCount: 0,
        likesCount: 1,
      ),
      NotificationItem(
        id: '8',
        title: 'UNLIKE',
        body: 'pic.x.com/ZXcL0gT8 pic.x.com/ZXcL0gT8',
        isRead: false,
        mediaUrl: 'https://i.pravatar.cc/150?img=3',
        tweetId: 'tweet_007',
        createdAt: now.subtract(const Duration(hours: 7)).toIso8601String(),
        actor: Actor(
          name: 'Karim Atef',
          username: 'atefkarim',
          profileMediaId: '3',
        ),
        targetUsername: 'abdalrhman_ziko',
        repliesCount: 0,
        repostsCount: 0,
        likesCount: 0,
      ),
    ];
  }
}
