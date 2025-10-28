import '../../models/notification_model.dart';

/// Abstract interface for notification data source
/// Follows Single Responsibility Principle (SRP)
abstract class INotificationDataSource {
  Future<List<NotificationModel>> fetchNotifications(String token);
  Future<int> getUnseenCount(String token);
  Future<void> markAsRead(String token, String notificationId);
  Future<List<NotificationModel>> getUnseenNotifications(String token);
  Future<NotificationModel> addNotification(String token, NotificationInputModel notificationInput);
}
