import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/notifications/repositories/notification_repository.dart';
import 'notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref);
});

class NotificationsController extends AsyncNotifier<List<NotificationItem>> {
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      return await repo.fetchNotifications();
    });
  }

  @override
  Future<List<NotificationItem>> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    final items = await repo.fetchNotifications();
    return items;
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationItem>>(
      () => NotificationsController(),
    );

/// Stream provider for real-time notifications via socket
/// Ensures initial data is loaded before streaming updates
final notificationsStreamProvider = 
    StreamProvider<List<NotificationItem>>((ref) async* {
  final repo = ref.read(notificationRepositoryProvider);
  
  // Ensure initial data is loaded from REST API
  await repo.fetchNotifications();
  
  // Yield the current list of notifications
  yield repo.notifications;
  
  // Then stream updates from socket
  yield* repo.notificationsStream;
});

/// Stream provider for unseen notification count
final unseenNotificationsCountProvider =
    StreamProvider<int>((ref) async* {
  final repo = ref.read(notificationRepositoryProvider);
  yield* repo.unseenCountStream;
});

/// Stream provider for mentions and replies
/// Ensures initial data is loaded before streaming updates
final mentionsStreamProvider =
    StreamProvider<List<NotificationItem>>((ref) async* {
  final repo = ref.read(notificationRepositoryProvider);
  
  // Ensure initial mentions data is loaded from REST API
  await repo.fetchMentions();
  
  // Yield the current list of mentions
  yield repo.mentions;
  
  // Then stream updates from socket
  yield* repo.mentionsStream;
});

/// Future provider for initial mentions load from /api/notifications/mentions endpoint
final mentionsFutureProvider =
    FutureProvider<List<NotificationItem>>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return await repo.fetchMentions();
});