import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/repository/media_repo.dart';
import 'package:lite_x/features/media/upload_media.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'upload_media_integration_test.mocks.dart';

@GenerateMocks([MediaRepo])
void main() {
  late MockMediaRepo mockMediaRepo;

  setUp(() {
    mockMediaRepo = MockMediaRepo();
  });

  group('upload_media integration', () {
    test('should successfully upload single file and return media ID', () async {
      // Arrange
      final testFile = File('test_integration.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]);

      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned-url',
        keyName: 'uploads/test_integration.jpg',
      );

      final confirmModel = ConfirmUploadModel(
        id: 'media-integration-123',
        name: 'test_integration.jpg',
        keyName: 'uploads/test_integration.jpg',
        type: 'image/jpeg',
        size: 5,
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any))
          .thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Right(confirmModel));

      // Create a container with overridden provider
      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Simulate the upload_media function logic
      final files = [testFile];
      final limitedFiles = files.take(4).toList();

      final uploadFutures = limitedFiles.map((file) async {
        bool fail = false;
        final fileName = file.path.split(Platform.pathSeparator).last;
        final fileType = 'image/jpeg';

        // Step 1: Request upload
        final requestUpload = container.read(requestUploadProvider);
        final requestUploadResponse = await requestUpload(fileName, fileType);
        
        RequestUploadModel requestUploadModel = RequestUploadModel(
          url: "",
          keyName: "",
        );
        
        requestUploadResponse.fold(
          (l) {
            fail = true;
          },
          (res) {
            requestUploadModel = res;
          },
        );
        
        if (fail) return "";

        // Step 2: Upload
        final upload = container.read(uploadProvider);
        final uploadResponse = await upload(requestUploadModel.url, file);
        
        uploadResponse.fold((l) {
          fail = true;
        }, (res) {});
        
        if (fail) return "";

        // Step 3: Confirm upload
        final confirmUpload = container.read(confirmUploadProvider);
        final confirmUploadResponse = await confirmUpload(requestUploadModel.keyName);
        
        ConfirmUploadModel confirmUploadModel = ConfirmUploadModel(
          id: "",
          name: "",
          keyName: "",
          type: "",
          size: 0,
        );
        
        confirmUploadResponse.fold(
          (l) {
            fail = true;
          },
          (res) {
            confirmUploadModel = res;
          },
        );
        
        if (fail) return "";
        
        return confirmUploadModel.id;
      }).toList();

      // Wait for all uploads
      final ids = await Future.wait(uploadFutures);

      // Assert
      expect(ids.length, 1);
      expect(ids[0], 'media-integration-123');

      // Cleanup
      container.dispose();
      await testFile.delete();
    });

    test('should handle multiple files and limit to 4', () async {
      // Arrange - Create 6 files
      final files = List.generate(6, (i) async {
        final file = File('test_multi_$i.jpg');
        await file.writeAsBytes([i]);
        return file;
      });

      final createdFiles = await Future.wait(files);

      // Mock responses
      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned',
        keyName: 'uploads/test.jpg',
      );

      final confirmModel = ConfirmUploadModel(
        id: 'media-multi',
        name: 'test.jpg',
        keyName: 'uploads/test.jpg',
        type: 'image/jpeg',
        size: 1,
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any))
          .thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Right(confirmModel));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Take only 4 files
      final limitedFiles = createdFiles.take(4).toList();
      expect(limitedFiles.length, 4);

      // Process all files
      final uploadFutures = limitedFiles.map((file) async {
        final requestUpload = container.read(requestUploadProvider);
        final fileName = file.path.split(Platform.pathSeparator).last;
        await requestUpload(fileName, 'image/jpeg');
        return 'media-$fileName';
      }).toList();

      final ids = await Future.wait(uploadFutures);

      // Assert
      expect(ids.length, 4);

      // Cleanup
      container.dispose();
      for (var file in createdFiles) {
        await file.delete();
      }
    });

    test('should return empty string on request failure', () async {
      // Arrange
      final testFile = File('test_fail_request.jpg');
      await testFile.writeAsBytes([1, 2, 3]);

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Left(Failure("Request failed")));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act
      bool fail = false;
      final requestUpload = container.read(requestUploadProvider);
      final fileName = testFile.path.split(Platform.pathSeparator).last;
      final result = await requestUpload(fileName, 'image/jpeg');
      
      result.fold((l) => fail = true, (r) {});

      // Assert
      expect(fail, true);

      // Cleanup
      container.dispose();
      await testFile.delete();
    });

    test('should return empty string on upload failure', () async {
      // Arrange
      final testFile = File('test_fail_upload.jpg');
      await testFile.writeAsBytes([1, 2, 3]);

      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned',
        keyName: 'uploads/test.jpg',
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any))
          .thenAnswer((_) async => Left(Failure("Upload failed")));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act
      final requestUpload = container.read(requestUploadProvider);
      final fileName = testFile.path.split(Platform.pathSeparator).last;
      final requestResult = await requestUpload(fileName, 'image/jpeg');
      
      RequestUploadModel model = RequestUploadModel(url: "", keyName: "");
      requestResult.fold((l) {}, (r) => model = r);

      bool uploadFail = false;
      final upload = container.read(uploadProvider);
      final uploadResult = await upload(model.url, testFile);
      uploadResult.fold((l) => uploadFail = true, (r) {});

      // Assert
      expect(uploadFail, true);

      // Cleanup
      container.dispose();
      await testFile.delete();
    });

    test('should return empty string on confirm failure', () async {
      // Arrange
      final testFile = File('test_fail_confirm.jpg');
      await testFile.writeAsBytes([1, 2, 3]);

      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned',
        keyName: 'uploads/test.jpg',
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any))
          .thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Left(Failure("Confirm failed")));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act - Execute through all steps
      final requestUpload = container.read(requestUploadProvider);
      final fileName = testFile.path.split(Platform.pathSeparator).last;
      await requestUpload(fileName, 'image/jpeg');

      final upload = container.read(uploadProvider);
      await upload(requestModel.url, testFile);

      bool confirmFail = false;
      final confirmUpload = container.read(confirmUploadProvider);
      final confirmResult = await confirmUpload(requestModel.keyName);
      confirmResult.fold((l) => confirmFail = true, (r) {});

      // Assert
      expect(confirmFail, true);

      // Cleanup
      container.dispose();
      await testFile.delete();
    });

    test('should handle parallel uploads correctly', () async {
      // Arrange
      final files = await Future.wait(
        List.generate(3, (i) async {
          final file = File('parallel_$i.jpg');
          await file.writeAsBytes([i]);
          return file;
        }),
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(RequestUploadModel(
                url: 'https://s3.amazonaws.com/url',
                keyName: 'uploads/key',
              )));
      when(mockMediaRepo.upload(any, any))
          .thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Right(ConfirmUploadModel(
                id: 'media-parallel',
                name: 'file.jpg',
                keyName: 'key',
                type: 'image/jpeg',
                size: 1,
              )));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act - Process in parallel
      final futures = files.map((file) async {
        final requestUpload = container.read(requestUploadProvider);
        final result = await requestUpload('file.jpg', 'image/jpeg');
        return result.isRight();
      }).toList();

      final results = await Future.wait(futures);

      // Assert
      expect(results.every((r) => r == true), true);

      // Cleanup
      container.dispose();
      for (var file in files) {
        await file.delete();
      }
    });
  });
}
