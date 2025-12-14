import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/classes/PickedImage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';

import 'picked_image_class_test.mocks.dart';

@GenerateMocks([ImagePicker, XFile])
void main() {
  late MockImagePicker mockPicker;
  late MockXFile mockXFile;

  setUp(() {
    mockPicker = MockImagePicker();
    mockXFile = MockXFile();
  });

  group("pickImage", () {
    test("should return PickedImage when image selected", () async {
      when(mockXFile.path).thenReturn("/test/image.png");
      when(mockXFile.name).thenReturn("image.png");
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenAnswer((_) async => mockXFile);

      final result = await pickImage(picker: mockPicker);

      expect(result, isA<PickedImage>());
      expect(result!.name, "image.png");
      expect(result.path, "/test/image.png");
      expect(result.file, isA<File>());
      verify(mockPicker.pickImage(source: anyNamed("source"))).called(1);
    });

    test("should return null when no image selected", () async {
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenAnswer((_) async => null);

      final result = await pickImage(picker: mockPicker);

      expect(result, null);
      verify(mockPicker.pickImage(source: anyNamed("source"))).called(1);
    });

    test("should return null when picker throws exception", () async {
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenThrow(Exception("Picker error"));

      final result = await pickImage(picker: mockPicker);

      expect(result, null);
      verify(mockPicker.pickImage(source: anyNamed("source"))).called(1);
    });

    test("should use default ImagePicker when picker is null", () async {
      final result = await pickImage(picker: null);
      expect(result, null);
    });

    test("should handle different exception types", () async {
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenThrow(ArgumentError("Invalid argument"));

      final result = await pickImage(picker: mockPicker);

      expect(result, null);
    });
  });

  group("pickImages", () {
    test("should return list with one PickedImage", () async {
      when(mockXFile.path).thenReturn("/test/multi.png");
      when(mockXFile.name).thenReturn("multi.png");
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenAnswer((_) async => mockXFile);

      final result = await pickImages(maxImages: 4, picker: mockPicker);

      expect(result.length, 1);
      expect(result.first.name, "multi.png");
      expect(result.first.path, "/test/multi.png");
      expect(result.first.file, isA<File>());
      verify(mockPicker.pickImage(source: anyNamed("source"))).called(1);
    });

    test("should return empty list when no image selected", () async {
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenAnswer((_) async => null);

      final result = await pickImages(maxImages: 4, picker: mockPicker);

      expect(result, isEmpty);
      verify(mockPicker.pickImage(source: anyNamed("source"))).called(1);
    });

    test("should return empty list when picker throws exception", () async {
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenThrow(Exception("Gallery access denied"));

      final result = await pickImages(maxImages: 4, picker: mockPicker);

      expect(result, isEmpty);
      verify(mockPicker.pickImage(source: anyNamed("source"))).called(1);
    });

    test("should use default ImagePicker when picker is null", () async {
      final result = await pickImages(maxImages: 4, picker: null);

      expect(result, isEmpty);
    });

    test("should handle different maxImages parameter", () async {
      when(mockXFile.path).thenReturn("/test/image.jpg");
      when(mockXFile.name).thenReturn("image.jpg");
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenAnswer((_) async => mockXFile);

      final result1 = await pickImages(maxImages: 1, picker: mockPicker);
      final result2 = await pickImages(maxImages: 10, picker: mockPicker);

      expect(result1.length, 1);
      expect(result2.length, 1);
    });

    test("should handle different exception types", () async {
      when(
        mockPicker.pickImage(source: anyNamed("source")),
      ).thenThrow(StateError("Invalid state"));

      final result = await pickImages(maxImages: 4, picker: mockPicker);

      expect(result, isEmpty);
    });
  });

  group("pickVideo", () {
    test("should return PickedImage when video selected", () async {
      when(mockXFile.path).thenReturn("/test/video.mp4");
      when(mockXFile.name).thenReturn("video.mp4");
      when(
        mockPicker.pickVideo(source: anyNamed("source")),
      ).thenAnswer((_) async => mockXFile);

      final result = await pickVideo(picker: mockPicker);

      expect(result, isA<PickedImage>());
      expect(result!.name, "video.mp4");
      expect(result.path, "/test/video.mp4");
      expect(result.file, isA<File>());
      verify(mockPicker.pickVideo(source: anyNamed("source"))).called(1);
    });

    test("should return null when no video selected", () async {
      when(
        mockPicker.pickVideo(source: anyNamed("source")),
      ).thenAnswer((_) async => null);

      final result = await pickVideo(picker: mockPicker);

      expect(result, null);
      verify(mockPicker.pickVideo(source: anyNamed("source"))).called(1);
    });

    test("should return null when picker throws exception", () async {
      when(
        mockPicker.pickVideo(source: anyNamed("source")),
      ).thenThrow(Exception("Video picker error"));

      final result = await pickVideo(picker: mockPicker);

      expect(result, null);
      verify(mockPicker.pickVideo(source: anyNamed("source"))).called(1);
    });

    test("should use default ImagePicker when picker is null", () async {
      final result = await pickVideo(picker: null);

      expect(result, null);
    });

    test("should handle different exception types", () async {
      when(
        mockPicker.pickVideo(source: anyNamed("source")),
      ).thenThrow(FormatException("Invalid format"));

      final result = await pickVideo(picker: mockPicker);

      expect(result, null);
    });

    test("should handle video with long path", () async {
      final longPath = "/very/long/path/to/video/" * 10 + "video.mp4";
      when(mockXFile.path).thenReturn(longPath);
      when(mockXFile.name).thenReturn("video.mp4");
      when(
        mockPicker.pickVideo(source: anyNamed("source")),
      ).thenAnswer((_) async => mockXFile);

      final result = await pickVideo(picker: mockPicker);

      expect(result, isNotNull);
      expect(result!.path, longPath);
    });
  });

  group("PickedImage class", () {
    test("should create PickedImage with file", () {
      final file = File("/test/image.png");
      final pickedImage = PickedImage(
        file: file,
        name: "image.png",
        path: "/test/image.png",
      );

      expect(pickedImage.file, equals(file));
      expect(pickedImage.name, "image.png");
      expect(pickedImage.path, "/test/image.png");
      expect(pickedImage.bytes, null);
    });

    test("should create PickedImage with bytes", () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final pickedImage = PickedImage(bytes: bytes, name: "image.png");

      expect(pickedImage.bytes, equals(bytes));
      expect(pickedImage.name, "image.png");
      expect(pickedImage.file, null);
      expect(pickedImage.path, null);
    });

    test("should create PickedImage with all parameters", () {
      final file = File("/test/image.png");
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final pickedImage = PickedImage(
        file: file,
        bytes: bytes,
        name: "image.png",
        path: "/test/image.png",
      );

      expect(pickedImage.file, equals(file));
      expect(pickedImage.bytes, equals(bytes));
      expect(pickedImage.name, "image.png");
      expect(pickedImage.path, "/test/image.png");
    });

    test("should create PickedImage with only name", () {
      final pickedImage = PickedImage(name: "image.png");

      expect(pickedImage.name, "image.png");
      expect(pickedImage.file, null);
      expect(pickedImage.bytes, null);
      expect(pickedImage.path, null);
    });
  });
}
