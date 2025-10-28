import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../../../view_models/notification_view_model.dart';
import '../cards/notification_card.dart';
import '../empty_states/all_empty_state.dart';

/// Clean all notifications tab
class AllNotificationsTab extends StatefulWidget {
  const AllNotificationsTab({super.key});

  @override
  State<AllNotificationsTab> createState() => _AllNotificationsTabState();
}

class _AllNotificationsTabState extends State<AllNotificationsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorState(viewModel);
        }

        final notifications = viewModel.getNotificationsForTab('all');

        return Container(
          color: Palette.background,
          child: notifications.isEmpty
              ? const AllEmptyState()
              : RefreshIndicator(
                  onRefresh: () => viewModel.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: NotificationCard(
                          notification: notifications[index],
                          onTap: () => _handleNotificationTap(
                            context,
                            viewModel,
                            notifications[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildErrorState(NotificationViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Palette.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Issue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Palette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationViewModel viewModel,
    notification,
  ) {
    // Handle notification tap
    // You can navigate to the relevant content or mark as read
    viewModel.markAsRead(notification.id);
  }

  @override
  bool get wantKeepAlive => true;
}
