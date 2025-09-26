import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/theme/app_theme.dart';

void main() async {
  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'X Lite',
      theme: appTheme,
      routerConfig: Approuter.router,
    );
  }
}
