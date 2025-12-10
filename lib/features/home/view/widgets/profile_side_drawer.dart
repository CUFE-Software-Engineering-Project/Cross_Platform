import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/providers/user_profile_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfileSideDrawer extends ConsumerWidget {
  const ProfileSideDrawer({super.key});

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
    final profileState = ref.watch(profileDataProvider(user?.username ?? ""));

    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: profileState.when(
          data: (either) => either.fold(
            (l) => _buildDrawerContent(context, ref, user, null),
            (profileData) =>
                _buildDrawerContent(context, ref, user, profileData),
          ),
          loading: () => _buildLoadingDrawer(context, ref, user),
          error: (_, __) => _buildDrawerContent(context, ref, user, null),
        ),
      ),
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
    ProfileModel? profileData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: InkWell(
            onTap: () {
              context.push("/profilescreen/${user?.username}");
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildSmallProfileImage(
                  radius: 35,
                  username: user?.username ?? "",
                ),
                const SizedBox(height: 12),
                Text(
                  profileData?.displayName ?? user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '@${profileData?.username ?? user?.username ?? 'username'}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (profileData?.isVerified == true) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        color: const Color(0xFF1DA1F2),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStat(
                      '${profileData?.followingCount ?? user?.interests.length ?? 0}',
                      'Following',
                    ),
                    const SizedBox(width: 16),
                    _buildStat(
                      '${profileData?.followersCount ?? 0}',
                      'Followers',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(color: Color(0xFF1f1f1f), height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  if (user != null) {
                    context.push("/profilescreen/${user.username}");
                  }
                },
              ),
              _DrawerItem(
                icon: Icons.stars_outlined,
                label: 'Premium',
                onTap: () {},
              ),
              _DrawerItem(
                icon: Icons.chat_bubble_outline,
                trailing: _buildBadge('Beta'),
                label: 'Chat',
                onTap: () {},
              ),
              _DrawerItem(
                icon: Icons.bookmark_border,
                label: 'Bookmarks',
                onTap: () {},
              ),
              _DrawerItem(
                icon: Icons.list_alt_outlined,
                label: 'Lists',
                onTap: () {},
              ),
              _DrawerItem(
                icon: Icons.south_america_outlined,
                label: 'Spaces',
                onTap: () {},
              ),
              _DrawerItem(
                icon: Icons.monetization_on_outlined,
                label: 'Monetization',
                onTap: () {},
              ),
              const Divider(
                color: Color(0xFF1f1f1f),
                height: 24,
                thickness: 0.5,
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings & Support',
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push("/settingandprivacyscreen");
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDrawer(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey[850],
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 12),
              Container(height: 20, width: 150, color: Colors.grey[850]),
              const SizedBox(height: 8),
              Container(height: 14, width: 100, color: Colors.grey[850]),
            ],
          ),
        ),
        const Divider(color: Color(0xFF1f1f1f), height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _DrawerItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(context);
                  if (user != null) {
                    context.push("/profilescreen/${user.username}");
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      horizontalTitleGap: 16,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
