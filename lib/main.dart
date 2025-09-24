import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/app_theme.dart';
import 'package:lite_x/features/auth/view/widgets/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'X Lite',
      theme: appTheme,
      home: const Test(),
    );
  }
}
