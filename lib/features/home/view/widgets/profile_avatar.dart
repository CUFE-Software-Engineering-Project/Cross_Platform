import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';
import 'package:lite_x/features/profile/models/shared.dart';

class ProfileAvatar extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProfileAvatar({super.key, required this.scaffoldKey});

  String? _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) return null;

    // If it's already a full URL, return it
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }

    // Otherwise, construct the full media URL
    return 'https://litex.siematworld.online/media/$photo';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(userProfileProvider);

    return GestureDetector(
      onTap: () => _openDrawer(),
      child: BuildSmallProfileImage(radius: 15, username: user?.username ?? ""),
    );
  }

  void _openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
}
