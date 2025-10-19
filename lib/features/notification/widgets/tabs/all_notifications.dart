import 'package:flutter/material.dart';
import '../../models/notification.dart';
import 'mock_data.dart';
import 'package:lite_x/core/theme/palette.dart';

import '../empty/all_empty.dart';
import '../card/all_tweet_card.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key});

  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> with AutomaticKeepAliveClientMixin {
  final List<AppNotification> _notifications = allNotifications; // Use mock data
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    // Optionally, load items with animation
    //_loadItems();
  }

  void _loadItems() {
    var future = Future(() {});
    for (int i = 0; i < allNotifications.length; i++) {
      future = future.then((_) {
        return Future.delayed(const Duration(milliseconds: 100), () {
          _listKey.currentState?.insertItem(i);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Palette.background,
      child: _notifications.isEmpty
          ? const AllEmptyStateWidget()
          : AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              initialItemCount: _notifications.length,
              itemBuilder: (context, index, animation) {
                return _buildItem(_notifications[index], animation);
              },
            ),
    );
  }

  Widget _buildItem(AppNotification notification, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
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
