import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

/// Clean status bar widget
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Palette.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 53,
                alignment: Alignment.centerLeft,
                child: const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    "https://pbs.twimg.com/profile_images/1974381737816756224/AAifKtE9_bigger.jpg",
                  ),
                ),
              ),
              Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Palette.textWhite,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Icon(
            Icons.settings_outlined,
            size: 20,
            color: Palette.icons,
          ),
        ],
      ),
    );
  }
}
