import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/classes/AppFailure.dart';

void main() {
  group("AppFailure", () {
    test("should store default message", () {
      final failure = AppFailure();

      expect(failure.message, "Unexpected error occurred");
    });

    test("should store provided message", () {
      final failure = AppFailure(message: "Custom error");

      expect(failure.message, "Custom error");
    });

    test("toString should return formatted string", () {
      final failure = AppFailure(message: "Network issue");

      expect(failure.toString(), "AppFailure(message: Network issue)");
    });

    test("should compare equal when messages match", () {
      final f1 = AppFailure(message: "Error");
      final f2 = AppFailure(message: "Error");

      expect(f1, equals(f2));
    });
    test("identical objects should be equal", () {
      final f1 = AppFailure(message: "Same");
      final f2 = f1;

      expect(f1 == f2, true);
    });

    test("should not be equal when messages differ", () {
      final f1 = AppFailure(message: "Error1");
      final f2 = AppFailure(message: "Error2");

      expect(f1 == f2, false);
    });

    test("hashCode should match when messages match", () {
      final f1 = AppFailure(message: "Hash");
      final f2 = AppFailure(message: "Hash");

      expect(f1.hashCode, f2.hashCode);
    });
  });
}
