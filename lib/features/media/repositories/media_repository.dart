import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/constants/server_constants.dart';

/// Repository responsible for uploading and retrieving media related to tweets.
class MediaRepository {
  final Dio _dio;

  MediaRepository({required Dio dio}) : _dio = dio;

  /// Attach media (file at [filePath]) to a tweet identified by [tweetId].
  ///
  /// Returns the backend response (parsed JSON) on success.
  /// Attach media to a tweet. Provide the raw [fileBytes] and a [filename].
  /// This is web-compatible because it doesn't rely on `dart:io`.
  Future<Map<String, dynamic>> attachMediaToTweet({
    required String tweetId,
    required Uint8List fileBytes,
    required String filename,
  }) async {
    try {
      final multipart = MultipartFile.fromBytes(fileBytes, filename: filename);
      final form = FormData.fromMap({'file': multipart});

      final resp = await _dio.post('/tweets/$tweetId/media', data: form);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return Map<String, dynamic>.from(resp.data as Map);
      }
      throw Exception('Failed to attach media: ${resp.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }

  /// Retrieve list of media objects attached to a tweet.
  /// Returns a List of maps representing media metadata (url, id, etc.).
  Future<List<Map<String, dynamic>>> getMediaForTweet({required String tweetId}) async {
    try {
      final resp = await _dio.get('/tweets/$tweetId/media');
      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        // If backend returns an object with a `media` field
        if (data is Map && data['media'] is List) {
          return (data['media'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
        return [];
      }
      throw Exception('Failed to fetch media: ${resp.statusCode}');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }
}

/// Convenience provider that creates a MediaRepository using the project's
/// BASE_OPTIONS. Use `ref.read(mediaRepositoryProvider)` to get an instance.
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final dio = Dio(BASE_OPTIONS);
  // lightweight logging for development
  dio.interceptors.add(LogInterceptor(request: true, requestBody: true, responseBody: true));
  return MediaRepository(dio: dio);
});
