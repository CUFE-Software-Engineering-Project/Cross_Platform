import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';

import 'notification_timestamp.dart';

import '../../../notification_model.dart';

class FollowNotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const FollowNotificationCard({
    super.key,
    required this.notification,
  });

  TextStyle get _nameStyle => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w600,
        color: Palette.textPrimary,
      );

  TextStyle get _secondaryStyle => const TextStyle(
        fontFamily: 'SF Pro Text',
        color: Palette.textSecondary,
        fontSize: 14,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuildSmallProfileImage(
            mediaId: notification.mediaUrl.isNotEmpty ? notification.mediaUrl : null,
            userId: notification.actor.username,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${notification.actor.name} ',
                          style: _nameStyle,
                          children: [
                            TextSpan(
                              text: _getActionText(),
                              style: _secondaryStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatNotificationTimestamp(notification.createdAt),
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        color: Palette.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActionText() {
    return 'followed you';
  }
}
