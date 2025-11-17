// ignore_for_file: unused_import, unused_field

import 'package:dio/dio.dart';
import 'package:lite_x/core/constants/server_constants.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
part 'socket_repository.g.dart';

@Riverpod(keepAlive: true)
SocketRepository socketRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return SocketRepository(dio: dio);
}

class SocketRepository {
  final Dio _dio;
  SocketRepository({required Dio dio}) : _dio = dio;
}
