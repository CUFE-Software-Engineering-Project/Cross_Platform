import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/home/view/widgets/profile_side_drawer.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/status_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Palette.background,
      drawer: const ProfileSideDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Statusbar(scaffoldKey: _scaffoldKey),
            const Expanded(child: NotificationTabs()),
          ],
        ),
      ),
    );
  }
}
