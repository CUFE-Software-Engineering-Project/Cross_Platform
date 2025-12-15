import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/repository/media_repo_impl.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'media_repo_impl_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late MediaRepoImpL mediaRepo;

  setUp(() {
    mockDio = MockDio();
    mediaRepo = MediaRepoImpL(mockDio);
  });

  group('MediaRepoImpL', () {
    group('requestUpload', () {
      test('should return RequestUploadModel on successful upload request', () async {
        // Arrange
        final responseData = {
          'url': 'https://s3.amazonaws.com/presigned-url',
          'keyName': 'uploads/file123.jpg',
        };

        when(mockDio.post(
          'api/media/upload-request',
          data: {'fileName': 'test.jpg', 'contentType': 'image/jpeg'},
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: 'api/media/upload-request'),
            ));

        // Act
        final result = await mediaRepo.requestUpload('test.jpg', 'image/jpeg');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (model) {
            expect(model.url, 'https://s3.amazonaws.com/presigned-url');
            expect(model.keyName, 'uploads/file123.jpg');
          },
        );

        verify(mockDio.post(
          'api/media/upload-request',
          data: {'fileName': 'test.jpg', 'contentType': 'image/jpeg'},
        )).called(1);
      });

      test('should return Failure when request fails', () async {
        // Arrange
        when(mockDio.post(
          'api/media/upload-request',
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: 'api/media/upload-request'),
          error: 'Network error',
        ));

        // Act
        final result = await mediaRepo.requestUpload('test.jpg', 'image/jpeg');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "can't request upload media");
          },
          (model) => fail('Should not return success'),
        );
      });

      test('should return Failure on general exception', () async {
        // Arrange
        when(mockDio.post(
          'api/media/upload-request',
          data: anyNamed('data'),
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await mediaRepo.requestUpload('video.mp4', 'video/mp4');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, "can't request upload media"),
          (_) => fail('Should not return success'),
        );
      });

      test('should handle different file types', () async {
        // Arrange
        final responseData = {
          'url': 'https://s3.amazonaws.com/presigned-url',
          'keyName': 'uploads/video.mp4',
        };

        when(mockDio.post(
          'api/media/upload-request',
          data: {'fileName': 'video.mp4', 'contentType': 'video/mp4'},
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: 'api/media/upload-request'),
            ));

        // Act
        final result = await mediaRepo.requestUpload('video.mp4', 'video/mp4');

        // Assert
        expect(result.isRight(), true);
      });
    });

    group('confirmUpload', () {
      test('should return ConfirmUploadModel on successful confirmation', () async {
        // Arrange
        final responseData = {
          'newMedia': {
            'id': 'media123',
            'name': 'test.jpg',
            'keyName': 'uploads/test.jpg',
            'type': 'image/jpeg',
            'size': 1024000,
          },
        };

        when(mockDio.post('api/media/confirm-upload/uploads%2Ftest.jpg'))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/media/confirm-upload/uploads%2Ftest.jpg'),
                ));

        // Act
        final result = await mediaRepo.confirmUpload('uploads/test.jpg');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (model) {
            expect(model.id, 'media123');
            expect(model.name, 'test.jpg');
            expect(model.keyName, 'uploads/test.jpg');
            expect(model.type, 'image/jpeg');
            expect(model.size, 1024000);
          },
        );
      });

      test('should URL encode keyName in request', () async {
        // Arrange
        final keyName = 'uploads/special key#with@chars.jpg';
        final encodedKeyName = Uri.encodeComponent(keyName);

        final responseData = {
          'newMedia': {
            'id': 'media456',
            'name': 'special.jpg',
            'keyName': keyName,
            'type': 'image/jpeg',
            'size': 500000,
          },
        };

        when(mockDio.post('api/media/confirm-upload/$encodedKeyName'))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/media/confirm-upload/$encodedKeyName'),
                ));

        // Act
        final result = await mediaRepo.confirmUpload(keyName);

        // Assert
        expect(result.isRight(), true);
        verify(mockDio.post('api/media/confirm-upload/$encodedKeyName')).called(1);
      });

      test('should return Failure when confirmation fails', () async {
        // Arrange
        when(mockDio.post(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: 'api/media/confirm-upload/test'),
          error: 'Server error',
        ));

        // Act
        final result = await mediaRepo.confirmUpload('uploads/test.jpg');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "can't confirm upload media");
          },
          (model) => fail('Should not return success'),
        );
      });

      test('should return Failure on general exception', () async {
        // Arrange
        when(mockDio.post(any)).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await mediaRepo.confirmUpload('key');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, "can't confirm upload media"),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('upload', () {
      test('should successfully upload file with mocked Dio', () async {
        // Arrange
        final file = File('test_upload_success.jpg');
        await file.writeAsBytes([1, 2, 3, 4, 5]);

        final mockDioForUpload = MockDio();
        when(mockDioForUpload.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        )).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: 'https://s3.amazonaws.com/test'),
            ));

        // Act
        final result = await mediaRepo.upload('https://s3.amazonaws.com/test', file, dio: mockDioForUpload);

        // Assert
        expect(result.isRight(), true);
        await file.delete();
      });

      test('should successfully upload file with 201 status code', () async {
        // Arrange
        final file = File('test_upload_201.jpg');
        await file.writeAsBytes([1, 2, 3, 4, 5]);

        final mockDioForUpload = MockDio();
        when(mockDioForUpload.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        )).thenAnswer((_) async => Response(
              statusCode: 201,
              requestOptions: RequestOptions(path: 'https://s3.amazonaws.com/test'),
            ));

        // Act
        final result = await mediaRepo.upload('https://s3.amazonaws.com/test', file, dio: mockDioForUpload);

        // Assert
        expect(result.isRight(), true);
        await file.delete();
      });

      test('should return Failure on non-200/201 status code', () async {
        // Arrange
        final file = File('test_upload_fail_status.jpg');
        await file.writeAsBytes([1, 2, 3, 4, 5]);

        final mockDioForUpload = MockDio();
        when(mockDioForUpload.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        )).thenAnswer((_) async => Response(
              statusCode: 403,
              requestOptions: RequestOptions(path: 'https://s3.amazonaws.com/test'),
            ));

        // Act
        final result = await mediaRepo.upload('https://s3.amazonaws.com/test', file, dio: mockDioForUpload);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, "can't upload media"),
          (_) => fail('Should not return success'),
        );
        await file.delete();
      });

      test('should return Failure on upload exception with nonexistent file', () async {
        // Arrange
        final file = File('nonexistent_file_that_does_not_exist.jpg');

        // Act
        final result = await mediaRepo.upload('https://invalid-url', file);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, "can't upload media"),
          (_) => fail('Should not return success'),
        );
      });

      test('should return Failure with invalid upload URL', () async {
        // Arrange
        final file = File('temp_test.jpg');
        await file.writeAsBytes([1, 2, 3]);

        // Act
        final result = await mediaRepo.upload('not-a-valid-url', file);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, "can't upload media"),
          (_) => fail('Should not return success'),
        );

        // Cleanup
        await file.delete();
      });

      test('should handle file read operations for content type detection', () async {
        // Arrange
        final file = File('test.png');
        await file.writeAsBytes([137, 80, 78, 71, 13, 10, 26, 10]); // PNG header

        // Act
        final result = await mediaRepo.upload('https://httpstat.us/500', file);

        // Assert - Will fail but covers the code path
        expect(result.isLeft(), true);

        // Cleanup
        await file.delete();
      });
    });

    group('getMediaUrl', () {
      test('should return media URL on success', () async {
        // Arrange
        final responseData = {
          'url': 'https://cdn.example.com/media/12345.jpg',
        };

        when(mockDio.get('api/media/download-request/12345'))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/media/download-request/12345'),
                ));

        // Act
        final result = await mediaRepo.getMediaUrl('12345');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (url) {
            expect(url, 'https://cdn.example.com/media/12345.jpg');
          },
        );

        verify(mockDio.get('api/media/download-request/12345')).called(1);
      });

      test('should return empty string when url is missing', () async {
        // Arrange
        final responseData = <String, dynamic>{};

        when(mockDio.get('api/media/download-request/123'))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/media/download-request/123'),
                ));

        // Act
        final result = await mediaRepo.getMediaUrl('123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (url) => expect(url, ''),
        );
      });

      test('should return empty string when url is null', () async {
        // Arrange
        final responseData = {'url': null};

        when(mockDio.get('api/media/download-request/456'))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/media/download-request/456'),
                ));

        // Act
        final result = await mediaRepo.getMediaUrl('456');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (url) => expect(url, ''),
        );
      });

      test('should return Failure when request fails', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: 'api/media/download-request/123'),
          error: 'Not found',
        ));

        // Act
        final result = await mediaRepo.getMediaUrl('123');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, "can't download media");
          },
          (url) => fail('Should not return success'),
        );
      });

      test('should return Failure on general exception', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await mediaRepo.getMediaUrl('789');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, "can't download media"),
          (_) => fail('Should not return success'),
        );
      });

      test('should handle different media IDs', () async {
        // Arrange
        final responseData = {'url': 'https://example.com/video.mp4'};

        when(mockDio.get('api/media/download-request/video_123'))
            .thenAnswer((_) async => Response(
                  data: responseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: 'api/media/download-request/video_123'),
                ));

        // Act
        final result = await mediaRepo.getMediaUrl('video_123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (url) => expect(url, 'https://example.com/video.mp4'),
        );
      });
    });
  });
}
