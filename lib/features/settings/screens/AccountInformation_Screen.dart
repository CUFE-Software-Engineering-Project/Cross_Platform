import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/settings/view/widgets/settings_responsive_scaffold.dart';

class AccountInformationScreen extends ConsumerWidget {
  const AccountInformationScreen({super.key});

  String _subtitle(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final username = user?.username;
    return username == null || username.isEmpty ? '' : '@$username';
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                color: Palette.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      );
  }

  Widget _field(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          value,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final username = user?.username ?? '';
    final email = user?.email ?? '';

    Widget body = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (username.isNotEmpty) ...[
              Text(
                '@$username',
                style: const TextStyle(
                  color: Palette.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _section(
              title: '',
              children: [
                _field(
                  'Username',
                  Text(
                    username.isEmpty ? '-' : '@$username',
                    style: const TextStyle(color: Palette.textSecondary, fontSize: 16),
                  ),
                ),
                _field(
                  'Phone',
                  const Text(
                    'Add',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                _field(
                  'Email',
                  Text(
                    email.isEmpty ? '-' : email,
                    style: const TextStyle(color: Palette.textSecondary, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Country', style: TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Egypt', style: TextStyle(color: Palette.textSecondary, fontSize: 16)),
                      SizedBox(height: 8),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Select the country you live in. ',
                            style: TextStyle(color: Palette.textSecondary, fontSize: 16),
                          ),
                          TextSpan(
                            text: 'Learn more',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                _field(
                  'Automation',
                  const Text(
                    'Manage your automated account.',
                    style: TextStyle(color: Palette.textSecondary, fontSize: 16),
                  ),
                ),
                _field(
                  'Parody, commentary and fan account',
                  const Text(
                    'Manage your parody, commentary and fan account.',
                    style: TextStyle(color: Palette.textSecondary, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _subtitle(ref); // keep provider call for side-effect-free compatibility (not used for placeholder)
        if (constraints.maxWidth > 600) {
          return SettingsResponsiveScaffold.web(
            title: 'Account information',
            subtitle: '@profilename',
            body: body,
          );
        }
        return SettingsResponsiveScaffold.mobile(
          title: 'Account information',
          subtitle: '',
          body: body,
        );
      },
    );
  }
}
