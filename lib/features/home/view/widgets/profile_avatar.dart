import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProfileAvatar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () => _openDrawer(),
      child: Container(
        width: 32,
        height: 32,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[800],
          backgroundImage: user?.localProfilePhotoPath != null
              ? FileImage(File(user!.localProfilePhotoPath!))
              : null,

          child: user?.photo == null || user?.photo?.isEmpty == true
              ? Icon(Icons.person, color: Colors.grey[400], size: 18)
              : null,
        ),
      ),
    );
  }

  void _openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
}
