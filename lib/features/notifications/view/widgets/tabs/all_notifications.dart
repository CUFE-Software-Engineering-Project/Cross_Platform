import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/Palette.dart';

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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
              await ref.read(notificationViewModelProvider.notifier).refresh();
            },
            child: items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: const [AllEmptyStateWidget()],
                  )
                : AnimatedList(
                    key: _listKey,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    initialItemCount: items.length,
                    itemBuilder: (context, index, animation) {
                      return _buildItem(items[index], animation);
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
                'Failed to load notifications',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(notificationViewModelProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    NotificationItem notification,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AllTweetCardWidget(notification: notification),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
