import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? profileImage;
  final String subtitle;
  final VoidCallback? onProfileTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onAudioCallTap;

  const MessageAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.profileImage,
    this.onProfileTap,
    this.onVideoCallTap,
    this.onAudioCallTap,
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
      actions: [
        IconButton(
          icon: Icon(MdiIcons.videoPlusOutline, size: 28, color: Colors.white),
          onPressed: onVideoCallTap,
        ),
        IconButton(
          icon: Icon(MdiIcons.phoneOutline, size: 25, color: Colors.white),
          onPressed: onAudioCallTap,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
