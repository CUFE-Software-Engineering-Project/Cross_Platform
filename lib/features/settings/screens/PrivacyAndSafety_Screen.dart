import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';

class PrivacyAndSafetyScreen extends StatelessWidget {
  const PrivacyAndSafetyScreen({super.key});

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Palette.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _tile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: SizedBox(
      width: 40,
      height: 40,
      child: Center(child: Icon(icon, color: Palette.textWhite, size: 18)),
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

  Widget _linkTile(String title) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    title: Text(title, style: const TextStyle(color: Palette.textWhite)),
    onTap: () {},
  );

  Widget _buildContent(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionTitle('Your X activity'),
        _tile(
          Icons.group,
          'Audience and tagging',
          'Manage what information you allow other people on X to see.',
        ),
        _tile(
          Icons.edit,
          'Your posts',
          'Manage the information associated with your posts.',
        ),
        _tile(
          Icons.view_list,
          'Content you see',
          'Decide what you see on X based on your preferences.',
        ),
        _tile(
          Icons.block,
          'Mute and block',
          'Manage the accounts, words, and notifications that you\'ve muted or blocked.',
          onTap: () =>
              GoRouter.of(context).pushNamed(RouteConstants.muteandblockscreen),
        ),
        _tile(
          Icons.mail_outline,
          'Direct messages',
          'Manage who can message you directly.',
        ),
        _tile(Icons.mic, 'Spaces', 'Manage your Spaces activity'),
        _tile(
          Icons.person_search,
          'Discoverability and contacts',
          'Control your discoverability settings and manage contacts you\'ve imported.',
        ),

        const SizedBox(height: 18),
        _sectionTitle('Data sharing and personalization'),
        _tile(
          Icons.open_in_new,
          'Ads preferences',
          'Manage your ads experience on X.',
        ),
        _tile(
          Icons.show_chart,
          'Inferred identity',
          'Allow X to personalize your experience with your inferred activity.',
        ),
        _tile(
          Icons.sync_alt,
          'Data sharing with business partners',
          'Allow sharing of additional information with X\'s business partners.',
        ),
        _tile(
          Icons.location_on,
          'Location information',
          'Manage the location information X uses to personalize your experience.',
        ),
        _tile(
          Icons.shield,
          'Grok & Third-party Collaborators',
          'Allow your public data and interactions to be used for training and fine-tuning.',
        ),

        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          color: Palette.cardBackground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: const Text(
            'Learn more about privacy on X',
            style: TextStyle(
              color: Palette.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _linkTile('Privacy center'),
        _linkTile('Privacy policy'),
        _linkTile('Contact us'),
        const SizedBox(height: 48),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Match the Settings screen's web container size and mobile full-screen behavior
        if (constraints.maxWidth > 600) {
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
                  children: [
                    AppBar(
                      backgroundColor: Palette.background,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Palette.textWhite,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Privacy and safety',
                            style: TextStyle(
                              color: Palette.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '@profilename',
                            style: TextStyle(
                              color: Palette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      centerTitle: false,
                    ),
                    Expanded(child: _buildContent(context)),
                  ],
                ),
              ),
            ),
          );
        }

        // Mobile layout (full screen)
        return Scaffold(
          backgroundColor: Palette.background,
          appBar: AppBar(
            backgroundColor: Palette.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Palette.textWhite,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Privacy and safety',
                  style: TextStyle(
                    color: Palette.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '@profilename',
                  style: TextStyle(color: Palette.textSecondary, fontSize: 12),
                ),
              ],
            ),
            centerTitle: false,
          ),
          body: _buildContent(context),
        );
      },
    );
  }
}
