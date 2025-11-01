import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';

class MuteAndBlockScreen extends StatelessWidget {
  const MuteAndBlockScreen({super.key});

  Widget _sectionDescription() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          'Manage the accounts, words, and notifications that you\'ve muted or blocked.',
          style: const TextStyle(color: Palette.textSecondary, fontSize: 16, height: 1.4),
        ),
      );

  Widget _linkTile(String title, {VoidCallback? onTap}) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        title: Text(title, style: const TextStyle(color: Palette.textWhite, fontSize: 16)),
        onTap: onTap ?? () {},
      );

  Widget _buildContent(BuildContext context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _sectionDescription(),
            const SizedBox(height: 12),
            _linkTile('Blocked accounts', onTap: () => GoRouter.of(context).pushNamed(RouteConstants.blockedaccountsscreen)),
            _linkTile('Muted accounts', onTap: () => GoRouter.of(context).pushNamed(RouteConstants.mutedaccountsscreen)),
            _linkTile('Muted words'),
            _linkTile('Muted notifications'),
            const SizedBox(height: 48),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
                      icon: const Icon(Icons.arrow_back, color: Palette.textWhite, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Mute and block', style: TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('@profilename', style: TextStyle(color: Palette.textSecondary, fontSize: 12)),
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

      return Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Palette.textWhite, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Mute and block', style: TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('@profilename', style: TextStyle(color: Palette.textSecondary, fontSize: 12)),
            ],
          ),
          centerTitle: false,
        ),
        body: _buildContent(context),
      );
    });
  }
}
