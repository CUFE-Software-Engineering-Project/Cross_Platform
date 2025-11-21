import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';

class ProfileSideDrawer extends ConsumerWidget {
  const ProfileSideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Header with user info
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: user?.localProfilePhotoPath != null
                        ? FileImage(File(user!.localProfilePhotoPath!))
                        : null,
                    child: user?.photo == null || user?.photo?.isEmpty == true
                        ? Icon(Icons.person, color: Colors.grey[400], size: 32)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Username
                  Text(
                    '@${user?.username ?? 'username'}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, thickness: 0.5),
            // Profile button
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                if (user != null) {
                  context.push("/profilescreen/${user.username}");
                }
              },
            ),
            // Settings button
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                context.push("/settingandprivacyscreen");
              },
            ),
          ],
        ),
      ),
    );
  }
}
