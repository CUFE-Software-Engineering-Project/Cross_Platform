import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
import 'package:lite_x/features/chat/repositories/chat_remote_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'Conversations_view_model.g.dart';

@Riverpod(keepAlive: true)
class ConversationsViewModel extends _$ConversationsViewModel {
  late final ChatRemoteRepository _chatRemoteRepository;

  @override
  AsyncValue<List<ConversationModel>> build() {
    _chatRemoteRepository = ref.watch(chatRemoteRepositoryProvider);
    return const AsyncValue.data([]);
  }

  Future<List<UserSearchModel>> searchUsers(String query) async {
    final result = await _chatRemoteRepository.searchUsers(query);

    return result.fold((failure) {
      print("Search Error: ${failure.message}");
      return [];
    }, (users) => users);
  }
}
  // Future<void> loadConversations() async {
  //   state = const AsyncValue.loading();

  //   final result = await _chatRemoteRepository.getConversations();

  //   state = result.fold(
  //     (failure) => AsyncValue.error(failure.message, StackTrace.current),
  //     (conversations) => AsyncValue.data(conversations),
  //   );
  // }