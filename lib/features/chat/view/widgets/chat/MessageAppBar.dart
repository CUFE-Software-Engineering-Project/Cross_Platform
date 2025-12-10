import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? profileImage;
  final String subtitle;
  final VoidCallback? onProfileTap;

  const MessageAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.profileImage,
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
              child: CircleAvatar(
                radius: 18,
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
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
