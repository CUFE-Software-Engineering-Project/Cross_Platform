import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/notification_view_model.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/status_bar.dart';
import 'package:lite_x/core/theme/palette.dart';

/// Clean notification screen following SOLID principles
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationViewModelFactory.create(),
      child: const _NotificationScreenContent(),
    );
  }
}

class _NotificationScreenContent extends StatefulWidget {
  const _NotificationScreenContent();

  @override
  State<_NotificationScreenContent> createState() => _NotificationScreenContentState();
}

class _NotificationScreenContentState extends State<_NotificationScreenContent> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // Get auth token and user ID from your auth system
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VybmFtZSI6ImpvaG5kb2UiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJpZCI6IjdjNDA5MGQxLTQ0NzgtNGE1Mi1hY2VhLTkyY2QyYjZkYmRlMiIsImV4cCI6MTc2MTY2OTE5NywiaWF0IjoxNzYxNjY4Mjk3LCJ2ZXJzaW9uIjowLCJqdGkiOiIwM2UzMDBmYi0zMTA1LTQ4OTQtYTIwYi00YjEyYjI2ZjFlMzEiLCJkZXZpZCI6IjJlYmQ0YjI2LTBhMTEtNDI5Zi1iNDYwLTM0NDM5MDQxYzcwZSJ9.do8LLX6iDxTr84BqxZlBP4hqEdIQgIalcdovRghd2hc";
    final userId = "7c4090d1-4478-4a52-acea-92cd2b6dbde2";
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().initialize(token, userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            const Expanded(
              child: NotificationTabs(),
            ),
          ],
        ),
      ),
    );
  }
}
