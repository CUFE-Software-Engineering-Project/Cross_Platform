import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lite_x/core/constants/server_constants.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final envPath = p.join(Directory.current.path, 'test', '.env.test');

    print("Loading env from: $envPath");

    await dotenv.load(fileName: envPath);
  });

  group("API_URL", () {
    test("should load API_URL from environment", () {
      final apiUrl = dotenv.env["API_URL"];
      expect(apiUrl, isNotNull);
      expect(apiUrl, equals("https://example.com/"));
    });
  });

  group("BASE_OPTIONS", () {
    test("should have correct baseUrl", () {
      expect(BASE_OPTIONS.baseUrl, equals("https://example.com/"));
    });

    test("should set contentType to application/json", () {
      expect(BASE_OPTIONS.contentType, equals("application/json"));
    });

    test("should have correct timeouts", () {
      expect(BASE_OPTIONS.sendTimeout, equals(const Duration(seconds: 60)));
      expect(BASE_OPTIONS.receiveTimeout, equals(const Duration(seconds: 60)));
      expect(BASE_OPTIONS.connectTimeout, equals(const Duration(seconds: 60)));
    });
  });
}
