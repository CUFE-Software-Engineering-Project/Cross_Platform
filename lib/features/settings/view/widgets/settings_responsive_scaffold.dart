import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lite_x/core/theme/Palette.dart';

class SettingsResponsiveScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final Widget? headerBottom;
  final bool isWeb;

  const SettingsResponsiveScaffold._({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.headerBottom,
    required this.isWeb,
    Key? key,
  }) : super(key: key);

  factory SettingsResponsiveScaffold.mobile({
    required String title,
    required String subtitle,
    required Widget body,
    Widget? headerBottom,
  }) => SettingsResponsiveScaffold._(
    title: title,
    subtitle: subtitle,
    body: body,
    headerBottom: headerBottom,
    isWeb: false,
  );

  factory SettingsResponsiveScaffold.web({
    required String title,
    required String subtitle,
    required Widget body,
    Widget? headerBottom,
  }) => SettingsResponsiveScaffold._(
    title: title,
    subtitle: subtitle,
    body: body,
    headerBottom: headerBottom,
    isWeb: true,
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      leading: IconButton(
        icon: const Icon(
          LucideIcons.arrowLeft,
          color: Palette.textWhite,
          size: 24,
        ),
        onPressed: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Palette.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                color: Palette.textSecondary,
                fontSize: 13,
              ),
            ),
        ],
      ),
      centerTitle: false,
      bottom: headerBottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: headerBottom,
              ),
            )
          : null,
      backgroundColor: Palette.background,
      elevation: 0,
    );
  }

  Widget _buildWebContainer(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Palette.background,
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isWeb ? _buildWebContainer(context) : _buildMobileScaffold(context);
  }
}
