import 'dart:async';
import 'package:flutter/material.dart';
import '../core/interfaces/notification_service_interface.dart';
import '../core/di/notification_di_container.dart';
import '../models/notification_model.dart';

/// Clean ViewModel following SOLID principles
/// Follows Single Responsibility Principle (SRP)
class NotificationViewModel extends ChangeNotifier {
  final INotificationService _service;
  final List<StreamSubscription> _subscriptions = [];

  NotificationViewModel({required INotificationService service}) : _service = service;

  // State
  List<AppNotification> _notifications = [];
  int _unseenCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AppNotification> get notifications => _notifications;
  int get unseenCount => _unseenCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize the notification system
  Future<void> initialize(String token, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.initialize(token, userId);
      _setupStreams();
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Setup reactive streams
  void _setupStreams() {
    _subscriptions.add(
      _service.notificationsStream.listen((notifications) {
        _notifications = notifications;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _service.unseenCountStream.listen((count) {
        _unseenCount = count;
        notifyListeners();
      }),
    );
  }

  /// Refresh notifications
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();

    try {
      await _service.refreshNotifications();
    } catch (e) {
      _setError('Failed to refresh notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
    }
  }

  /// Get notifications for specific tab
  List<AppNotification> getNotificationsForTab(String tabType) {
    switch (tabType.toLowerCase()) {
      case 'verified':
        return _notifications.where((n) => n.user.isVerified).toList();
      case 'mentions':
        return _notifications.where((n) => 
          n.type == NotificationType.mention || n.type == NotificationType.reply).toList();
      case 'all':
      default:
        return _notifications;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}

/// Factory for creating NotificationViewModel
class NotificationViewModelFactory {
  static NotificationViewModel create() {
    final container = NotificationDIContainer();
    return NotificationViewModel(service: container.service);
  }
}
