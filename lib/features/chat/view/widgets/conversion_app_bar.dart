import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:lite_x/features/chat/view/widgets/SearchField.dart';

class ConversationAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ConversationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentuser = ref.watch(currentUserProvider);

    return AppBar(
      backgroundColor: Palette.background,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {},
                child: Hero(
                  tag: "user_avatar",
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: currentuser?.photo != null
                        ? NetworkImage(currentuser!.photo!)
                        : null,
                    child: currentuser?.photo == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SearchField(
                hintText: 'Search Direct Messages',
                onTap: () {},
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color.fromARGB(174, 255, 255, 255),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
