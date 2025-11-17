// ignore_for_file: unused_import

import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'chat_local_repository.g.dart';

@Riverpod(keepAlive: true)
ChatLocalRepository chatLocalRepository(Ref ref) {
  return ChatLocalRepository();
}

class ChatLocalRepository {}
