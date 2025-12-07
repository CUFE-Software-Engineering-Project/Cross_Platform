import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
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
              backgroundColor: Colors.grey[800],
              backgroundImage: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                  ? NetworkImage(userAvatarUrl!)
                  : null,
              child: userAvatarUrl == null || userAvatarUrl!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey[400], size: 18)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Search Bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.pushNamed(
                  RouteConstants.SearchScreen,
                  extra: <String, dynamic>{'showResults': false},
                );
              },
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
                      ' Search',
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
              Icons.settings_outlined,
              size: 24,
              color: Palette.icons,
            ),
            onPressed: onSettingsTap ?? () {

            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

