import 'dart:async';
import '../core/interfaces/notification_service_interface.dart';
import '../core/interfaces/notification_repository_interface.dart';
import '../models/notification_model.dart';

/// Concrete implementation of notification service
/// Follows Single Responsibility Principle (SRP)
class NotificationServiceImpl implements INotificationService {
  final INotificationRepository _repository;
  final StreamController<List<AppNotification>> _notificationsController = StreamController<List<AppNotification>>.broadcast();
  final StreamController<int> _unseenCountController = StreamController<int>.broadcast();

  List<AppNotification> _notifications = [];
  int _unseenCount = 0;
  String? _currentToken;

  NotificationServiceImpl({required INotificationRepository repository}) : _repository = repository;

  @override
  Future<List<AppNotification>> getNotifications() async {
    if (_currentToken == null) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      final notificationModels = await _repository.fetchNotifications(_currentToken!);
      _notifications = notificationModels.map((model) => _convertToAppNotification(model)).toList();
      _notificationsController.add(_notifications);
      return _notifications;
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<int> getUnseenCount() async {
    if (_currentToken == null) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      _unseenCount = await _repository.getUnseenCount(_currentToken!);
      _unseenCountController.add(_unseenCount);
      return _unseenCount;
    } catch (e) {
      throw Exception('Failed to fetch unseen count: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (_currentToken == null) {
      throw Exception('Not authenticated. Please login first.');
    }

    try {
      await _repository.markAsRead(_currentToken!, notificationId);
      await refreshNotifications();
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> refreshNotifications() async {
    await getNotifications();
    await getUnseenCount();
  }

  @override
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;

  @override
  Stream<int> get unseenCountStream => _unseenCountController.stream;

  /// Initialize the service with authentication
  Future<void> initialize(String token, String userId) async {
    _currentToken = token;
    
    // Set up socket connection for real-time updates
    _repository.connectSocket(token, userId, _handleNewNotification);
    
    // Load initial data
    await refreshNotifications();
  }

  /// Handle new notifications from socket
  void _handleNewNotification(NotificationModel notification) {
    final appNotification = _convertToAppNotification(notification);
    _notifications.insert(0, appNotification);
    _unseenCount++;
    _notificationsController.add(_notifications);
    _unseenCountController.add(_unseenCount);
  }

  /// Convert NotificationModel to AppNotification
  AppNotification _convertToAppNotification(NotificationModel notification) {
    final user = User(
      id: notification.actorId ?? '',
      username: (notification.actorId ?? 'user').toString(),
      name: '',
      avatarUrl: 'https://picsum.photos/id/100/100/100',
      isVerified: false,
    );

    return AppNotification(
      id: notification.id,
      user: user,
      type: _toNotificationType(notification.type),
      content: notification.content,
      timestamp: _formatTimestamp(notification.createdAt),
      isRead: notification.isRead,
      postSnippet: null,
      tweetId: notification.tweetId,
    );
  }

  NotificationType _toNotificationType(String raw) {
    switch (raw.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'repost':
        return NotificationType.repost;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'reply':
        return NotificationType.reply;
      default:
        return NotificationType.like;
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  /// Dispose resources
  void dispose() {
    _repository.disconnectSocket();
    _notificationsController.close();
    _unseenCountController.close();
  }
}
