import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';

class ConversationAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ConversationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentuser = ref.watch(currentUserProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Palette.background,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Hero(
                    tag: "chat_user_avatar",
                    child: BuildSmallProfileImage(
                      radius: 20,
                      username: currentuser?.username,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
