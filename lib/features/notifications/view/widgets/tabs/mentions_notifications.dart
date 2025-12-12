import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../empty/mention_empty.dart';
import '../card/mentions_tweet_card.dart';
import '../../../mentions_view_model.dart';

class MentionsTab extends ConsumerStatefulWidget {
  const MentionsTab({super.key});

  @override
  ConsumerState<MentionsTab> createState() => _MentionsTabState();
}

class _MentionsTabState extends ConsumerState<MentionsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mentionsViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(mentionsViewModelProvider);

    return Container(
      color: Palette.background,
      child: state.when(
        data: (items) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(mentionsViewModelProvider.notifier).refresh();
            },
            child: items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: const [MentionsEmptyStateWidget()],
                  )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return MentionTweetCard(mention: items[index]);
                  },
                ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading mentions',
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "Try again later.Or Retry\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(mentionsViewModelProvider.notifier).refresh();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DA1F2),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
