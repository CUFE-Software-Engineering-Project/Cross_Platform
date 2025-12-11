import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';

import '../empty/all_empty.dart';
import '../card/all_tweet_card.dart';
import '../../../notification_view_model.dart';

class AllTab extends ConsumerStatefulWidget {
  const AllTab({super.key});

  @override
  ConsumerState<AllTab> createState() => _AllTabState();
}

class _AllTabState extends ConsumerState<AllTab>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark notifications as read when opening the tab
      ref.read(notificationViewModelProvider.notifier).markNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Watch the view model provider instead of stream provider
    final state = ref.watch(notificationViewModelProvider);

    return Container(
      color: Palette.background,
      child: state.when(
        data: (items) {
          return RefreshIndicator(
            onRefresh: () async {
              // Call the refresh method that makes API request
              await ref.read(notificationViewModelProvider.notifier).refresh();
            },
            child: items.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 50),
                      AllEmptyStateWidget(),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final notification = items[index];
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
            'Failed to load notifications',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
