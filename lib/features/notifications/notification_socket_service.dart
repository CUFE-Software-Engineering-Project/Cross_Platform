import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

final notificationSocketServiceProvider =
    Provider<NotificationSocketService>((ref) {
  return NotificationSocketService(ref: ref);
});

class NotificationSocketService {
  final _newNotificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _unseenCountController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get newNotificationStream =>
      _newNotificationController.stream;
  Stream<Map<String, dynamic>> get unseenCountStream =>
      _unseenCountController.stream;

  final Ref ref;
  io.Socket? _socket;
  final baseUrl = dotenv.env["Socket_Url"]!;

  NotificationSocketService({required this.ref}) {
    _initSocket();
  }

  void _initSocket() async {
    final authLocalRepository = ref.read(authLocalRepositoryProvider);
    final token = authLocalRepository.getTokens()?.accessToken;

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setTimeout(5000)
          .enableReconnection()
          .setReconnectionAttempts(50)
          .setExtraHeaders(
            token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .build(),
    );

    _setupListeners();
    _socket?.connect();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      print("NOTIFICATION SOCKET CONNECTED: ${_socket?.id}");
    });

    _socket?.onConnectError((data) {
      print("Notification socket connect error: $data");
    });

    _socket?.onDisconnect((_) {
      print("Notification socket disconnected");
    });

    // Listen for new notifications
    _socket?.on('notification', (data) {
      print("New notification event: $data");
      if (data != null && !_newNotificationController.isClosed) {
        _newNotificationController.add(Map<String, dynamic>.from(data));
      }
    });

    // Listen for unseen count updates
    _socket?.on('unseen-notifications-count', (data) {
      print("Unseen notifications count: $data");
      if (data != null && !_unseenCountController.isClosed) {
        _unseenCountController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  // Emit open-notification event to mark as seen
  void openNotification(String notificationId) {
    print("Opening notification: $notificationId");
    _socket?.emit('open-notification', {'notificationId': notificationId});
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _newNotificationController.close();
    _unseenCountController.close();
  }
}
