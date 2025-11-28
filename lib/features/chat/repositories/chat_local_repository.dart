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

class ChatLocalRepository {
  final Box<ConversationModel> _conversationsBox = Hive.box<ConversationModel>(
    "conversationsBox",
  );

  final Box<MessageModel> _messagesBox = Hive.box<MessageModel>("messagesBox");

  // Save or update conversations
  Future<void> upsertConversations(
    List<ConversationModel> conversations,
  ) async {
    for (ConversationModel conv in conversations) {
      await _conversationsBox.put(conv.id, conv);
    }
  }

  // Load all cached conversations
  List<ConversationModel> getAllConversations() {
    return _conversationsBox.values.toList();
  }

  //
  ConversationModel? getConversationById(String id) {
    return _conversationsBox.get(id);
  }

  // save Message
  Future<void> saveMessage(MessageModel message) async {
    await _messagesBox.put(message.id, message);
  }

  // Save list of messages (when loading chat history)
  Future<void> saveMessages(List<MessageModel> messages) async {
    for (MessageModel msg in messages) {
      await _messagesBox.put(msg.id, msg);
    }
  }

  // get messages by chat_id
  List<MessageModel> getMessagesForChat(String chatId) {
    return _messagesBox.values.where((msg) => msg.chatId == chatId).toList();
  }

  // update message status
  Future<void> markMessagesAsRead(String chatId, String myUserId) async {
    for (MessageModel msg in _messagesBox.values) {
      if (msg.chatId == chatId && msg.userId == myUserId) {
        msg.status = "READ";
        await msg.save();
      }
    }
  }

  // When user sends a message -> mark as sent immediately
  Future<void> markMessageAsSent(String messageId) async {
    final msg = _messagesBox.get(messageId);
    if (msg != null) {
      msg.status = "SENT";
      await msg.save();
    }
  }

  // DELETE MESSAGE
  Future<void> deleteMessage(String messageId) async {
    await _messagesBox.delete(messageId);
  }

  // CLEAR ALL cache
  Future<void> clearAll() async {
    await _conversationsBox.clear();
    await _messagesBox.clear();
  }
}
