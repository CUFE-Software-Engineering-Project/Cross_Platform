import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;

  const SearchField({super.key, required this.hintText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 11),
        height: 40,
        decoration: BoxDecoration(
          color: Palette.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hintText,
                style: const TextStyle(
                  color: Color.fromARGB(255, 85, 88, 92),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
