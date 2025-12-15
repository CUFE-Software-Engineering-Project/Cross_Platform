import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/repository/media_repo_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'media_repo_impl_integration_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDio mockDio;
  late MediaRepoImpL repository;

  setUp(() {
    mockDio = MockDio();
    repository = MediaRepoImpL(mockDio);
  });

  group('MediaRepoImpL Integration - requestUpload', () {
    test('should complete full upload request flow', () async {
      // Arrange
      final responseData = {
        'url': 'https://s3.amazonaws.com/bucket/presigned-url',
        'keyName': 'uploads/test-file-123.jpg',
      };

      when(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': 'photo.jpg', 'contentType': 'image/jpeg'},
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Act
      final result = await repository.requestUpload('photo.jpg', 'image/jpeg');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (model) {
          expect(model.url, contains('s3.amazonaws.com'));
          expect(model.keyName, contains('uploads/'));
          expect(model, isA<RequestUploadModel>());
        },
      );

      verify(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': 'photo.jpg', 'contentType': 'image/jpeg'},
      )).called(1);
    });

    test('should handle server error response', () async {
      // Arrange
      when(mockDio.post(
        'api/media/upload-request',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {'error': 'Server error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Act
      final result = await repository.requestUpload('file.jpg', 'image/jpeg');

      // Assert - Should still parse response as RequestUploadModel
      expect(result.isRight(), true);
    });

    test('should handle network timeout', () async {
      // Arrange
      when(mockDio.post(
        'api/media/upload-request',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'api/media/upload-request'),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act
      final result = await repository.requestUpload('file.jpg', 'image/jpeg');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "can't request upload media"),
        (_) => fail('Should return failure'),
      );
    });

    test('should handle different media types', () async {
      // Arrange - Video upload
      final videoResponse = {
        'url': 'https://s3.amazonaws.com/bucket/video-url',
        'keyName': 'uploads/video-456.mp4',
      };

      when(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': 'video.mp4', 'contentType': 'video/mp4'},
      )).thenAnswer((_) async => Response(
            data: videoResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Act
      final result = await repository.requestUpload('video.mp4', 'video/mp4');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (model) {
          expect(model.keyName, contains('.mp4'));
        },
      );
    });
  });

  group('MediaRepoImpL Integration - confirmUpload', () {
    test('should complete full confirm upload flow', () async {
      // Arrange
      final keyName = 'uploads/test-file-123.jpg';
      final encodedKeyName = Uri.encodeComponent(keyName);
      final responseData = {
        'newMedia': {
          'id': 'media-abc-123',
          'name': 'test-file-123.jpg',
          'keyName': keyName,
          'type': 'image/jpeg',
          'size': 2048576,
        },
      };

      when(mockDio.post('api/media/confirm-upload/$encodedKeyName'))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  path: 'api/media/confirm-upload/$encodedKeyName',
                ),
              ));

      // Act
      final result = await repository.confirmUpload(keyName);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (model) {
          expect(model.id, 'media-abc-123');
          expect(model.name, 'test-file-123.jpg');
          expect(model.keyName, keyName);
          expect(model.type, 'image/jpeg');
          expect(model.size, 2048576);
          expect(model, isA<ConfirmUploadModel>());
        },
      );

      verify(mockDio.post('api/media/confirm-upload/$encodedKeyName')).called(1);
    });

    test('should handle keyName with special characters', () async {
      // Arrange
      final keyName = 'uploads/special #file @2024.jpg';
      final encodedKeyName = Uri.encodeComponent(keyName);
      final responseData = {
        'newMedia': {
          'id': 'media-special-456',
          'name': 'special #file @2024.jpg',
          'keyName': keyName,
          'type': 'image/jpeg',
          'size': 1024000,
        },
      };

      when(mockDio.post('api/media/confirm-upload/$encodedKeyName'))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  path: 'api/media/confirm-upload/$encodedKeyName',
                ),
              ));

      // Act
      final result = await repository.confirmUpload(keyName);

      // Assert
      expect(result.isRight(), true);
      verify(mockDio.post('api/media/confirm-upload/$encodedKeyName')).called(1);
    });

    test('should handle confirm with missing newMedia field', () async {
      // Arrange
      final responseData = <String, dynamic>{}; // Missing newMedia

      when(mockDio.post(any)).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/confirm-upload/test'),
          ));

      // Act
      final result = await repository.confirmUpload('uploads/test.jpg');

      // Assert - Should handle missing data gracefully
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (model) {
          expect(model.id, '');
          expect(model.name, '');
        },
      );
    });

    test('should handle server error on confirm', () async {
      // Arrange
      when(mockDio.post(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'api/media/confirm-upload/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: 'api/media/confirm-upload/test'),
        ),
      ));

      // Act
      final result = await repository.confirmUpload('uploads/test.jpg');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "can't confirm upload media"),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('MediaRepoImpL Integration - getMediaUrl', () {
    test('should retrieve media URL successfully', () async {
      // Arrange
      final mediaId = 'media-xyz-789';
      final responseData = {
        'url': 'https://cdn.example.com/media/media-xyz-789.jpg',
      };

      when(mockDio.get('api/media/download-request/$mediaId'))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  path: 'api/media/download-request/$mediaId',
                ),
              ));

      // Act
      final result = await repository.getMediaUrl(mediaId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (url) {
          expect(url, 'https://cdn.example.com/media/media-xyz-789.jpg');
          expect(url, contains('cdn.example.com'));
        },
      );

      verify(mockDio.get('api/media/download-request/$mediaId')).called(1);
    });

    test('should handle missing URL in response', () async {
      // Arrange
      final responseData = <String, dynamic>{}; // No url field

      when(mockDio.get(any)).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/download-request/test'),
          ));

      // Act
      final result = await repository.getMediaUrl('test');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (url) => expect(url, ''),
      );
    });

    test('should handle media not found error', () async {
      // Arrange
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'api/media/download-request/notfound'),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: 'api/media/download-request/notfound'),
          data: {'error': 'Media not found'},
        ),
      ));

      // Act
      final result = await repository.getMediaUrl('notfound');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "can't download media"),
        (_) => fail('Should return failure'),
      );
    });

    test('should handle multiple media ID requests', () async {
      // Arrange
      final ids = ['media1', 'media2', 'media3'];

      for (var id in ids) {
        when(mockDio.get('api/media/download-request/$id'))
            .thenAnswer((_) async => Response(
                  data: {'url': 'https://cdn.example.com/$id.jpg'},
                  statusCode: 200,
                  requestOptions: RequestOptions(
                    path: 'api/media/download-request/$id',
                  ),
                ));
      }

      // Act
      final results = await Future.wait(
        ids.map((id) => repository.getMediaUrl(id)),
      );

      // Assert
      expect(results.length, 3);
      for (var result in results) {
        expect(result.isRight(), true);
      }
    });
  });

  group('MediaRepoImpL Integration - Full Upload Flow', () {
    test('should complete entire upload workflow', () async {
      // Arrange
      final fileName = 'integration-test.jpg';
      final fileType = 'image/jpeg';

      // Step 1: Request upload
      final requestResponse = {
        'url': 'https://s3.amazonaws.com/bucket/presigned',
        'keyName': 'uploads/integration-test.jpg',
      };

      when(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': fileName, 'contentType': fileType},
      )).thenAnswer((_) async => Response(
            data: requestResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Step 2: Confirm upload
      final confirmResponse = {
        'newMedia': {
          'id': 'media-integration-123',
          'name': fileName,
          'keyName': 'uploads/integration-test.jpg',
          'type': fileType,
          'size': 1024000,
        },
      };

      final encodedKeyName =
          Uri.encodeComponent('uploads/integration-test.jpg');
      when(mockDio.post('api/media/confirm-upload/$encodedKeyName'))
          .thenAnswer((_) async => Response(
                data: confirmResponse,
                statusCode: 200,
                requestOptions: RequestOptions(
                  path: 'api/media/confirm-upload/$encodedKeyName',
                ),
              ));

      // Step 3: Get media URL
      when(mockDio.get('api/media/download-request/media-integration-123'))
          .thenAnswer((_) async => Response(
                data: {'url': 'https://cdn.example.com/integration-test.jpg'},
                statusCode: 200,
                requestOptions: RequestOptions(
                  path: 'api/media/download-request/media-integration-123',
                ),
              ));

      // Act - Execute full workflow
      final requestResult = await repository.requestUpload(fileName, fileType);
      expect(requestResult.isRight(), true);

      String keyName = '';
      requestResult.fold((_) {}, (model) => keyName = model.keyName);

      final confirmResult = await repository.confirmUpload(keyName);
      expect(confirmResult.isRight(), true);

      String mediaId = '';
      confirmResult.fold((_) {}, (model) => mediaId = model.id);

      final urlResult = await repository.getMediaUrl(mediaId);
      expect(urlResult.isRight(), true);

      String finalUrl = '';
      urlResult.fold((_) {}, (url) => finalUrl = url);

      // Assert - Verify complete flow
      expect(finalUrl, contains('cdn.example.com'));
      expect(finalUrl, contains('integration-test.jpg'));

      // Verify all API calls were made
      verify(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': fileName, 'contentType': fileType},
      )).called(1);
      verify(mockDio.post('api/media/confirm-upload/$encodedKeyName')).called(1);
      verify(mockDio.get('api/media/download-request/media-integration-123'))
          .called(1);
    });

    test('should handle failure at each step of upload flow', () async {
      // Test failure at request upload
      when(mockDio.post(
        'api/media/upload-request',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'api/media/upload-request'),
      ));

      final requestResult =
          await repository.requestUpload('fail.jpg', 'image/jpeg');
      expect(requestResult.isLeft(), true);

      // Test failure at confirm upload
      when(mockDio.post(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'api/media/confirm-upload/test'),
      ));

      final confirmResult = await repository.confirmUpload('uploads/fail.jpg');
      expect(confirmResult.isLeft(), true);

      // Test failure at get media URL
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: 'api/media/download-request/fail'),
      ));

      final urlResult = await repository.getMediaUrl('fail');
      expect(urlResult.isLeft(), true);
    });
  });

  group('MediaRepoImpL Integration - Edge Cases', () {
    test('should handle very long file names', () async {
      // Arrange
      final longFileName = 'a' * 255 + '.jpg';
      final responseData = {
        'url': 'https://s3.amazonaws.com/bucket/url',
        'keyName': 'uploads/$longFileName',
      };

      when(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': longFileName, 'contentType': 'image/jpeg'},
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Act
      final result = await repository.requestUpload(longFileName, 'image/jpeg');

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle unicode file names', () async {
      // Arrange
      final unicodeFileName = 'テスト画像🖼️.jpg';
      final responseData = {
        'url': 'https://s3.amazonaws.com/bucket/url',
        'keyName': 'uploads/$unicodeFileName',
      };

      when(mockDio.post(
        'api/media/upload-request',
        data: {'fileName': unicodeFileName, 'contentType': 'image/jpeg'},
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Act
      final result =
          await repository.requestUpload(unicodeFileName, 'image/jpeg');

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle empty response data', () async {
      // Arrange
      when(mockDio.post(any)).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/upload-request'),
          ));

      // Act
      final result = await repository.requestUpload('test.jpg', 'image/jpeg');

      // Assert - Should return Left on null data
      expect(result.isLeft(), true);
    });

    test('should handle large file sizes in confirm', () async {
      // Arrange
      final responseData = {
        'newMedia': {
          'id': 'large-media',
          'name': 'large-file.mp4',
          'keyName': 'uploads/large-file.mp4',
          'type': 'video/mp4',
          'size': 5368709120, // 5GB
        },
      };

      when(mockDio.post(any)).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'api/media/confirm-upload/test'),
          ));

      // Act
      final result = await repository.confirmUpload('uploads/large-file.mp4');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (model) => expect(model.size, 5368709120),
      );
    });
  });
}
