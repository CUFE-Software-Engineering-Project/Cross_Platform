import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/palette.dart';

Widget buildTermsTextP() {
  return RichText(
    text: TextSpan(
      text: 'By signing up, you agree to the ',
      style: const TextStyle(
        color: Palette.greycolor,
        fontSize: 15,
        height: 1.5,
      ),
      children: [
        TextSpan(
          text: 'Terms of Service',
          style: const TextStyle(color: Palette.primary),
        ),
        const TextSpan(text: ' and '),
        TextSpan(
          text: 'Privacy Policy',
          style: const TextStyle(color: Palette.primary),
        ),
        const TextSpan(text: ', including '),
        TextSpan(
          text: 'Cookie Use',
          style: const TextStyle(color: Palette.primary),
        ),
        const TextSpan(
          text:
              '. X may use your contact information, including your email address and phone number for purposes outlined in our Privacy Policy, such as keeping your account secure and personalising our services, including ads. ',
        ),
        TextSpan(
          text: 'Learn more',
          style: const TextStyle(color: Palette.primary),
        ),
        const TextSpan(
          text:
              '. Others will be able to find you by email address or phone number, when provided, unless you choose otherwise ',
        ),
        TextSpan(
          text: 'here',
          style: const TextStyle(color: Palette.primary),
        ),
        const TextSpan(text: '.'),
      ],
    ),
  );
}
