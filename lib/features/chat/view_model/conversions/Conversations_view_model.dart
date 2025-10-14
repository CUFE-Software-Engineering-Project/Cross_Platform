import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'Conversations_view_model.g.dart';

@Riverpod(keepAlive: true)
class ConversationsViewModel extends _$ConversationsViewModel {
  @override
  AsyncValue<ConversationModel>? build() {
    return null;
  }
}
