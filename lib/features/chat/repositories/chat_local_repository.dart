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

  List<MessageModel> getCachedMessages(String chatId) {
    final messages = _messagesBox.values
        .where((msg) => msg.chatId == chatId)
        .toList();
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return messages;
  }

  Future<void> saveMessage(MessageModel message) async {
    await _messagesBox.put(message.id, message);
    if (message.status != "READ") {
      await _enforceCacheLimit(message.chatId);
    }
  }

  Future<void> saveInitialMessages(List<MessageModel> messages) async {
    final Map<String, MessageModel> entries = {
      for (var msg in messages) msg.id: msg,
    };
    await _messagesBox.putAll(entries);

    if (messages.isNotEmpty) {
      await _enforceCacheLimit(messages.first.chatId);
    }
  }

  Future<void> replaceTempWithServerMessage({
    required String tempId,
    required MessageModel serverMessage,
  }) async {
    if (_messagesBox.containsKey(tempId)) {
      await _messagesBox.delete(tempId);
    }

    await _messagesBox.put(serverMessage.id, serverMessage);
    await _enforceCacheLimit(serverMessage.chatId);
  }

  Future<void> markMessagesAsRead(String chatId, String myUserId) async {
    final messagesToUpdate = _messagesBox.values.where(
      (msg) =>
          msg.chatId == chatId &&
          msg.userId == myUserId &&
          msg.status != "READ",
    );

    for (var msg in messagesToUpdate) {
      msg.status = "READ";
      await msg.save();
    }
  }

  Future<void> markMessageAsSent(String messageId) async {
    final msg = _messagesBox.get(messageId);
    if (msg != null && msg.status != "READ") {
      msg.status = "SENT";
      await msg.save();
    }
  }

  Future<void> _enforceCacheLimit(String chatId) async {
    final chatMessages = _messagesBox.values
        .where((msg) => msg.chatId == chatId)
        .toList();

    if (chatMessages.length <= 50) return;
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final messagesToDelete = chatMessages.sublist(50);
    final keysToDelete = messagesToDelete.map((e) => e.id).toList();

    if (keysToDelete.isNotEmpty) {
      await _messagesBox.deleteAll(keysToDelete);
    }
  }

  List<MessageModel> getPendingMessages(String chatId) {
    return _messagesBox.values
        .where((msg) => msg.chatId == chatId && msg.status == "SENDING")
        .toList();
  }

  Future<void> upsertConversations(
    List<ConversationModel> conversations,
  ) async {
    for (ConversationModel conv in conversations) {
      await _conversationsBox.put(conv.id, conv);
    }
  }

  List<ConversationModel> getAllConversations() {
    return _conversationsBox.values.toList();
  }

  ConversationModel? getConversationById(String id) {
    return _conversationsBox.get(id);
  }

  Future<void> clearAll() async {
    await _conversationsBox.clear();
    await _messagesBox.clear();
  }

  Future<void> deleteMessage(String messageId) async {
    await _messagesBox.delete(messageId);
  }
}
