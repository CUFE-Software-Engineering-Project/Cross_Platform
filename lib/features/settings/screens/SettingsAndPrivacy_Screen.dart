import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: Palette.textWhite,
            size: 22,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Settings',
              style: TextStyle(
                color: Palette.textWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '',
              style: TextStyle(color: Palette.textSecondary, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(64),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: _SearchBar(),
          ),
        ),
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      backgroundColor: Palette.background,
      body: const _SettingsList(),
    );
  }
}

class _BuildWebLayout extends StatelessWidget {
  const _BuildWebLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Center(
        child: Container(
          width: 800,
          height: 700,
          decoration: BoxDecoration(
            color: Palette.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [
              SizedBox(height: 12),
              _ProfileHeader(),
              SizedBox(height: 8),
              _SearchBar(),
              SizedBox(height: 8),
              Expanded(child: _SettingsList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: Icon(LucideIcons.user, color: Palette.textWhite, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: Palette.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '@profilename',
                style: TextStyle(color: Palette.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Palette.inputBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.search, color: Palette.textSecondary, size: 18),
            SizedBox(width: 10),
            Text(
              'Search settings',
              style: TextStyle(color: Palette.textSecondary),
            ),
          ],
        ),
      ),
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
          ),
          _tile(
            Icon(LucideIcons.lock, color: Palette.textWhite, size: 22),
            'Security and account access',
            'Manage your account\'s security and keep track of your account\'s usage including apps that you have connected to your account.',
          ),
          _tile(
            // SvgPicture.asset(
            //   'assets/icons/x.svg',
            //   width: 20,
            //   height: 20,
            //   color: Palette.textWhite,
            // ),
            Icon(Icons.workspace_premium),
            'Premium',
            'See what\'s included in Premium and manage your settings.',
          ),
          _tile(
            // SvgPicture.asset(
            //   'assets/icons/money.svg',
            //   width: 20,
            //   height: 20,
            //   color: Palette.textWhite,
            // ),
            Icon(Icons.workspace_premium),
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
