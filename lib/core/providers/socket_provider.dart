import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final authLocalRepository = ref.watch(authLocalRepositoryProvider);
  return SocketService(authLocalRepository);
});

class SocketService {
  final AuthLocalRepository _authLocalRepository;
  late IO.Socket _socket;
  bool _isConnected = false;

  SocketService(this._authLocalRepository) {
    _initializeSocket();
  }

  void _initializeSocket() {
    final tokens = _authLocalRepository.getTokens();
    final token = tokens?.accessToken ?? '';


    print('NOTI:Initializing socket connection to: $API_URL');

    _socket = IO.io(
  API_URL,
  IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableReconnection()
      .setReconnectionDelay(1000)
      .setReconnectionDelayMax(5000)
      .setReconnectionAttempts(10)
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .build(),
);


    _setupListeners();
  }

  void _setupListeners() {
    _socket.on('connect', (_) {
      _isConnected = true;
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
    });

    _socket.on('error', (error) {
    });

    _socket.on('connect_error', (error) {
    });
  }

  IO.Socket get socket => _socket;

  bool get isConnected => _isConnected;

  void connect() {
    if (!_isConnected) {
      _socket.connect();
    }
  }

  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
    }
  }

  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
    } else {
    }
  }

  /// Emit an event with automatic retry if socket is not yet connected
  /// Waits up to 5 seconds for socket to connect before giving up
  Future<void> emitWhenConnected(String event, dynamic data) async {
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds (50 * 100ms)
    const delayMs = 100;

    while (!_isConnected && attempts < maxAttempts) {
      attempts++;
      await Future.delayed(const Duration(milliseconds: delayMs));
    }

    if (_isConnected) {
      _socket.emit(event, data);
    } else {
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void off(String event) {
    _socket.off(event);
  }
}
