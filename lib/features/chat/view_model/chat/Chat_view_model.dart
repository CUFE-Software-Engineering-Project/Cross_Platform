import 'package:lite_x/TestChatScreen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'Chat_view_model.g.dart';

@Riverpod(keepAlive: true)
class ChatViewModel extends _$ChatViewModel {
  @override
  AsyncValue<MessageModel>? build() {
    return null;
  }
}
