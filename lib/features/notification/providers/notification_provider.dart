import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../view_models/notification_view_model.dart';

/// Helper to wrap a subtree with the Notification provider
Widget buildNotificationProvider({required Widget child}) {
  return ChangeNotifierProvider<NotificationViewModel>(
    create: (_) => NotificationViewModelFactory.create(),
    child: child,
  );
}


