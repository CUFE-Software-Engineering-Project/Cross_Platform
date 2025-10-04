import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/auth/view/widgets/buildXLogo.dart';

class UsernameScreen extends StatelessWidget {
  const UsernameScreen({super.key});
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
        title: buildXLogo(size: 36),
        centerTitle: true,
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      backgroundColor: Palette.background,
      body: _UsernameForm(isWeb: false),
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
          width: 600,
          height: 650,
          decoration: BoxDecoration(
            color: Palette.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Palette.textWhite),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(child: Center(child: buildXLogo(size: 40))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Expanded(child: _UsernameForm(isWeb: true)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameForm extends ConsumerStatefulWidget {
  const _UsernameForm({required this.isWeb});

  final bool isWeb;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __UsernameFormState();
}

class __UsernameFormState extends ConsumerState<_UsernameForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
