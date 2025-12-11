import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onProfileTap;

  const MessageAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Palette.background,
      elevation: 0,
      titleSpacing: 0,
      title: GestureDetector(
        onTap: onProfileTap,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Hero(
              tag: "message_app_bar",
              child: BuildSmallProfileImage(radius: 18, username: subtitle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
