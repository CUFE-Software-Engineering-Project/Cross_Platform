import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';

import '../empty/all_empty.dart';
import '../card/all_tweet_card.dart';
import '../../../notification_model.dart';
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
      ref.read(notificationViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = ref.watch(notificationViewModelProvider);

    return Container(
      color: Palette.background,
      child: state.when(
        data: (items) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(notificationViewModelProvider.notifier)
                  .refresh();
            },
            child: items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: const [AllEmptyStateWidget()],
                  )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildItem(items[index]);
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
                  'Error loading notifications',
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "Try again later.Or Retry",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(notificationViewModelProvider.notifier).refresh();
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

  Widget _buildItem(NotificationItem notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AllTweetCardWidget(notification: notification),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
