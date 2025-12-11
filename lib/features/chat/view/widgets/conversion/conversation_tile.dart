import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/screens/profile_screen.dart';

class ConversationTile extends StatelessWidget {
  final String recipientId;
  final String chatId;
  final String name;
  final String username;
  final String message;
  final String time;
  final String? avatarUrl;
  final bool isUnread;
  final int unseenCount;
  final bool isDMChat;
  final int recipientFollowersCount;
  final VoidCallback? onLongPress;
  const ConversationTile({
    super.key,
    required this.name,
    required this.recipientId,
    required this.chatId,
    required this.username,
    required this.message,
    required this.time,
    this.avatarUrl,
    this.isUnread = false,
    this.unseenCount = 0,
    this.isDMChat = true,
    this.recipientFollowersCount = 0,
    this.onLongPress,
  });
  void _openProfile(BuildContext context, String username) {
    final normalized = username.startsWith('@')
        ? username.substring(1)
        : username;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePage(username: normalized)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteConstants.ChatScreen,
          pathParameters: {'chatId': chatId},
          extra: {
            'title': name,
            'avatarUrl': avatarUrl,
            'subtitle': username,
            'isGroup': isDMChat,
            'recipientFollowersCount': recipientFollowersCount,
          },
        );
      },
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Palette.border, width: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (username.isNotEmpty) {
                  _openProfile(context, username);
                }
              },
              child: BuildSmallProfileImage(radius: 24, username: username),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Palette.textWhite,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (isDMChat && username.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '@$username',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Palette.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      Text(
                        ' · $time',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: 15,
                            color: isUnread
                                ? Palette.textWhite
                                : Palette.textSecondary,
                            fontWeight: isUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unseenCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          // child: Text(
                          //   unseenCount > 99 ? '99+' : unseenCount.toString(),
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.white,
                          //   ),
                          // ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
