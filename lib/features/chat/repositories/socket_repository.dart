import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lite_x/core/providers/unseenChatsCountProvider.dart';
import 'package:lite_x/features/auth/repositories/auth_local_repository.dart';
import 'package:lite_x/features/chat/providers/tokenStream.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';
part 'socket_repository.g.dart';

@Riverpod(keepAlive: true)
SocketRepository socketRepository(Ref ref) {
  return SocketRepository(ref: ref);
}

class SocketRepository {
  final _newMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageAddedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _messagesReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _unseenChatsController =
      StreamController<Map<String, dynamic>>.broadcast();
  //-------------------------------------------------------------------------------//
  Stream<Map<String, dynamic>> get messagesReadStream =>
      _messagesReadController.stream;
  Stream<Map<String, dynamic>> get newMessageStream =>
      _newMessageController.stream;
  Stream<Map<String, dynamic>> get messageAddedStream =>
      _messageAddedController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get unseenChatsStream =>
      _unseenChatsController.stream;

  final Ref ref;
  io.Socket? _socket;
  final baseUrl = dotenv.env["API_URL"]!;
  SocketRepository({required this.ref, io.Socket? socket}) : _socket = socket {
    if (_socket != null) {
      _setupListeners();
      _listenTokenChanges();
      _listenToUnseenChats();
    } else {
      _initSocket();
      _listenTokenChanges();
      _listenToUnseenChats();
    }
  }
  void _listenTokenChanges() {
    ref.listen(tokenStreamProvider, (previous, next) {
      next.whenData((tokens) {
        if (tokens != null) {
          //   print("Socket Token Updated via Stream");
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

  void _listenToUnseenChats() {
    unseenChatsStream.listen((data) {
      int count = data['count'] ?? 0;
      ref.read(unseenChatsCountProvider.notifier).state = count;
    });
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
      // print("SOCKET CONNECTED: ${_socket?.id}\n");
    });

    _socket?.onConnectError((data) {
      // print("Socket connect error: $data\n");
    });

    _socket?.onDisconnect((_) {
      // print("Socket disconnected\n");
    });

    _socket?.on('authenticated', (data) {
      // print("Authenticated: $data\n");
    });

    _socket?.on('auth-error', (data) {
      // print(" Auth error: $data\n");
    });

    _socket?.on('new-message', (data) {
      if (data != null && !_newMessageController.isClosed) {
        _newMessageController.add(Map<String, dynamic>.from(data));
      }
    });
    _socket?.on("messages-read", (data) {
      if (data != null && !_messagesReadController.isClosed) {
        _messagesReadController.add(Map<String, dynamic>.from(data));
      }
    });
    _socket?.on('message-added', (data) {
      if (data != null && !_messageAddedController.isClosed) {
        _messageAddedController.add(Map<String, dynamic>.from(data));
      }
    });
    _socket?.on('user-typing', (data) {
      if (data != null && !_typingController.isClosed) {
        _typingController.add(Map<String, dynamic>.from(data));
      }
    });
    _socket?.on('unseen-chats-count', (data) {
      print("Unseen chats count: $data\n");
      if (data != null && !_unseenChatsController.isClosed) {
        _unseenChatsController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void sendOpenMessageTab() {
    print("sending open-message-tab");
    _socket?.emit('open-message-tab');
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
    });
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

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _newMessageController.close();
    _messageAddedController.close();
    _typingController.close();
    _messagesReadController.close();
    _unseenChatsController.close();
  }
}
