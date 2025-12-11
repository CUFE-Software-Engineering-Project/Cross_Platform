import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

import 'notification_timestamp.dart';

import '../../../notification_model.dart';

class LoginNotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const LoginNotificationCard({
    super.key,
    required this.notification,
  });

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'SF Pro Text',
        color: Palette.textPrimary,
        fontSize: 14,
        height: 1.4,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrandBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.body,
                        style: _bodyStyle,
                      ),
                    ),
                    const SizedBox(width: 12),
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

  Widget _buildBrandBadge() {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: const Text(
        'X',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w700,
          color: Palette.textPrimary,
          fontSize: 24,
        ),
      ),
    );
  }

}
