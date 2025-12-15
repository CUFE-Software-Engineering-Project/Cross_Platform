import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';
import 'package:lite_x/features/media/repository/media_repo.dart';
import 'package:lite_x/features/media/repository/media_repo_impl.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'providers_test.mocks.dart';

@GenerateMocks([MediaRepo, Dio])
void main() {
  late MockMediaRepo mockMediaRepo;
  late ProviderContainer container;

  setUp(() {
    mockMediaRepo = MockMediaRepo();
    container = ProviderContainer(
      overrides: [
        mediaRepoProvider.overrideWithValue(mockMediaRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('mediaRepoProvider', () {
    test('should provide MediaRepo instance from mock', () {
      // Use mocked repository from setUp
      final repo = container.read(mediaRepoProvider);
      expect(repo, isNotNull);
      expect(repo, isA<MediaRepo>());
    });

    test('should create MediaRepoImpL with dioProvider', () {
      // Create a container without overrides to test the actual provider
      final mockDio = MockDio();
      final testContainer = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      // Act
      final repo = testContainer.read(mediaRepoProvider);

      // Assert
      expect(repo, isNotNull);
      expect(repo, isA<MediaRepoImpL>());
      testContainer.dispose();
    });
  });

  group('requestUploadProvider', () {
    test('should call repo.requestUpload with correct parameters', () async {
      // Arrange
      final model = RequestUploadModel(
        url: 'https://s3.amazonaws.com/test',
        keyName: 'uploads/test.jpg',
      );
      when(mockMediaRepo.requestUpload('test.jpg', 'image/jpeg'))
          .thenAnswer((_) async => Right(model));

      // Act
      final requestUpload = container.read(requestUploadProvider);
      final result = await requestUpload('test.jpg', 'image/jpeg');

      // Assert
      verify(mockMediaRepo.requestUpload('test.jpg', 'image/jpeg')).called(1);
      result.fold(
        (failure) => fail('Should not return failure'),
        (uploadModel) {
          expect(uploadModel.url, 'https://s3.amazonaws.com/test');
          expect(uploadModel.keyName, 'uploads/test.jpg');
        },
      );
    });

    test('should return failure when repo fails', () async {
      // Arrange
      when(mockMediaRepo.requestUpload(any, any))
          .thenAnswer((_) async => Left(Failure("Upload request failed")));

      // Act
      final requestUpload = container.read(requestUploadProvider);
      final result = await requestUpload('test.jpg', 'image/jpeg');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Upload request failed"),
        (_) => fail('Should not return success'),
      );
    });

    test('should handle different file types', () async {
      // Arrange
      final model = RequestUploadModel(
        url: 'https://s3.amazonaws.com/video',
        keyName: 'uploads/video.mp4',
      );
      when(mockMediaRepo.requestUpload('video.mp4', 'video/mp4'))
          .thenAnswer((_) async => Right(model));

      // Act
      final requestUpload = container.read(requestUploadProvider);
      final result = await requestUpload('video.mp4', 'video/mp4');

      // Assert
      expect(result.isRight(), true);
    });
  });

  group('confirmUploadProvider', () {
    test('should call repo.confirmUpload with correct keyName', () async {
      // Arrange
      final model = ConfirmUploadModel(
        id: 'media123',
        name: 'test.jpg',
        keyName: 'uploads/test.jpg',
        type: 'image/jpeg',
        size: 1024000,
      );
      when(mockMediaRepo.confirmUpload('uploads/test.jpg'))
          .thenAnswer((_) async => Right(model));

      // Act
      final confirmUpload = container.read(confirmUploadProvider);
      final result = await confirmUpload('uploads/test.jpg');

      // Assert
      verify(mockMediaRepo.confirmUpload('uploads/test.jpg')).called(1);
      result.fold(
        (failure) => fail('Should not return failure'),
        (confirmModel) {
          expect(confirmModel.id, 'media123');
          expect(confirmModel.name, 'test.jpg');
          expect(confirmModel.keyName, 'uploads/test.jpg');
          expect(confirmModel.type, 'image/jpeg');
          expect(confirmModel.size, 1024000);
        },
      );
    });

    test('should return failure when repo fails', () async {
      // Arrange
      when(mockMediaRepo.confirmUpload(any))
          .thenAnswer((_) async => Left(Failure("Confirm failed")));

      // Act
      final confirmUpload = container.read(confirmUploadProvider);
      final result = await confirmUpload('uploads/test.jpg');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Confirm failed"),
        (_) => fail('Should not return success'),
      );
    });

    test('should handle special characters in keyName', () async {
      // Arrange
      final keyName = 'uploads/special#file@name.jpg';
      final model = ConfirmUploadModel(
        id: 'media456',
        name: 'special#file@name.jpg',
        keyName: keyName,
        type: 'image/jpeg',
        size: 500000,
      );
      when(mockMediaRepo.confirmUpload(keyName))
          .thenAnswer((_) async => Right(model));

      // Act
      final confirmUpload = container.read(confirmUploadProvider);
      final result = await confirmUpload(keyName);

      // Assert
      expect(result.isRight(), true);
    });
  });

  group('uploadProvider', () {
    test('should call repo.upload with correct parameters', () async {
      // Arrange
      final file = File('test.jpg');
      when(mockMediaRepo.upload('https://s3.amazonaws.com/test', file))
          .thenAnswer((_) async => Right(null));

      // Act
      final upload = container.read(uploadProvider);
      final result = await upload('https://s3.amazonaws.com/test', file);

      // Assert
      verify(mockMediaRepo.upload('https://s3.amazonaws.com/test', file))
          .called(1);
      expect(result.isRight(), true);
    });

    test('should return failure when repo fails', () async {
      // Arrange
      final file = File('test.jpg');
      when(mockMediaRepo.upload(any, any))
          .thenAnswer((_) async => Left(Failure("Upload failed")));

      // Act
      final upload = container.read(uploadProvider);
      final result = await upload('https://s3.amazonaws.com/test', file);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, "Upload failed"),
        (_) => fail('Should not return success'),
      );
    });

    test('should handle different file types', () async {
      // Arrange
      final file = File('video.mp4');
      when(mockMediaRepo.upload('https://s3.amazonaws.com/video', file))
          .thenAnswer((_) async => Right(null));

      // Act
      final upload = container.read(uploadProvider);
      final result = await upload('https://s3.amazonaws.com/video', file);

      // Assert
      expect(result.isRight(), true);
    });
  });

  group('mediaUrlProvider', () {
    test('should return media URL on success', () async {
      // Arrange
      when(mockMediaRepo.getMediaUrl('media123'))
          .thenAnswer((_) async => Right('https://cdn.example.com/media123.jpg'));

      // Act
      final url = await container.read(mediaUrlProvider('media123').future);

      // Assert
      expect(url, 'https://cdn.example.com/media123.jpg');
      verify(mockMediaRepo.getMediaUrl('media123')).called(1);
    });

    test('should return empty string on failure', () async {
      // Arrange
      when(mockMediaRepo.getMediaUrl('media456'))
          .thenAnswer((_) async => Left(Failure("Media not found")));

      // Act
      final url = await container.read(mediaUrlProvider('media456').future);

      // Assert
      expect(url, '');
    });

    test('should handle different media IDs', () async {
      // Arrange
      when(mockMediaRepo.getMediaUrl('video789'))
          .thenAnswer((_) async => Right('https://cdn.example.com/video789.mp4'));

      // Act
      final url = await container.read(mediaUrlProvider('video789').future);

      // Assert
      expect(url, 'https://cdn.example.com/video789.mp4');
    });

    test('should cache results for same media ID', () async {
      // Arrange
      when(mockMediaRepo.getMediaUrl('cached123'))
          .thenAnswer((_) async => Right('https://cdn.example.com/cached.jpg'));

      // Act
      final url1 = await container.read(mediaUrlProvider('cached123').future);
      final url2 = await container.read(mediaUrlProvider('cached123').future);

      // Assert
      expect(url1, url2);
      // Should only call once due to caching
      verify(mockMediaRepo.getMediaUrl('cached123')).called(1);
    });

    test('should handle empty media ID', () async {
      // Arrange
      when(mockMediaRepo.getMediaUrl(''))
          .thenAnswer((_) async => Left(Failure("Invalid ID")));

      // Act
      final url = await container.read(mediaUrlProvider('').future);

      // Assert
      expect(url, '');
    });

    test('should handle null URL from response', () async {
      // Arrange
      when(mockMediaRepo.getMediaUrl('null123'))
          .thenAnswer((_) async => Right(''));

      // Act
      final url = await container.read(mediaUrlProvider('null123').future);

      // Assert
      expect(url, '');
    });
  });
}
