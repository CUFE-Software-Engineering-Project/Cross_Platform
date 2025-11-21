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
                    backgroundImage:
                        user?.photo != null && user!.photo!.isNotEmpty
                        ? NetworkImage(user.photo!)
                        : null,
                    child: user?.photo == null || user?.photo?.isEmpty == true
                        ? Icon(Icons.person, color: Colors.grey[500], size: 32)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Yara Elbaki',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user?.username ?? 'FaroukYara21241'}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStat('${user?.interests.length ?? 0}', 'Following'),
                      const SizedBox(width: 16),
                      _buildStat('0', 'Followers'),
                    ],
                  ),
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
        ),
      ),
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
