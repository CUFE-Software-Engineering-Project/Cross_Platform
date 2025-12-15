import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';

class MentionsEmptyStateWidget extends StatelessWidget {
  const MentionsEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 336,
          height: 148,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Nothing to see here — yet",
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  color: Palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "When someone mentions you, you'll find it here.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Palette.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
