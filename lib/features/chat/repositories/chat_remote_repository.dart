// ignore_for_file: unused_local_variable, unused_import, unused_catch_clause

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_remote_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRemoteRepository chatRemoteRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ChatRemoteRepository(dio: dio);
}

class ChatRemoteRepository {
  final Dio _dio;
  ChatRemoteRepository({required Dio dio}) : _dio = dio;
  //--------------------------------------------------search users to choose to chat with him or them according to group or not ----------------------------------------//
  Future<Either<AppFailure, List<UserSearchModel>>> searchUsers(
    String query,
  ) async {
    try {
      final response = await _dio.get(
        "api/users/search",
        queryParameters: {"query": query},
      );

      final data = response.data as Map<String, dynamic>;

      final List<dynamic> list = data["users"] ?? [];

      final users = list
          .map((e) => UserSearchModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(users);
    } on DioException catch (e) {
      print("DIO RESPONSE DATA: ${e.response?.data}");
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to search users";

      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      print("GENERAL ERROR: ${e.toString()}");
      return Left(AppFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------create chat ---------------------------------------------------------------------//
  Future<Either<AppFailure, ConversationModel>> create_chat({
    required List<String> recipientIds,
    required String Current_UserId,
    required bool DMChat,
  }) async {
    try {
      final response = await _dio.post(
        "api/dm/chat/create-chat",
        data: {"participant_ids": recipientIds, "DMChat": DMChat},
      );
      final data = response.data["newChat"] as Map<String, dynamic>;
      print("RESPONSE => ${response.data}");

      final conversation = ConversationModel.fromApiResponse(
        data,
        Current_UserId,
      );

      return Right(conversation);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to create chat";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------get inital messages from getchatinfo without timestemp-------------------------------//

  Future<Either<AppFailure, List<MessageModel>>> getInitialChatMessages(
    String chatId,
  ) async {
    try {
      print(chatId);
      final response = await _dio.get("api/dm/chat/$chatId");
      final data = response.data as Map<String, dynamic>;

      final List<dynamic> messagesList = data['messages'] ?? [];

      final messages = messagesList
          .map((msg) => MessageModel.fromApiResponse(msg))
          .toList();

      return Right(messages);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to get initial messages";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------get user chats-----------------------------------------------------------------//
  Future<Either<AppFailure, List<ConversationModel>>> getuserchats(
    String Current_UserId,
  ) async {
    try {
      final response = await _dio.get("api/dm/chat/user");

      final List<dynamic> chatsList = response.data as List<dynamic>;
      final conversations = chatsList
          .map(
            (chat) => ConversationModel.fromApiResponse(
              chat as Map<String, dynamic>,
              Current_UserId,
            ),
          )
          .toList();

      return Right(conversations);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to get user chats";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //---------------------------------------------------------------------------//
  //-----------------------------------------------------------get messages of the conversation-------------------------------------------------------------------------//
  Future<Either<AppFailure, List<MessageModel>>> getMessagesChat(
    String chatId, {
    required DateTime lastMessageTimestamp,
  }) async {
    try {
      final response = await _dio.get(
        "api/dm/chat/$chatId/messages",
        queryParameters: {
          "lastMessageTimestamp": lastMessageTimestamp.toIso8601String(),
        },
      );

      final List<dynamic> messagesList = response.data as List<dynamic>;

      final messages = messagesList
          .map(
            (msg) => MessageModel.fromApiResponse(msg as Map<String, dynamic>),
          )
          .toList();

      return Right(messages);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to get messages";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------get unseen count of one chat------------------------------------------------------------------------//
  Future<Either<AppFailure, int>> getUnseenCountOfChat(String chatId) async {
    try {
      final response = await _dio.get(
        "api/dm/chat/$chatId/unseen-messages-count",
      );

      final data = response.data as Map<String, dynamic>;
      final unseenCount = data["unseenMessagesCount"] as int? ?? 0;

      return Right(unseenCount);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to get unseen count";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //-----------------------------------------------------------------get unseen count of all messages of all chats --------------------------------------------------------------------------//
  Future<Either<AppFailure, int>> getUnseenCountAllChats() async {
    try {
      final response = await _dio.get("api/dm/chat/all-unseen-messages-count");

      final data = response.data as Map<String, dynamic>;
      final totalUnseenCount = data["totalUnseenMessages"] as int? ?? 0;

      return Right(totalUnseenCount);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to get all unseen count";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //--------------------------------------------------------------get chat info --------------------------------------------------------------------------//
  Future<Either<AppFailure, ConversationModel>> getChatInfo(
    String chatId,
    String currentUserId,
  ) async {
    try {
      final response = await _dio.get("api/dm/chat/$chatId");

      final data = response.data as Map<String, dynamic>;
      final conversation = ConversationModel.fromApiResponse(
        data,
        currentUserId,
      );

      return Right(conversation);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to get chat info";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //------------------------------------------------------------------delete chat from conversions---------------------------------------------------------------------------//
  Future<Either<AppFailure, bool>> deleteChat(String chatId) async {
    try {
      final response = await _dio.delete("api/dm/chat/$chatId");

      final data = response.data as Map<String, dynamic>;
      final success = data["success"] as bool? ?? true;

      return Right(success);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to delete chat";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }

  //---------------------------------------------------------------------media of message ---------------------------------------------------------------------------------//
  Future<Either<AppFailure, Map<String, dynamic>>> upload_Media_Message({
    required File file,
    required String fileType,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final requestResponse = await _dio.post(
        'api/media/upload-request',
        data: {'fileName': fileName, 'contentType': fileType},
      );

      final String presignedUrl = requestResponse.data['url'];
      final String keyName = requestResponse.data['keyName'];
      final fileBytes = await file.readAsBytes();

      final newDio = Dio(
        BaseOptions(
          headers: {
            'Content-Type': fileType,
            'Content-Length': fileBytes.length,
          },
        ),
      );

      await newDio.put(presignedUrl, data: Stream.fromIterable([fileBytes]));

      final confirmResponse = await _dio.post(
        'api/media/confirm-upload/$keyName',
      );

      final mediaId = confirmResponse.data['newMedia']['id'].toString();

      final newMediaKey = confirmResponse.data['newMedia']['keyName'] as String;
      print("MEDIA ID AFTER UPLOAD: $mediaId");

      return right({'mediaId': mediaId, 'keyName': newMediaKey});
    } on DioException catch (e) {
      return left(AppFailure(message: 'Upload failed'));
    } catch (e) {
      return left(AppFailure(message: e.toString()));
    }
  }

  //------------------------------------------------------------------download the media------------------------------------------------------------------------------//
  Future<Either<AppFailure, File>> downloadMedia({
    required String mediaId,
  }) async {
    try {
      final response = await _dio.get('api/media/download-request/$mediaId');
      final String downloadUrl = response.data['url'];

      final newDio = Dio();
      final imageResponse = await newDio.get(
        downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/downloaded_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final file = File(filePath);
      await file.writeAsBytes(imageResponse.data);

      return right(file);
    } catch (e) {
      return left(AppFailure(message: 'Download failed $e'));
    }
  }

  //---------------------------------------------------------------update group info -------------------------------------------------------------------------------------//
  Future<Either<AppFailure, ConversationModel>> updateGroupInfo({
    required String chatId,
    required String currentUserId,
    String? groupName,
    String? groupDescription,
    String? groupPhotoKey,
  }) async {
    try {
      final response = await _dio.put(
        "api/dm/chat/$chatId/group",
        data: {
          if (groupName != null) "name": groupName,
          if (groupDescription != null) "description": groupDescription,
          if (groupPhotoKey != null) "photo": groupPhotoKey,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final updatedConversation = ConversationModel.fromApiResponse(
        data,
        currentUserId,
      );

      return Right(updatedConversation);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data["message"] ??
          e.response?.data["error"] ??
          "Failed to update group info";
      return Left(AppFailure(message: errorMessage));
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}
