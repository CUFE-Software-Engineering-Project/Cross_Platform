import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lite_x/core/theme/palette.dart';

class SettingsSearchBar extends StatelessWidget {
  const SettingsSearchBar({super.key});

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
