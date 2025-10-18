import 'package:lite_x/core/constants/server_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

@Riverpod(keepAlive: true)
SocketRepository socketRepository(Ref ref) {
  return SocketRepository(API_URL);
}

class SocketRepository {
  final String baseUrl;
  io.Socket? _socket;
  SocketRepository(this.baseUrl);

  Future<void> connect(String token) async {
    disconnect();
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'Bearer': token})
          .build(),
    );
    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void reconnect() {
    _socket?.connect();
  }

  void sendMessage(String chatId, String message) {
    _socket?.emit('send-message', {'chatId': chatId, 'message': message});
  }

  void sendTyping(String chatId, bool isTyping) {
    // final String userId = ref.read(currentUserProvider).id;

    _socket?.emit('typing', {
      // 'userId': userId,
      'chatId': chatId,
      'isTyping': isTyping,
    });
  }

  void joinChat(String chatId) {}
  void leaveChat(String chatId) {}

  void onNewMessage(Function(dynamic data) callback) {
    _socket?.on('new-message', (data) => callback(data));
  }

  void onTyping(Function(dynamic data) callback) {
    _socket?.on('user-typing', (data) => callback(data));
  }

  void onAuthenticated(Function(dynamic data) callback) {
    _socket?.on('authenticated', (data) => callback(data));
  }

  void onAuthError(Function(dynamic data) callback) {
    _socket?.on('auth-error', (data) => callback(data));
  }
}
