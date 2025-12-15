import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/trends/models/for_you_response_model.dart';

void main() {
  group('ForYouResponseModel', () {
    test('should create ForYouResponseModel with empty lists', () {
      final response = ForYouResponseModel(
        categories: [],
        suggestedUsers: [],
      );

      expect(response.categories, isEmpty);
      expect(response.suggestedUsers, isEmpty);
    });

    test('should allow access to categories field', () {
      final response = ForYouResponseModel(
        categories: [],
        suggestedUsers: [],
      );

      expect(response.categories, isNotNull);
      expect(response.categories, isA<List>());
    });

    test('should allow access to suggestedUsers field', () {
      final response = ForYouResponseModel(
        categories: [],
        suggestedUsers: [],
      );

      expect(response.suggestedUsers, isNotNull);
      expect(response.suggestedUsers, isA<List>());
    });
  });
}
