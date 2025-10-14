import 'package:dio/dio.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@Riverpod(keepAlive: true)
SocketRepository socketRepository(Ref ref) {
  return SocketRepository(Dio(BASE_OPTIONS), API_URL);
}

class SocketRepository {
  final Dio dio;
  final String baseUrl;

  SocketRepository(this.dio, this.baseUrl);
  Future<void> connect(String token) async {}
  void disconnect() {}
  void reconnect() {}

  void joinChat(String chatId) {}
  void leaveChat(String chatId) {}

  void sendMessage(String chatId, String message) {}
  void sendTyping(String chatId, bool isTyping) {}

  void onNewMessage(Function callback) {}
  void onTyping(Function callback) {}
  void onAuthenticated(Function callback) {}
  void onAuthError(Function callback) {}
}
