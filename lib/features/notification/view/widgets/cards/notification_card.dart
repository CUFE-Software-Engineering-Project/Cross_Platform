import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import '../../../models/notification_model.dart';

/// Clean notification card widget
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.5,
                        backgroundImage: NetworkImage(
                          notification.user.avatarUrl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                if (notification.user.isVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified,
                                    color: Palette.verified,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              notification.content,
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Palette.textWhite,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        notification.timestamp,
                        style: TextStyle(
                          color: Palette.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (notification.postSnippet != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Palette.cardBackground,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        notification.postSnippet!,
                        style: TextStyle(
                          color: Palette.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.like:
        iconData = Icons.favorite;
        bgColor = Palette.like;
        break;
      case NotificationType.repost:
        iconData = Icons.repeat;
        bgColor = Palette.retweet;
        break;
      case NotificationType.follow:
        iconData = Icons.person_add;
        bgColor = Palette.primary;
        break;
      case NotificationType.mention:
        iconData = Icons.alternate_email;
        bgColor = Palette.info;
        break;
      case NotificationType.reply:
        iconData = Icons.reply;
        bgColor = Palette.reply;
        break;
      default:
        iconData = Icons.notifications;
        bgColor = Palette.icons;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(iconData, color: Palette.textWhite, size: 16),
    );
  }
}
