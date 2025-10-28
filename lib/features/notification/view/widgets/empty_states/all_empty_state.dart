import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lite_x/core/theme/palette.dart';

/// Clean empty state for all notifications
class AllEmptyState extends StatelessWidget {
  const AllEmptyState({super.key});

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
                style: GoogleFonts.libreFranklin(
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  color: Palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "From likes to reposts and a whole lot more, this is where all the action happens.",
                style: GoogleFonts.libreFranklin(
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
