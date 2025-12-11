import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mentions_model.dart';
import 'repositories/mentions_repository.dart';

final mentionsRepositoryProvider = Provider<MentionsRepository>((ref) {
  return MentionsRepository(ref);
});

class MentionsController extends AsyncNotifier<List<MentionItem>> {
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(mentionsRepositoryProvider);
      return await repo.fetchMentions();
    });
  }

  @override
  Future<List<MentionItem>> build() async {
    final repo = ref.read(mentionsRepositoryProvider);
    final items = await repo.fetchMentions();
    return items;
  }
}

final mentionsProvider =
    AsyncNotifierProvider<MentionsController, List<MentionItem>>(
  () => MentionsController(),
);
