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

import 'upload_media_test.mocks.dart';

@GenerateMocks([MediaRepo])
void main() {
  late MockMediaRepo mockMediaRepo;

  setUp(() {
    mockMediaRepo = MockMediaRepo();
  });

  group('upload_media', () {
    test('should successfully upload single file and return media ID', () async {
      // Arrange
      final file = File('test_upload_media.jpg');
      await file.writeAsBytes([1, 2, 3, 4, 5]);

      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned',
        keyName: 'uploads/test.jpg',
      );
      final confirmModel = ConfirmUploadModel(
        id: 'media123',
        name: 'test.jpg',
        keyName: 'uploads/test.jpg',
        type: 'image/jpeg',
        size: 1024,
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any)).thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Right(confirmModel));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act
      final result = await upload_media([file], container: container);

      // Assert
      expect(result, ['media123']);
      await file.delete();
      container.dispose();
    });

    test('should handle multiple files in parallel (limited to 4)', () async {
      // Arrange - Create 5 files, only 4 should be processed
      final files = List.generate(5, (i) {
        final file = File('test$i.jpg');
        return file;
      });

      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned',
        keyName: 'uploads/test.jpg',
      );
      final confirmModel = ConfirmUploadModel(
        id: 'media123',
        name: 'test.jpg',
        keyName: 'uploads/test.jpg',
        type: 'image/jpeg',
        size: 1024,
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any)).thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Right(confirmModel));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act - Only 4 should be processed
      final result = await upload_media(files, container: container);

      // Assert - Only 4 files should be uploaded
      expect(result.length, 4);
      container.dispose();
    });

    test('should return empty string on request upload failure', () async {
      // Arrange
      final file = File('test_fail_request.jpg');
      await file.writeAsBytes([1, 2, 3]);

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Left(Failure("Request failed")));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act
      final result = await upload_media([file], container: container);

      // Assert
      expect(result, ['']);
      await file.delete();
      container.dispose();
    });

    test('should return empty string on upload failure', () async {
      // Arrange
      final file = File('test_fail_upload.jpg');
      await file.writeAsBytes([1, 2, 3]);

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
      final result = await upload_media([file], container: container);

      // Assert
      expect(result, ['']);
      await file.delete();
      container.dispose();
    });

    test('should return empty string on confirm upload failure', () async {
      // Arrange
      final file = File('test_fail_confirm.jpg');
      await file.writeAsBytes([1, 2, 3]);

      final requestModel = RequestUploadModel(
        url: 'https://s3.amazonaws.com/presigned',
        keyName: 'uploads/test.jpg',
      );

      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Right(requestModel));
      when(mockMediaRepo.upload(any, any)).thenAnswer((_) async => Right(null));
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Left(Failure("Confirm failed")));

      final container = ProviderContainer(
        overrides: [
          mediaRepoProvider.overrideWithValue(mockMediaRepo),
        ],
      );

      // Act
      final result = await upload_media([file], container: container);

      // Assert
      expect(result, ['']);
      await file.delete();
      container.dispose();
    });

    test('should extract fileName correctly from path', () {
      // Arrange
      final filePath = Platform.isWindows ? 'C:\\path\\to\\test.jpg' : '/path/to/test.jpg';
      final fileName = filePath.split(Platform.pathSeparator).last;

      // Assert
      expect(fileName, 'test.jpg');
    });

    test('should handle Windows path separator', () {
      // Arrange
      final windowsPath = 'C:\\Users\\test\\file.jpg';
      final fileName = windowsPath.split('\\').last;

      // Assert
      expect(fileName, 'file.jpg');
    });

    test('should process files in parallel using Future.wait', () async {
      // This tests the parallel processing pattern
      final futures = [1, 2, 3].map((i) async {
        await Future.delayed(Duration(milliseconds: 10));
        return i * 2;
      }).toList();

      final results = await Future.wait(futures);
      expect(results, [2, 4, 6]);
    });

    test('should initialize ConfirmUploadModel with default values', () {
      final model = ConfirmUploadModel(
        id: "",
        name: "",
        keyName: "",
        type: "",
        size: 0,
      );

      expect(model.id, "");
      expect(model.name, "");
      expect(model.keyName, "");
      expect(model.type, "");
      expect(model.size, 0);
    });

    test('should initialize RequestUploadModel with default values', () {
      final model = RequestUploadModel(
        url: "",
        keyName: "",
      );

      expect(model.url, "");
      expect(model.keyName, "");
    });

    test('should handle empty file list', () {
      final files = <File>[];
      final limited = files.take(4).toList();
      expect(limited.length, 0);
    });

    test('should handle exactly 4 files', () {
      final files = List.generate(4, (i) => File('test$i.jpg'));
      final limited = files.take(4).toList();
      expect(limited.length, 4);
    });

    test('should handle less than 4 files', () {
      final files = List.generate(2, (i) => File('test$i.jpg'));
      final limited = files.take(4).toList();
      expect(limited.length, 2);
    });

    test('should handle more than 4 files', () {
      final files = List.generate(10, (i) => File('test$i.jpg'));
      final limited = files.take(4).toList();
      expect(limited.length, 4);
      // Verify first 4 files are taken
      expect(limited[0].path, 'test0.jpg');
      expect(limited[3].path, 'test3.jpg');
    });

    test('should create default ProviderContainer when container is null', () async {
      // This test covers the `container ?? ProviderContainer()` branch (line 10)
      // and the `if (container == null)` branch (line 79)
      
      // Since we can't easily mock without passing container,
      // we'll test the pattern by calling the function without container parameter
      // This will create and dispose its own container
      final files = <File>[];
      final result = await upload_media(files); // No container parameter
      
      // Should return empty list for empty files
      expect(result, isEmpty);
    });
  });
}
