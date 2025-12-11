import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

Widget buildTermsText() {
  return Text.rich(
    TextSpan(
      text: 'By signing up, you agree to our ',
      style: const TextStyle(color: Colors.grey, fontSize: 14),
      children: [
        TextSpan(
          text: 'Terms',
          style: TextStyle(color: Palette.info),
        ),
        const TextSpan(text: ', '),
        TextSpan(
          text: 'Privacy Policy',
          style: TextStyle(color: Palette.info),
        ),
        const TextSpan(text: ' and '),
        TextSpan(
          text: 'Cookie Use',
          style: TextStyle(color: Palette.info),
        ),
        const TextSpan(text: '.'),
      ],
    ),
    textAlign: TextAlign.start,
  );
}
