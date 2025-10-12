import 'package:lite_x/core/constants/server_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository(dio: Dio(BASE_OPTIONS));
}

class AuthRemoteRepository {
  // ignore: unused_field
  final Dio _dio;
  AuthRemoteRepository({required Dio dio}) : _dio = dio;
  // end points
}
