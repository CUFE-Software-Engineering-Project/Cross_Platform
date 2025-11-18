import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/settings/view/widgets/settings_responsive_scaffold.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class YourAccountScreen extends ConsumerWidget {
  const YourAccountScreen({super.key});

  String _subtitle(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final username = user?.username;
    return username == null || username.isEmpty ? '' : '@$username';
  }

  Widget _tile({required Widget leading, required String title, required String subtitle, VoidCallback? onTap}) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(width: 44, height: 44, child: Center(child: leading)),
        title: Text(
          title,
          style: const TextStyle(color: Palette.textWhite, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Palette.textSecondary, fontSize: 13)),
        onTap: onTap,
      );

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'See information about your account, download an archive of your data, or learn about account deactivation options.',
              style: TextStyle(color: Palette.textSecondary, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),

            _tile(
              leading: Icon(LucideIcons.user, color: Palette.textWhite, size: 22),
              title: 'Account information',
              subtitle: 'See your account information like your phone number and email address.',
              onTap: () => GoRouter.of(context).pushNamed(RouteConstants.accountinformationscreen),
            ),
            _tile(
              leading: Icon(LucideIcons.lock, color: Palette.textWhite, size: 22),
              title: 'Change your password',
              subtitle: 'Change your password at any time.',
              onTap: () => GoRouter.of(context).pushNamed(RouteConstants.passwordscreen),
            ),
            _tile(
              leading: Icon(LucideIcons.download, color: Palette.textWhite, size: 22),
              title: 'Download an archive of your data',
              subtitle: 'Get insights into the type of information stored for your account.',
            ),
            _tile(
              leading: Icon(LucideIcons.heart, color: Palette.textWhite, size: 22),
              title: 'Deactivate Account',
              subtitle: 'Find out how you can deactivate your account.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final subtitle = _subtitle(ref);
      if (constraints.maxWidth > 600) {
        return SettingsResponsiveScaffold.web(
          title: 'Your account',
          subtitle: subtitle,
          body: _body(context),
        );
      }
      return SettingsResponsiveScaffold.mobile(
        title: 'Your account',
        subtitle: subtitle,
        body: _body(context),
      );
    });
  }
}
