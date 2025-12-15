import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/media/models/request_upload_model.dart';

void main() {
  group('RequestUploadModel', () {
    group('Constructor', () {
      test('should create RequestUploadModel with all required fields', () {
        final model = RequestUploadModel(
          url: 'https://example.com/upload',
          keyName: 'media/12345.jpg',
        );

        expect(model.url, 'https://example.com/upload');
        expect(model.keyName, 'media/12345.jpg');
      });

      test('should create RequestUploadModel with empty strings', () {
        final model = RequestUploadModel(
          url: '',
          keyName: '',
        );

        expect(model.url, '');
        expect(model.keyName, '');
      });
    });

    group('fromJson', () {
      test('should create RequestUploadModel from valid JSON', () {
        final json = {
          'url': 'https://s3.amazonaws.com/bucket/key',
          'keyName': 'uploads/file123.png',
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, 'https://s3.amazonaws.com/bucket/key');
        expect(model.keyName, 'uploads/file123.png');
      });

      test('should handle missing url with empty string', () {
        final json = {
          'keyName': 'test.jpg',
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, '');
        expect(model.keyName, 'test.jpg');
      });

      test('should handle missing keyName with empty string', () {
        final json = {
          'url': 'https://test.com',
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, 'https://test.com');
        expect(model.keyName, '');
      });

      test('should handle null url', () {
        final json = {
          'url': null,
          'keyName': 'key.jpg',
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, '');
        expect(model.keyName, 'key.jpg');
      });

      test('should handle null keyName', () {
        final json = {
          'url': 'https://test.com',
          'keyName': null,
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, 'https://test.com');
        expect(model.keyName, '');
      });

      test('should handle both fields missing', () {
        final json = <String, dynamic>{};

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, '');
        expect(model.keyName, '');
      });

      test('should handle both fields null', () {
        final json = {
          'url': null,
          'keyName': null,
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url, '');
        expect(model.keyName, '');
      });

      test('should handle long URLs and key names', () {
        final json = {
          'url': 'https://very-long-domain-name.s3.amazonaws.com/bucket/path/to/file/with/multiple/segments/file123456789.jpg?signature=verylongsignature',
          'keyName': 'uploads/2024/12/15/user_123/profile/images/original/file_with_very_long_name_123456789.jpg',
        };

        final model = RequestUploadModel.fromJson(json);

        expect(model.url.length, greaterThan(100));
        expect(model.keyName.length, greaterThan(50));
      });
    });

    group('toJson', () {
      test('should convert RequestUploadModel to JSON', () {
        final model = RequestUploadModel(
          url: 'https://example.com/upload',
          keyName: 'media/test.jpg',
        );

        final json = model.toJson();

        expect(json['url'], 'https://example.com/upload');
        expect(json['keyName'], 'media/test.jpg');
        expect(json.length, 2);
      });

      test('should convert model with empty strings to JSON', () {
        final model = RequestUploadModel(
          url: '',
          keyName: '',
        );

        final json = model.toJson();

        expect(json['url'], '');
        expect(json['keyName'], '');
      });

      test('should create JSON with correct keys', () {
        final model = RequestUploadModel(
          url: 'test',
          keyName: 'key',
        );

        final json = model.toJson();

        expect(json.containsKey('url'), isTrue);
        expect(json.containsKey('keyName'), isTrue);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data through JSON round-trip', () {
        final original = RequestUploadModel(
          url: 'https://test.com/upload',
          keyName: 'files/image.png',
        );

        final json = original.toJson();
        final restored = RequestUploadModel.fromJson(json);

        expect(restored.url, original.url);
        expect(restored.keyName, original.keyName);
      });

      test('should handle round-trip with empty strings', () {
        final original = RequestUploadModel(
          url: '',
          keyName: '',
        );

        final json = original.toJson();
        final restored = RequestUploadModel.fromJson(json);

        expect(restored.url, '');
        expect(restored.keyName, '');
      });
    });
  });
}
