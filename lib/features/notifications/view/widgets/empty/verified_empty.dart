import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';

class VerifiedEmptyStateWidget extends StatelessWidget {
  const VerifiedEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 336,
          height: 388,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  'https://abs.twimg.com/responsive-web/client-web/verification-check-800x400.v1.52677a99.png',
                  width: 336,
                  height: 168,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

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
                "Likes, mentions, reposts, and a whole lot more — when it comes from a verified account, you'll find it here.",
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
