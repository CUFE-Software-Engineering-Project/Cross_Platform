import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lite_x/core/models/search_history_hive_model.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();  

  await Hive.openBox<SearchHistoryHiveModel>('search_history');

  runApp(const ProviderScope(child: MyApp()));
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
