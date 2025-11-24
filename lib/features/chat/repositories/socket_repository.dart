// ignore_for_file: unused_import, unused_field

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/models/TokensModel.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/chat/providers/tokenStream.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
part 'socket_repository.g.dart';

@Riverpod(keepAlive: true)
SocketRepository socketRepository(Ref ref) {
  return SocketRepository(ref: ref);
}

class SocketRepository {
  final Ref ref;
  io.Socket? _socket;
  final baseUrl = dotenv.env["API_URL"]!;
  SocketRepository({required this.ref}) {
    _initSocket();
    _listenTokenChanges();
  }
  void _listenTokenChanges() {
    ref.listen(tokenStreamProvider, (previous, next) {
      next.whenData((tokens) {
        if (tokens != null) {
          print("Socket Token Updated via Stream");
          _updateSocketToken(tokens.accessToken);
        }
      });
    });
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

  void _updateSocketToken(String newToken) {
    if (_socket == null) return;
    _socket?.io.options?['extraHeaders'] = {
      'Authorization': 'Bearer $newToken',
    };

    _socket?.disconnect();
    _socket?.connect();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      print("SOCKET CONNECTED: ${_socket?.id}");
    });

    _socket?.onConnectError((data) {
      print("Socket connect error: $data");
    });

    _socket?.onDisconnect((_) {
      print("Socket disconnected");
    });

    _socket?.on('authenticated', (data) {
      print("Authenticated: $data");
    });

    _socket?.on('auth-error', (data) {
      print(" Auth error: $data");
    });

    _socket?.on('new-message', (data) {
      print(" New message: $data");
    });
    _socket?.on("messages-read", (data) {
      print("Messages read event: $data");
    });
    _socket?.on("message-added", (data) {
      print("Message added event: $data");
    });
  }

  void sendTyping(String chatId, bool isTyping) {
    _socket?.emit('typing', {'chatId': chatId, 'isTyping': isTyping});
  }

  void onTyping(Function(dynamic data) callback) {
    _socket?.on('user-typing', (data) => callback(data));
  }

  // Send a real-time message
  void sendMessage(Map<String, dynamic> message) {
    _socket?.emit("add-message", {"message": message});
  } // sender

  // Listen to new real-time message
  void onNewMessage(Function(dynamic data) callback) {
    _socket?.on("new-message", (data) {
      callback(data);
    }); // receiver
  }

  // Mark chat opened (make all messages READ)
  void openChat(String chatId) {
    _socket?.emit("open-chat", {"chatId": chatId});
  }

  // the messages are read
  void onMessagesRead(Function(dynamic data) callback) {
    _socket?.on("messages-read", (data) => callback(data));
  }

  void onMessageAdded(Function(dynamic data) callback) {
    _socket?.on("message-added", (data) => callback(data));
  } //for sender

  void disposeListeners() {
    _socket?.off('new-message');
    _socket?.off('user-typing');
    _socket?.off('messages-read');
    _socket?.off('message-added');
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
  }
}
