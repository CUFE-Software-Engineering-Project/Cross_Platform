import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'tabs/all_notifications.dart';
import 'tabs/verified_notifications.dart';
import 'tabs/mentions_notifications.dart';
import '../../notification_view_model.dart';
import '../../mentions_view_model.dart';

class NotificationTabs extends ConsumerStatefulWidget {
  const NotificationTabs({super.key});

  @override
  ConsumerState<NotificationTabs> createState() => _NotificationTabsState();
}

class _NotificationTabsState extends ConsumerState<NotificationTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;
  final tabs = ['All', 'Verified', 'Mentions'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (selectedIndex != _tabController.index) {
        setState(() {
          selectedIndex = _tabController.index;
        });
        // Trigger refresh for the newly selected tab
        switch (_tabController.index) {
          case 0:
            ref.read(notificationViewModelProvider.notifier).refresh();
            break;
          case 1:
            // Verified tab currently static; no provider to refresh
            break;
          case 2:
            ref.read(mentionsViewModelProvider.notifier).refresh();
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Palette.background,
            border: Border(
              bottom: BorderSide(
                color: Palette.border,
                width: 1,
              ),
            ),
          ),
          height: 53,
          child: Row(
            children: List.generate(
              tabs.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    _tabController.animateTo(index);
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: 53,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: selectedIndex == index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 15,
                              color: selectedIndex == index
                                  ? Palette.textPrimary
                                  : Palette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (selectedIndex == index)
                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Palette.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(1),
                              topRight: Radius.circular(1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AllTab(key: PageStorageKey('allTab')),
              VerifiedTab(key: PageStorageKey('verifiedTab')),
              MentionsTab(key: PageStorageKey('mentionsTab')),
            ],
          ),
        ),
      ],
    );
  }
}