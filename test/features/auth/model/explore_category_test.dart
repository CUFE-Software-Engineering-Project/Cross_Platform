import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/auth/models/ExploreCategory.dart';

void main() {
  group("ExploreCategory", () {
    test("should create ExploreCategory with correct values", () {
      final category = ExploreCategory(id: "1", name: "Tech");

      expect(category.id, "1");
      expect(category.name, "Tech");
    });

    test("fromMap should parse valid map correctly", () {
      final map = {"id": "10", "name": "Business"};

      final category = ExploreCategory.fromMap(map);

      expect(category.id, "10");
      expect(category.name, "Business");
    });

    test("fromMap should throw error if id is missing", () {
      final map = {"name": "Sports"};

      expect(() => ExploreCategory.fromMap(map), throwsA(isA<TypeError>()));
    });

    test("fromMap should throw error if name is missing", () {
      final map = {"id": "55"};

      expect(() => ExploreCategory.fromMap(map), throwsA(isA<TypeError>()));
    });

    test("two ExploreCategory objects with same values should be equal", () {
      final c1 = ExploreCategory(id: "1", name: "Tech");
      final c2 = ExploreCategory(id: "1", name: "Tech");

      expect(c1.id, c2.id);
      expect(c1.name, c2.name);
    });
  });
}
