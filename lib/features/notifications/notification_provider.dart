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

final notificationsProvider = AsyncNotifierProvider<NotificationsController, List<NotificationItem>>(
  () => NotificationsController(),
);
