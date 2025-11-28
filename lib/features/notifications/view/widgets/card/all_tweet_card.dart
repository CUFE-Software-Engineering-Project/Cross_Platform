import 'package:flutter/material.dart';
import '../../../notification_model.dart';
import 'package:lite_x/core/theme/palette.dart';

class AllTweetCardWidget extends StatelessWidget {
  final NotificationItem notification;

  const AllTweetCardWidget({super.key, required this.notification});

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color bgColor;

    switch (notification.title) {
      case "LIKE":
        iconData = Icons.favorite;
        bgColor = Palette.like;
        break;
      case "REPOST":
        iconData = Icons.repeat;
        bgColor = Palette.retweet;
        break;
      case "FOLLOW":
        iconData = Icons.person_add;
        bgColor = Palette.primary;
        break;
      case "MENTION":
        iconData = Icons.alternate_email;
        bgColor = Palette.info;
        break;
      case "REPLY":
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildNotificationIcon(),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18.5,
                  backgroundImage: (notification.mediaUrl.isNotEmpty)
                      ? NetworkImage(notification.mediaUrl)
                      : null,
                  backgroundColor: Palette.cardBackground,
                  child: (notification.mediaUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          color: Palette.textPrimary,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  notification.body,
                  style: const TextStyle(
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
        ],
      ),
    );
  }
}
