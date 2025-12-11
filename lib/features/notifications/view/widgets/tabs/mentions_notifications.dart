import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../empty/mention_empty.dart';
import '../card/all_tweet_card.dart';
import '../../../notification_view_model.dart';

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
    // The provider will auto-load when first watched
    // No need to manually invalidate
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Use the mentions view model which loads from dedicated mentions API
    final state = ref.watch(mentionsViewModelProvider);

    return Container(
      color: Palette.background,
      child: state.when(
        data: (mentions) {
          return RefreshIndicator(
            onRefresh: () async {
              // Use the dedicated refresh method that loads from mentions API
              await ref.read(mentionsViewModelProvider.notifier).refresh();
            },
            child: mentions.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 50),
                      MentionsEmptyStateWidget(),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: mentions.length,
                    itemBuilder: (context, index) {
                      final notification = mentions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AllTweetCardWidget(notification: notification),
                      );
                    },
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(
          child: Text(
            'Failed to load mentions',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
