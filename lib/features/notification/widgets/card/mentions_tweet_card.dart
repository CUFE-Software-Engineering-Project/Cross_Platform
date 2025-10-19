import 'package:flutter/material.dart';
import '../../models/notification.dart';
import 'interaction_bar.dart';
import 'package:lite_x/core/theme/palette.dart';

class MentionTweetCard extends StatelessWidget {
  final AppNotification notification;

  const MentionTweetCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(notification.user.avatarUrl),
            backgroundColor: Palette.cardBackground,
          ),
          const SizedBox(width: 12),
          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + Verified + Timestamp
                Row(
                  children: [
                    Text(
                      '@${notification.user.username}',
                      style: TextStyle(
                        color: Palette.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (notification.user.isVerified)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.verified,
                          color: Palette.verified,
                          size: 16,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      notification.timestamp,
                      style: TextStyle(
                        color: Palette.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Tweet content
                if (notification.postSnippet != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      notification.postSnippet!,
                      style: TextStyle(
                        color: Palette.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Interaction bar
                const InteractionBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
