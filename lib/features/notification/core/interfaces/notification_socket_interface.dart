import '../../models/notification_model.dart';

/// Abstract interface for notification socket
/// Follows Interface Segregation Principle (ISP)
abstract class INotificationSocket {
  void connect(String token, String userId, Function(NotificationModel) onNotification);
  void disconnect();
  bool get isConnected;
  Stream<NotificationModel> get notificationStream;
}
