// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lite_x/features/chat/view/TestChatScreen.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/theme/app_theme.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/mediamodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';

void main() async {
  await init();
  runApp(const ProviderScope(child: const MyApp()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(MediaModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('userBox'); // For testing purposes
  await Hive.deleteBoxFromDisk('tokenBox'); // For testing purposes

  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox('tokenBox');
  await dotenv.load(fileName: ".env");
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
