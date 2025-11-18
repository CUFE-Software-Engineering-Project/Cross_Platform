// ignore_for_file: unused_local_variable, unused_import

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lite_x/core/classes/AppFailure.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/chat/models/conversationmodel.dart';
import 'package:lite_x/features/chat/models/messagemodel.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
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
}
