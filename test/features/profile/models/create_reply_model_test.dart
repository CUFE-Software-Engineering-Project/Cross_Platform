import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/create_reply_model.dart';

void main() {
  group('CreateReplyModel', () {
    test('should have toJson method', () {
      // Arrange
      final model = CreateReplyModel();

      // Act
      final json = model.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json.isEmpty, true);
    });
  });
}
