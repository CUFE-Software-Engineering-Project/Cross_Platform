import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/models/usermodel.dart';

class Statusbar extends ConsumerWidget {
  const Statusbar({super.key});

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
              Container(
                width: 56,
                height: 53,
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(Icons.person, color: Colors.grey[400], size: 18)
                      : null,
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
          Icon(
            Icons.settings_outlined,
            size: 20,
            color: Palette.icons,
          ),
        ],
      ),
    );
  }
}