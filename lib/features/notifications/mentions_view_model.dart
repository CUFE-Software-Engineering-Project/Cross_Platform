import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'mentions_model.dart';
import './mentions_provider.dart';

part 'mentions_view_model.g.dart';

@riverpod
class MentionsViewModel extends _$MentionsViewModel {
  @override
  Future<List<MentionItem>> build() async {
    return _fetchMentions();
  }

  Future<List<MentionItem>> _fetchMentions() async {
    final repo = ref.read(mentionsRepositoryProvider);
    return repo.fetchMentions();
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      return _fetchMentions();
    });
    
    if (ref.mounted) {
      state = result;
    }
  }
}

