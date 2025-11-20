import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteConstants.ChatScreen,
          pathParameters: {'recipientId': recipientId},
          extra: {
            'name': name,
            'avatarUrl': avatarUrl,
            'username': username,
            'chatId': chatId,
            'isDMChat': isDMChat,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Palette.border, width: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              backgroundColor: Palette.cardBackground,
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person_3_rounded,
                      color: Palette.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Name
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

                      // Username (for DM chats)
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

                      // Time
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
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unseenCount > 99 ? '99+' : unseenCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
