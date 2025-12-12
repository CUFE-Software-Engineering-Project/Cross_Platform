import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/profile/models/shared.dart';

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
                child: ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: BuildSmallProfileImage(
                  mediaId: avatarUrl,
                  radius: 20,
                ),
              ),
            ),
              ),
              SizedBox(width: 12),
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