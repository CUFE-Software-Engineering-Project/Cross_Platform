import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/palette.dart';

class Statusbar extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Statusbar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? currentUser = ref.watch(currentUserProvider);
    final avatarUrl = currentUser?.photo;

    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Palette.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 56,
                  height: 53,
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    radius: 16,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Icon(Icons.person, color: Colors.grey[400], size: 18)
                        : null,
                  ),
                ),
              ),
              Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Palette.textWhite,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              context.push("/settingandprivacyscreen");
            },
            child: Icon(
              Icons.settings_outlined,
              size: 20,
              color: Palette.icons,
            ),
          ),
        ],
      ),
    );
  }
}