import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String recipientName;
  final String? recipientAvatarUrl;
  // final String recipientId;
  final VoidCallback? onProfileTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onAudioCallTap;

  const MessageAppBar({
    super.key,
    required this.recipientName,
    // required this.recipientId,
    this.recipientAvatarUrl,
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
                backgroundImage: recipientAvatarUrl != null
                    ? NetworkImage(recipientAvatarUrl!)
                    : null,
                child: recipientAvatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              recipientName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
