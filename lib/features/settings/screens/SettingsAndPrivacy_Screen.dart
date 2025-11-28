import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lite_x/features/settings/view/widgets/settings_search_bar.dart';
import 'package:lite_x/features/settings/view/widgets/settings_responsive_scaffold.dart';

class SettingsAndPrivacyScreen extends StatelessWidget {
  const SettingsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return const _BuildWebLayout();
        } else {
          return const _BuildMobileLayout();
        }
      },
    );
  }
}

class _BuildMobileLayout extends StatelessWidget {
  const _BuildMobileLayout();

  @override
  Widget build(BuildContext context) {
    return SettingsResponsiveScaffold.mobile(
      title: 'Settings',
      subtitle: '',
      headerBottom: const SettingsSearchBar(),
      body: const _SettingsList(),
    );
  }
}

class _BuildWebLayout extends StatelessWidget {
  const _BuildWebLayout();

  @override
  Widget build(BuildContext context) {
    return SettingsResponsiveScaffold.web(
      title: 'Settings',
      subtitle: '@profilename',
      headerBottom: const SettingsSearchBar(),
      body: const _SettingsList(),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  Widget _tile(
    Widget leadingWidget,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    leading: SizedBox(
      width: 44,
      height: 44,
      child: Center(child: leadingWidget),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Palette.textWhite,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: Palette.textSecondary, fontSize: 13),
    ),
    onTap: onTap ?? () {},
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _tile(
            Icon(LucideIcons.user, color: Palette.textWhite, size: 22),
            'Your account',
            'See information about your account, download an archive of your data, or learn about your account deactivation options.',
            onTap: () => GoRouter.of(context).pushNamed(RouteConstants.youraccountscreen),
          ),
          _tile(
            Icon(LucideIcons.lock, color: Palette.textWhite, size: 22),
            'Security and account access',
            'Manage your account\'s security and keep track of your account\'s usage including apps that you have connected to your account.',
          ),
          _tile(
            Icon(Icons.workspace_premium, color: Palette.textWhite, size: 22),
            'Premium',
            'See what\'s included in Premium and manage your settings.',
          ),
          _tile(
            Icon(Icons.attach_money, color: Palette.textWhite, size: 22),
            'Monetization',
            'See how you can make money on X and manage your monetization settings.',
          ),
          _tile(
            Icon(LucideIcons.shield, color: Palette.textWhite, size: 22),
            'Privacy and safety',
            'Manage what information you see and share on X.',
            onTap: () => GoRouter.of(
              context,
            ).pushNamed(RouteConstants.privacyandsafetyscreen, extra: null),
          ),
          _tile(
            Icon(LucideIcons.bell, color: Palette.textWhite, size: 22),
            'Notifications',
            'Select the kinds of notifications you get about your activities, interests, and recommendations.',
          ),
          _tile(
            Icon(LucideIcons.accessibility, color: Palette.textWhite, size: 22),
            'Accessibility, display and languages',
            'Manage how X content is displayed and more.',
          ),
          _tile(
            Icon(LucideIcons.ellipsis, color: Palette.textWhite, size: 22),
            'Additional resources',
            'Check out other places for helpful information to learn more about X products and services.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
