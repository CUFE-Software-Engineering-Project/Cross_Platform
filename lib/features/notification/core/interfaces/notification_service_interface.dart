import '../../models/notification_model.dart';

/// Abstract interface for notification service
/// Follows Interface Segregation Principle (ISP)
abstract class INotificationService {
  Future<void> initialize(String token, String userId);
  Future<List<AppNotification>> getNotifications();
  Future<int> getUnseenCount();
  Future<void> markAsRead(String notificationId);
  Future<void> refreshNotifications();
  Stream<List<AppNotification>> get notificationsStream;
  Stream<int> get unseenCountStream;
}
