import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/create_tweet_model.dart';

void main() {
  group('CreateTweetModel', () {
    test('should have toJson method', () {
      // Arrange
      final model = CreateTweetModel();

      // Act
      final json = model.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json.isEmpty, true);
    });
  });
}
