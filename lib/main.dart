import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/routes/AppRouter.dart';
import 'package:lite_x/core/services/deep_link_service.dart';
import 'package:lite_x/core/theme/app_theme.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/search/models/search_history_hive_model.dart';
import 'firebase_options.dart';

void main() async {
  await init();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DeepLinkService.init();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ProfileModelAdapter());
  await await Hive.openBox<ProfileModel>('profileDataBox');
  // await Hive.deleteBoxFromDisk('userBox');
  // await Hive.deleteBoxFromDisk('tokenBox');
  // await Hive.deleteBoxFromDisk('conversationsBox');
  // await Hive.deleteBoxFromDisk('messagesBox');
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox('tokenBox');
  await Hive.openBox<ConversationModel>('conversationsBox');
  await Hive.openBox<MessageModel>('messagesBox');
  await dotenv.load(fileName: ".env");

  await Hive.openBox<SearchHistoryHiveModel>('search_history');
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
