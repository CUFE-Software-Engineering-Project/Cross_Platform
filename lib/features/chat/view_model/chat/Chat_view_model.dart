// ignore_for_file: unused_field

import 'package:lite_x/features/chat/view/TestChatScreen.dart';
import 'package:lite_x/features/chat/repositories/chat_local_repository.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:lite_x/features/chat/repositories/socket_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'Chat_view_model.g.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isRecipientTyping;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isRecipientTyping = false,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isRecipientTyping,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isRecipientTyping: isRecipientTyping ?? this.isRecipientTyping,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatViewModel extends _$ChatViewModel {
  late ChatRemoteRepository _chatRemoteRepository;
  late ChatLocalRepository _chatLocalRepository;
  late SocketRepository _socketRepository;

  @override
  ChatState build() {
    _chatRemoteRepository = ref.watch(chatRemoteRepositoryProvider);
    _chatLocalRepository = ref.watch(chatLocalRepositoryProvider);
    _socketRepository = ref.watch(socketRepositoryProvider);
    return ChatState(isLoading: true);
  }
}
