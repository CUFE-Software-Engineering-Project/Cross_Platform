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
      // 1. Fetch notifications
      final resp = await dio.get('/api/notifications');

      if (resp.statusCode != 200) {
        throw Exception("Failed to load notifications");
      }

      // Handle both List and Map responses
      List<dynamic> data;
      if (resp.data is List) {
        data = resp.data as List<dynamic>;
      } else if (resp.data is Map) {
        final mapData = resp.data as Map<String, dynamic>;
        // Try common keys for the notifications array
        if (mapData.containsKey('notifications')) {
          data = mapData['notifications'] as List<dynamic>;
        } else if (mapData.containsKey('data')) {
          data = mapData['data'] as List<dynamic>;
        } else if (mapData.containsKey('items')) {
          data = mapData['items'] as List<dynamic>;
        } else {
          // If no common key found, try to get the first list value
          final listValue = mapData.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No notifications array found in response'),
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
        } catch (e, stackTrace) {
          rethrow;
        }
      }

      // 2. Build NotificationItem list
      List<NotificationItem> items = [];

      for (var notification in notifications) {
        String mediaUrl = '';

        // 3. Fetch actor media if profileMediaId exists and is not empty
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
            // If media fetch fails, continue with empty mediaUrl
          }
        }

        // 4. Build NotificationItem
        final item = NotificationItem(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          isRead: notification.isRead,
          mediaUrl: mediaUrl,
        );

        items.add(item);
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }
}
