import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String API_URL = dotenv.env["API_URL"]!;
final BASE_OPTIONS = BaseOptions(
  baseUrl: API_URL,
  contentType: 'application/json',
  sendTimeout: const Duration(seconds: 3),
  receiveTimeout: const Duration(seconds: 3),

  connectTimeout: const Duration(seconds: 3),
);
