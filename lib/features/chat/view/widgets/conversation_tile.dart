import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

class ConversationTile extends StatelessWidget {
  final String name;
  final String username;
  final String message;
  final String time;
  final String? avatarUrl;
  final bool isUnread;

  const ConversationTile({
    super.key,
    required this.name,
    required this.username,
    required this.message,
    required this.time,
    this.avatarUrl,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Palette.border, width: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$name',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Palette.textWhite,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ' @$username',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Palette.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ' · $time',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUnread
                          ? Palette.textWhite
                          : Palette.textSecondary,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
