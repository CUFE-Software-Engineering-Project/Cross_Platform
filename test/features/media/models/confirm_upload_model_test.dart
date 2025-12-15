import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/media/models/confirm_upload_model.dart';

void main() {
  group('ConfirmUploadModel', () {
    group('Constructor', () {
      test('should create ConfirmUploadModel with all required fields', () {
        final model = ConfirmUploadModel(
          id: '12345',
          name: 'test_image.jpg',
          keyName: 'uploads/test_image.jpg',
          type: 'image/jpeg',
          size: 1024000,
        );

        expect(model.id, '12345');
        expect(model.name, 'test_image.jpg');
        expect(model.keyName, 'uploads/test_image.jpg');
        expect(model.type, 'image/jpeg');
        expect(model.size, 1024000);
      });

      test('should create ConfirmUploadModel with empty strings and zero size', () {
        final model = ConfirmUploadModel(
          id: '',
          name: '',
          keyName: '',
          type: '',
          size: 0,
        );

        expect(model.id, '');
        expect(model.name, '');
        expect(model.keyName, '');
        expect(model.type, '');
        expect(model.size, 0);
      });

      test('should create ConfirmUploadModel with large file size', () {
        final model = ConfirmUploadModel(
          id: '999',
          name: 'large_video.mp4',
          keyName: 'videos/large_video.mp4',
          type: 'video/mp4',
          size: 1073741824, // 1GB
        );

        expect(model.size, 1073741824);
      });
    });

    group('fromJson', () {
      test('should create ConfirmUploadModel from valid JSON with newMedia', () {
        final json = {
          'newMedia': {
            'id': 'media123',
            'name': 'photo.png',
            'keyName': 'uploads/2024/photo.png',
            'type': 'image/png',
            'size': 500000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, 'media123');
        expect(model.name, 'photo.png');
        expect(model.keyName, 'uploads/2024/photo.png');
        expect(model.type, 'image/png');
        expect(model.size, 500000);
      });

      test('should handle missing newMedia with empty defaults', () {
        final json = <String, dynamic>{};

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
        expect(model.keyName, '');
        expect(model.type, '');
        expect(model.size, 0);
      });

      test('should handle null newMedia', () {
        final json = {
          'newMedia': null,
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
        expect(model.keyName, '');
        expect(model.type, '');
        expect(model.size, 0);
      });

      test('should handle missing id in newMedia', () {
        final json = {
          'newMedia': {
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, 'test.jpg');
      });

      test('should handle null id in newMedia', () {
        final json = {
          'newMedia': {
            'id': null,
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, '');
      });

      test('should handle missing name in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.name, '');
        expect(model.id, '123');
      });

      test('should handle null name in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': null,
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.name, '');
      });

      test('should handle missing keyName in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.keyName, '');
      });

      test('should handle null keyName in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'keyName': null,
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.keyName, '');
      });

      test('should handle missing type in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.type, '');
      });

      test('should handle null type in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'type': null,
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.type, '');
      });

      test('should handle missing size in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.size, 0);
      });

      test('should handle null size in newMedia', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
            'size': null,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.size, 0);
      });

      test('should handle all fields null in newMedia', () {
        final json = {
          'newMedia': {
            'id': null,
            'name': null,
            'keyName': null,
            'type': null,
            'size': null,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
        expect(model.keyName, '');
        expect(model.type, '');
        expect(model.size, 0);
      });

      test('should handle empty newMedia object', () {
        final json = {
          'newMedia': <String, dynamic>{},
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
        expect(model.keyName, '');
        expect(model.type, '');
        expect(model.size, 0);
      });

      test('should handle video file type', () {
        final json = {
          'newMedia': {
            'id': 'vid123',
            'name': 'video.mp4',
            'keyName': 'videos/video.mp4',
            'type': 'video/mp4',
            'size': 10485760, // 10MB
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.type, 'video/mp4');
        expect(model.size, 10485760);
      });

      test('should handle different image types', () {
        final json = {
          'newMedia': {
            'id': 'img123',
            'name': 'image.webp',
            'keyName': 'images/image.webp',
            'type': 'image/webp',
            'size': 250000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.type, 'image/webp');
        expect(model.name, 'image.webp');
      });
    });

    group('Edge cases', () {
      test('should handle negative size (invalid but testing robustness)', () {
        final json = {
          'newMedia': {
            'id': '123',
            'name': 'test.jpg',
            'keyName': 'key.jpg',
            'type': 'image/jpeg',
            'size': -100,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.size, -100);
      });

      test('should handle very long file names', () {
        final longName = 'a' * 500 + '.jpg';
        final json = {
          'newMedia': {
            'id': '123',
            'name': longName,
            'keyName': 'uploads/$longName',
            'type': 'image/jpeg',
            'size': 1000,
          },
        };

        final model = ConfirmUploadModel.fromJson(json);

        expect(model.name.length, greaterThan(500));
      });
    });
  });
}
