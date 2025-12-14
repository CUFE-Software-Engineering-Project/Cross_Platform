import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lite_x/core/theme/Palette.dart';

Widget buildXLogo({required double size}) {
  return SvgPicture.asset(
    'assets/svg/xlogo.svg',
    colorFilter: const ColorFilter.mode(Palette.textWhite, BlendMode.srcIn),
    width: size,
    height: size,
  );
}
