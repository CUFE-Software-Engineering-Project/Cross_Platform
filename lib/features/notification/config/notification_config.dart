/// Configuration for the notification system
class NotificationConfig {
  /// Base URL for your API
  static const String baseUrl = 'http://localhost:3000';
  
  /// Socket.io server URL (usually same as baseUrl)
  static const String socketUrl = 'http://localhost:3000';
  
  /// API endpoints - matching your backend structure
  static const String notificationsEndpoint = '/api/notifications';
  static const String unseenCountEndpoint = '/api/notifications/unseen/count';
  static const String unseenNotificationsEndpoint = '/api/notifications/unseen';
  static const String markAsReadEndpoint = '/api/notifications';
  
  /// Socket events
  static const String joinUserRoomEvent = 'join_user_room';
  static const String notificationEventPrefix = 'notification:';
  
  /// Timeout settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 5);
  
  /// Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

/// Helper class for building API URLs
class NotificationApiUrls {
  static String getNotifications() => NotificationConfig.notificationsEndpoint;
  static String getUnseenCount() => NotificationConfig.unseenCountEndpoint;
  static String getUnseenNotifications() => NotificationConfig.unseenNotificationsEndpoint;
  static String markAsRead(String notificationId) => '${NotificationConfig.markAsReadEndpoint}/$notificationId/read';
}

/// Helper class for socket events
class NotificationSocketEvents {
  static String joinUserRoom(String userId) => '${NotificationConfig.joinUserRoomEvent}:$userId';
  static String notificationForUser(String userId) => '${NotificationConfig.notificationEventPrefix}$userId';
}
