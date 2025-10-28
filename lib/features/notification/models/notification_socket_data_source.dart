import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/notification_config.dart';
import '../core/interfaces/notification_socket_interface.dart';
import 'notification_model.dart';

/// Socket.io data source for real-time notifications
class NotificationSocketDataSource implements INotificationSocket {
  io.Socket? _socket;
  final StreamController<NotificationModel> _controller =
      StreamController<NotificationModel>.broadcast();

  @override
  void connect(String token, String userId, Function(NotificationModel) onNotification) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      NotificationConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setTimeout(NotificationConfig.socketTimeout.inMilliseconds)
          .setQuery({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit(NotificationSocketEvents.joinUserRoom(userId));
    });

    final event = NotificationSocketEvents.notificationForUser(userId);
    _socket!.on(event, (data) {
      try {
        if (data is Map) {
          final model = NotificationModel.fromJson((data as Map).cast<String, dynamic>());
          _controller.add(model);
          onNotification(model);
        }
      } catch (_) {}
    });

    _socket!.onError((_) {});
    _socket!.onDisconnect((_) {});
  }

  @override
  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  @override
  bool get isConnected => _socket?.connected == true;

  @override
  Stream<NotificationModel> get notificationStream => _controller.stream;
}


