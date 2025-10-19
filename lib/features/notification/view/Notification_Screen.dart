import 'package:flutter/material.dart';
import '../widgets/status_bar.dart';
import '../widgets/notification_tabs.dart';
import 'package:lite_x/core/theme/palette.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            // Your custom status bar at the top.
            const Statusbar(),
            // Your custom tab handler, expanded to fill remaining space.
            const Expanded(
              child: NotificationTabs(),
            ),
          ],
        ),
      ),
    );
  }
}