import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/theme/palette.dart';

class ExploreNavBar extends StatelessWidget {
  final String? userAvatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSettingsTap;
  final Function(String)? onSearchChanged;

  const ExploreNavBar({
    super.key,
    this.userAvatarUrl,
    this.onAvatarTap,
    this.onSettingsTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.background,
        border: Border(
          bottom: BorderSide(
            color: Palette.divider,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // User Avatar
          GestureDetector(
            onTap: onAvatarTap ?? () {
              // Open profile drawer or navigate to profile
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Palette.primary,
              backgroundImage: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                  ? NetworkImage(userAvatarUrl!)
                  : null,
              child: userAvatarUrl == null || userAvatarUrl!.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 20,
                      color: Palette.textPrimary,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Search Bar
          Expanded(
            child: InkWell(
              onTap: () {
                // Navigate to search screen or focus search
                context.push('/search');
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Palette.inputBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: Palette.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search X',
                      style: TextStyle(
                        color: Palette.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Settings Icon
          IconButton(
            icon: const Icon(
              Icons.tune,
              size: 24,
              color: Palette.icons,
            ),
            onPressed: onSettingsTap ?? () {
              // Open content preferences
              _showContentPreferences(context);
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _showContentPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Palette.modalBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content preferences',
              style: TextStyle(
                color: Palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on, color: Palette.icons),
              title: const Text(
                'Location',
                style: TextStyle(color: Palette.textPrimary),
              ),
              subtitle: const Text(
                'Change trend location',
                style: TextStyle(color: Palette.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle location settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Palette.icons),
              title: const Text(
                'Trend settings',
                style: TextStyle(color: Palette.textPrimary),
              ),
              subtitle: const Text(
                'Customize trending topics',
                style: TextStyle(color: Palette.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle trend settings
              },
            ),
          ],
        ),
      ),
    );
  }
}

