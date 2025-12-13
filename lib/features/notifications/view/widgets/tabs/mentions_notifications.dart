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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load mentions',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(mentionsViewModelProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
