import '../../models/notification_model.dart';

/// Abstract interface for notification repository
/// Follows Dependency Inversion Principle (DIP)
abstract class INotificationRepository {
  Future<List<NotificationModel>> fetchNotifications(String token);
  Future<int> getUnseenCount(String token);
  Future<void> markAsRead(String token, String notificationId);
  Future<List<NotificationModel>> getUnseenNotifications(String token);
  Future<NotificationModel> addNotification(String token, NotificationInputModel notificationInput);
  void connectSocket(String token, String userId, Function(NotificationModel) onNotification);
  void disconnectSocket();
}
