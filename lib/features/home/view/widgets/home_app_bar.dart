// lib/features/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lite_x/features/home/view/widgets/home_tab_bar.dart';
import 'package:lite_x/features/home/view/widgets/profile_avatar.dart';

// Provider for app bar settings (future backend integration)
final appBarSettingsProvider = StateProvider<AppBarSettings>((ref) {
  return AppBarSettings(showNotificationDot: false, unreadCount: 0);
});

class AppBarSettings {
  final bool showNotificationDot;
  final int unreadCount;

  AppBarSettings({
    required this.showNotificationDot,
    required this.unreadCount,
  });
}

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appBarSettingsProvider);

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Top app bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Profile Avatar (Left)
                  const ProfileAvatar(),

                  // X Logo (Center)
                  Expanded(child: Center(child: _buildXLogo())),

                  // Settings Icon (Right)
                  _buildSettingsButton(context, settings),
                ],
              ),
            ),

            // Tab Bar
            const HomeTabBar(),

            // Bottom border
            Container(height: 0.5, color: Colors.grey[800]),
          ],
        ),
      ),
    );
  }

  Widget _buildXLogo() {
    return Container(
      width: 30,
      height: 30,
      child: SvgPicture.asset(
        'assets/svg/xlogo.svg',
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, AppBarSettings settings) {
    return Stack(
      children: [
        IconButton(
          onPressed: () => _openSettings(context),
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),

        // Notification dot (for future features)
        if (settings.showNotificationDot)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF1DA1F2),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  void _openSettings(BuildContext context) {
    // TODO: Navigate to settings or show bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSettingsBottomSheet(context),
    );
  }

  Widget _buildSettingsBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.timeline, color: Colors.white),
            title: const Text(
              'Timeline settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Open timeline settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.white),
            title: const Text(
              'See fewer tweets like this',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Handle preference
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(104.5); // 56 + 48 + 0.5
}
