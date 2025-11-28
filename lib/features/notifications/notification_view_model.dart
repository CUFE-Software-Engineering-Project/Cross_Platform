import 'package:riverpod_annotation/riverpod_annotation.dart';
import './repositories/notification_repository.dart';
import 'notification_model.dart';
import './notification_provider.dart';

part 'notification_view_model.g.dart';

@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  @override
  Future<List<NotificationItem>> build() async {
    return _fetchNotifications();
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    final repo = ref.read(notificationRepositoryProvider);
    return repo.fetchNotifications();
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      return _fetchNotifications();
    });
    
    if (ref.mounted) {
      state = result;
    }
  }

  Future<void> markAsRead(String id) async {
    if (!ref.mounted) return;
    
    final current = state.value;
    if (current == null) return;

    final updated = current.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    if (ref.mounted) {
      state = AsyncData(updated);
    }
  }
}
