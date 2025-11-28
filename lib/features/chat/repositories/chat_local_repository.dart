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
  static const String CONVERSATIONS_BOX = 'conversations';
  static const String MESSAGES_BOX = 'messages';
  static const String TEMP_MESSAGES_BOX = 'temp_messages';

  Box<ConversationModel>? _conversationsBox;
  Box<dynamic>? _messagesBox;
  Box<MessageModel>? _tempMessagesBox;

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    if (_conversationsBox?.isOpen != true) {
      _conversationsBox = await Hive.openBox<ConversationModel>(
        CONVERSATIONS_BOX,
      );
    }

    if (_messagesBox?.isOpen != true) {
      _messagesBox = await Hive.openBox(MESSAGES_BOX);
    }

    if (_tempMessagesBox?.isOpen != true) {
      _tempMessagesBox = await Hive.openBox<MessageModel>(TEMP_MESSAGES_BOX);
    }
  }

  bool get isInitialized =>
      _conversationsBox != null &&
      _messagesBox != null &&
      _tempMessagesBox != null;

  // ==================== CONVERSATIONS ====================

  /// Save single conversation
  Future<void> saveConversation(ConversationModel conversation) async {
    if (!isInitialized) await initialize();
    await _conversationsBox?.put(conversation.id, conversation);
  }

  /// Save multiple conversations (bulk sync)
  Future<void> saveConversations(List<ConversationModel> conversations) async {
    if (!isInitialized) await initialize();

    final Map<String, ConversationModel> entries = {
      for (var conv in conversations) conv.id: conv,
    };
    await _conversationsBox?.putAll(entries);
  }

  /// Get all conversations sorted by last message time
  List<ConversationModel> getAllConversations() {
    if (!isInitialized) return [];

    final conversations = _conversationsBox?.values.toList() ?? [];

    // Sort by last message time (newest first)
    conversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return conversations;
  }

  /// Get single conversation by ID
  ConversationModel? getConversationById(String chatId) {
    if (!isInitialized) return null;
    return _conversationsBox?.get(chatId);
  }

  /// Watch conversations for real-time updates
  Stream<List<ConversationModel>> watchConversations() {
    if (!isInitialized) return Stream.value([]);

    return _conversationsBox!.watch().map((_) {
      return getAllConversations();
    });
  }

  /// Delete conversation and its messages
  Future<void> deleteConversation(String chatId) async {
    if (!isInitialized) await initialize();

    await _conversationsBox?.delete(chatId);
    await deleteMessages(chatId);
  }

  /// Update conversation metadata
  Future<void> updateConversation(ConversationModel conversation) async {
    if (!isInitialized) await initialize();
    await _conversationsBox?.put(conversation.id, conversation);
  }

  /// Update unseen count for a conversation
  Future<void> updateUnseenCount(String chatId, int count) async {
    if (!isInitialized) await initialize();

    final conversation = getConversationById(chatId);
    if (conversation != null) {
      final updated = conversation.copyWith(unseenCount: count);
      await saveConversation(updated);
    }
  }

  /// Increment unseen count
  Future<void> incrementUnseenCount(String chatId) async {
    if (!isInitialized) await initialize();

    final conversation = getConversationById(chatId);
    if (conversation != null) {
      final updated = conversation.copyWith(
        unseenCount: conversation.unseenCount + 1,
      );
      await saveConversation(updated);
    }
  }

  /// Reset unseen count to zero
  Future<void> resetUnseenCount(String chatId) async {
    await updateUnseenCount(chatId, 0);
  }

  // ==================== MESSAGES ====================

  /// Get messages for a specific chat
  List<MessageModel> getMessages(String chatId) {
    if (!isInitialized) return [];

    final messagesData = _messagesBox?.get(chatId) as List<dynamic>?;
    if (messagesData == null) return [];

    try {
      return messagesData
          .map((json) => MessageModel.fromMap(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Sort by time
    } catch (e) {
      print('Error parsing messages for chat $chatId: $e');
      return [];
    }
  }

  /// Save single message
  Future<void> saveMessage(MessageModel message) async {
    if (!isInitialized) await initialize();

    final messages = getMessages(message.chatId);

    // Check if message already exists (avoid duplicates)
    final existingIndex = messages.indexWhere((m) => m.id == message.id);
    if (existingIndex != -1) {
      messages[existingIndex] = message;
    } else {
      messages.add(message);
    }

    // Sort by creation time
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Save to Hive
    await _messagesBox?.put(
      message.chatId,
      messages.map((m) => m.toMap()).toList(),
    );

    // Update last message in conversation
    await _updateLastMessage(message);
  }

  /// Save multiple messages (bulk)
  Future<void> saveMessages(String chatId, List<MessageModel> messages) async {
    if (!isInitialized) await initialize();

    // Sort by creation time
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    await _messagesBox?.put(chatId, messages.map((m) => m.toMap()).toList());

    if (messages.isNotEmpty) {
      await _updateLastMessage(messages.last);
    }
  }

  /// Watch messages for a chat (real-time stream)
  Stream<List<MessageModel>> watchMessages(String chatId) {
    if (!isInitialized) return Stream.value([]);

    return _messagesBox!.watch(key: chatId).map((_) {
      return getMessages(chatId);
    });
  }

  /// Update message status (PENDING -> SENT -> DELIVERED -> READ)
  Future<void> updateMessageStatus(
    String messageId,
    String chatId,
    String newStatus,
  ) async {
    if (!isInitialized) await initialize();

    final messages = getMessages(chatId);
    final index = messages.indexWhere((m) => m.id == messageId);

    if (index != -1) {
      messages[index] = messages[index].copyWith(status: newStatus);
      await saveMessages(chatId, messages);
    }
  }

  /// Replace temporary message with real message from server
  Future<void> replaceMessage(String tempId, MessageModel realMessage) async {
    if (!isInitialized) await initialize();

    final messages = getMessages(realMessage.chatId);
    final index = messages.indexWhere((m) => m.id == tempId);

    if (index != -1) {
      messages[index] = realMessage;
      await saveMessages(realMessage.chatId, messages);

      // Remove from temp box
      await _tempMessagesBox?.delete(tempId);
    }
  }

  /// Delete all messages for a chat
  Future<void> deleteMessages(String chatId) async {
    if (!isInitialized) await initialize();
    await _messagesBox?.delete(chatId);
  }

  /// Mark all messages as READ for a chat
  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    if (!isInitialized) await initialize();

    final messages = getMessages(chatId);

    // Only update messages that are not from current user
    final updated = messages.map((m) {
      if (m.userId != currentUserId && m.status != 'READ') {
        return m.copyWith(status: 'READ');
      }
      return m;
    }).toList();

    await saveMessages(chatId, updated);

    // Reset unseen count
    await resetUnseenCount(chatId);
  }

  /// Delete a specific message
  Future<void> deleteMessage(String messageId, String chatId) async {
    if (!isInitialized) await initialize();

    final messages = getMessages(chatId);
    messages.removeWhere((m) => m.id == messageId);
    await saveMessages(chatId, messages);
  }

  // ==================== TEMPORARY MESSAGES ====================

  /// Save temporary message (for optimistic UI)
  Future<void> saveTempMessage(MessageModel message) async {
    if (!isInitialized) await initialize();

    await _tempMessagesBox?.put(message.id, message);
    await saveMessage(message); // Also save to main messages
  }

  /// Get all temporary/pending messages for retry
  List<MessageModel> getTempMessages() {
    if (!isInitialized) return [];
    return _tempMessagesBox?.values.toList() ?? [];
  }

  /// Remove temporary message
  Future<void> removeTempMessage(String tempId) async {
    if (!isInitialized) await initialize();
    await _tempMessagesBox?.delete(tempId);
  }

  // ==================== HELPER METHODS ====================

  /// Update last message info in conversation
  Future<void> _updateLastMessage(MessageModel message) async {
    final conversation = getConversationById(message.chatId);
    if (conversation != null) {
      final updated = conversation.copyWith(
        lastMessageContent: message.content,
        lastMessageTime: message.createdAt,
        lastMessageSenderId: message.userId,
        updatedAt: DateTime.now(),
      );
      await saveConversation(updated);
    }
  }

  /// Get unseen messages count for a chat
  int getUnseenCount(String chatId, String currentUserId) {
    final messages = getMessages(chatId);
    return messages
        .where((m) => m.status != 'READ' && m.userId != currentUserId)
        .length;
  }

  /// Get total unseen chats count for user
  int getTotalUnseenChatsCount(String currentUserId) {
    return getAllConversations()
        .where(
          (conv) =>
              conv.unseenCount > 0 && conv.lastMessageSenderId != currentUserId,
        )
        .length;
  }

  /// Search conversations by query
  List<ConversationModel> searchConversations(String query) {
    if (query.trim().isEmpty) return getAllConversations();

    final lowerQuery = query.toLowerCase();
    return getAllConversations().where((conv) {
      final groupName = conv.groupName?.toLowerCase() ?? '';
      final lastMessage = conv.lastMessageContent?.toLowerCase() ?? '';
      return groupName.contains(lowerQuery) || lastMessage.contains(lowerQuery);
    }).toList();
  }

  /// Search messages in a chat
  List<MessageModel> searchMessages(String chatId, String query) {
    if (query.trim().isEmpty) return getMessages(chatId);

    final lowerQuery = query.toLowerCase();
    return getMessages(chatId).where((msg) {
      final content = msg.content?.toLowerCase() ?? '';
      return content.contains(lowerQuery);
    }).toList();
  }

  // ==================== SYNC & MAINTENANCE ====================

  /// Merge server conversations with local (conflict resolution)
  Future<void> mergeConversations(
    List<ConversationModel> serverConversations,
  ) async {
    if (!isInitialized) await initialize();

    final localConversations = getAllConversations();
    final Map<String, ConversationModel> mergedMap = {};

    // Add all local conversations
    for (var local in localConversations) {
      mergedMap[local.id] = local;
    }

    // Merge with server (server wins on conflict)
    for (var server in serverConversations) {
      final local = mergedMap[server.id];

      if (local == null) {
        // New conversation from server
        mergedMap[server.id] = server;
      } else {
        // Keep the one with latest updatedAt
        if (server.updatedAt.isAfter(local.updatedAt)) {
          mergedMap[server.id] = server.copyWith(
            unseenCount: local.unseenCount, // Keep local unseen count
          );
        }
      }
    }

    await saveConversations(mergedMap.values.toList());
  }

  /// Clear all data (for logout)
  Future<void> clearAll() async {
    if (!isInitialized) await initialize();

    await _conversationsBox?.clear();
    await _messagesBox?.clear();
    await _tempMessagesBox?.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _conversationsBox?.close();
    await _messagesBox?.close();
    await _tempMessagesBox?.close();
  }

  /// Get box statistics (for debugging)
  Map<String, dynamic> getStats() {
    return {
      'conversations_count': _conversationsBox?.length ?? 0,
      'messages_boxes_count': _messagesBox?.length ?? 0,
      'temp_messages_count': _tempMessagesBox?.length ?? 0,
      'is_initialized': isInitialized,
    };
  }
}
