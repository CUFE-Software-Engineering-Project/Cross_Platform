import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_remote_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRemoteRepository chatRemoteRepository(Ref ref) {
  return ChatRemoteRepository(dio: Dio(BASE_OPTIONS));
}

class ChatRemoteRepository {
  final Dio _dio;

  ChatRemoteRepository({required Dio dio}) : _dio = dio;

  // Get chat information by chat ID
  // GET /api/dm/chat/{chatId}
  Future<Either<AppFailure, ConversationModel>> getChatById(
    String chatId,
  ) async {
    try {
      final response = await _dio.get('/api/dm/chat/$chatId');

      if (response.statusCode == 200) {
        final conversation = ConversationModel.fromApiResponse(response.data);
        return right(conversation);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to get chat'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Retrieve all chats for a user
  // GET /api/dm/chat/{userId}
  Future<Either<AppFailure, List<ConversationModel>>> getUserChats(
    String userId,
  ) async {
    try {
      final response = await _dio.get('/api/dm/chat/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> chatsData = response.data;
        final conversations = chatsData
            .map((chat) => ConversationModel.fromApiResponse(chat))
            .toList();
        return right(conversations);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to get chats'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Create a new chat
  // POST /api/dm/chat/{userId}/createchat
  Future<Either<AppFailure, ConversationModel>> createChat({
    required String userId,
    required bool isDMChat,
    required List<String> participantIds,
    String? groupName,
    String? groupPhoto,
    String? groupDescription,
  }) async {
    try {
      final requestData = {
        'DMChat': isDMChat,
        'participant_ids': participantIds,
      };
      if (!isDMChat) {
        if (groupName != null) requestData['name'] = groupName;
        if (groupPhoto != null) requestData['photo'] = groupPhoto;
        if (groupDescription != null) {
          requestData['description'] = groupDescription;
        }
      }

      final response = await _dio.post(
        '/api/dm/chat/$userId/createchat',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final conversation = ConversationModel.fromApiResponse(response.data);
        return right(conversation);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to create chat'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Delete a chat
  // DELETE /api/dm/chat/{chatId}
  Future<Either<AppFailure, String>> deleteChat(String chatId) async {
    try {
      final response = await _dio.delete('/api/dm/chat/$chatId');

      if (response.statusCode == 200) {
        return right(response.data['message'] ?? 'Chat deleted successfully');
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to delete chat'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Update group chat details
  // PUT /api/dm/chat/{chatId}/group
  Future<Either<AppFailure, ConversationModel>> updateGroupChat({
    required String chatId,
    String? name,
    String? description,
    String? photo,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      if (name != null) requestData['name'] = name;
      if (description != null) requestData['description'] = description;
      if (photo != null) requestData['photo'] = photo;

      final response = await _dio.put(
        '/api/dm/chat/$chatId/group',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final conversation = ConversationModel.fromApiResponse(response.data);
        return right(conversation);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to update group'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Send a message to a chat
  // POST /api/dm/chat/{userId}/message
  Future<Either<AppFailure, MessageModel>> sendMessage({
    required String userId,
    required String chatId,
    required List<String> recipientIds,
    String? content,
    List<Map<String, dynamic>>? mediaData,
  }) async {
    try {
      final requestData = {
        'chatId': chatId,
        'recipientId': recipientIds,
        'data': {
          'content': content,
          if (mediaData != null && mediaData.isNotEmpty)
            'messageMedia': mediaData,
        },
      };

      final response = await _dio.post(
        '/api/dm/chat/$userId/message',
        data: requestData,
      );

      if (response.statusCode == 201) {
        final message = MessageModel.fromApiResponse(response.data);
        return right(message);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to send message'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Update message status
  // PUT /api/dm/chat/{chatId}/messageStatus
  Future<Either<AppFailure, String>> updateMessageStatus({
    required String chatId,
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        '/api/dm/chat/$chatId/messageStatus',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return right(response.data['status'] ?? 'Status updated');
      }

      return left(
        AppFailure(
          message: response.data['error'] ?? 'Failed to update status',
        ),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // Get unseen messages count for a specific chat
  // GET /api/dm/chat/{chatId}/unseenMessagesCount
  Future<Either<AppFailure, int>> getUnseenMessagesCount(String chatId) async {
    try {
      final response = await _dio.get(
        '/api/dm/chat/$chatId/unseenMessagesCount',
      );

      if (response.statusCode == 200) {
        return right(response.data['unseenMessagesCount'] ?? 0);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to get count'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  /// Get unseen chats count for a user
  /// GET /api/dm/chat/{userId}/unseenChats
  Future<Either<AppFailure, int>> getUnseenChatsCount(String userId) async {
    try {
      final response = await _dio.get('/api/dm/chat/$userId/unseenChats');

      if (response.statusCode == 200) {
        return right(response.data['unseenChatsCount'] ?? 0);
      }

      return left(
        AppFailure(message: response.data['error'] ?? 'Failed to get count'),
      );
    } on DioException catch (e) {
      return left(
        AppFailure(
          message: e.response?.data['error'] ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  // added future
  Future<Either<AppFailure, MessageModel>> sendTextMessage({
    required String userId,
    required String chatId,
    required List<String> recipientIds,
    required String content,
  }) {
    return sendMessage(
      userId: userId,
      chatId: chatId,
      recipientIds: recipientIds,
      content: content,
    );
  }

  Future<Either<AppFailure, MessageModel>> sendMediaMessage({
    required String userId,
    required String chatId,
    required List<String> recipientIds,
    required List<Map<String, dynamic>> mediaData,
    String? content,
  }) {
    return sendMessage(
      userId: userId,
      chatId: chatId,
      recipientIds: recipientIds,
      content: content,
      mediaData: mediaData,
    );
  }
}
