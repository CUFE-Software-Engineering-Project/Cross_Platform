import '../core/interfaces/notification_repository_interface.dart';
import '../core/interfaces/notification_data_source_interface.dart';
import '../core/interfaces/notification_socket_interface.dart';
import '../models/notification_model.dart';

/// Concrete implementation of notification repository
/// Follows Dependency Inversion Principle (DIP)
class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationDataSource _dataSource;
  final INotificationSocket _socket;

  NotificationRepositoryImpl({
    required INotificationDataSource dataSource,
    required INotificationSocket socket,
  }) : _dataSource = dataSource, _socket = socket;

  @override
  Future<List<NotificationModel>> fetchNotifications(String token) {
    return _dataSource.fetchNotifications(token);
  }

  @override
  Future<int> getUnseenCount(String token) {
    return _dataSource.getUnseenCount(token);
  }

  @override
  Future<void> markAsRead(String token, String notificationId) {
    return _dataSource.markAsRead(token, notificationId);
  }

  @override
  Future<List<NotificationModel>> getUnseenNotifications(String token) {
    return _dataSource.getUnseenNotifications(token);
  }

  @override
  Future<NotificationModel> addNotification(String token, NotificationInputModel notificationInput) {
    return _dataSource.addNotification(token, notificationInput);
  }

  @override
  void connectSocket(String token, String userId, Function(NotificationModel) onNotification) {
    _socket.connect(token, userId, onNotification);
  }

  @override
  void disconnectSocket() {
    _socket.disconnect();
  }
}
