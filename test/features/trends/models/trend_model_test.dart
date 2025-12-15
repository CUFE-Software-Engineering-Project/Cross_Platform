import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/trends/models/trend_model.dart';

void main() {
  group('TrendModel', () {
    group('Constructor', () {
      test('should create TrendModel with all required fields', () {
        const trend = TrendModel(
          id: '123',
          title: '#Flutter',
          postCount: 1500,
          rank: 1,
          likesCount: 5000,
        );

        expect(trend.id, '123');
        expect(trend.title, '#Flutter');
        expect(trend.postCount, 1500);
        expect(trend.rank, 1);
        expect(trend.likesCount, 5000);
      });

      test('should create TrendModel with num types (int and double)', () {
        const trend = TrendModel(
          id: 'abc',
          title: '#Dart',
          postCount: 1500.5,
          rank: 2.0,
          likesCount: 3000,
        );

        expect(trend.postCount, 1500.5);
        expect(trend.rank, 2.0);
        expect(trend.likesCount, 3000);
      });
    });

    group('fromJson', () {
      test('should create TrendModel from valid JSON', () {
        final json = {
          'id': 'trend123',
          'hashtag': '#Technology',
          'tweetCount': 2500,
          'rank': 3,
          'likesCount': 8000,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.id, 'trend123');
        expect(trend.title, '#Technology');
        expect(trend.postCount, 2500);
        expect(trend.rank, 3);
        expect(trend.likesCount, 8000);
      });

      test('should handle missing id with empty string', () {
        final json = {
          'hashtag': '#Test',
          'tweetCount': 100,
          'rank': 1,
          'likesCount': 200,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.id, '');
        expect(trend.title, '#Test');
      });

      test('should handle null values in JSON by not crashing', () {
        final json = {
          'id': 'test',
          'hashtag': 'Test',
          'tweetCount': 100,
          'rank': 1,
          'likesCount': 200,
        };

        final trend = TrendModel.fromJson(json);

        // Should successfully create without crashing
        expect(trend.id, 'test');
      });

      test('should parse JSON with different numeric types', () {
        final json = {
          'id': '456',
          'hashtag': '#Mobile',
          'tweetCount': 1234.56,
          'rank': 5,
          'likesCount': 6789.0,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.postCount, 1234.56);
        expect(trend.rank, 5);
        expect(trend.likesCount, 6789.0);
      });

      test('should handle zero values', () {
        final json = {
          'id': '0',
          'hashtag': '#Zero',
          'tweetCount': 0,
          'rank': 0,
          'likesCount': 0,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.postCount, 0);
        expect(trend.rank, 0);
        expect(trend.likesCount, 0);
      });

      test('should handle negative values', () {
        final json = {
          'id': 'neg',
          'hashtag': '#Negative',
          'tweetCount': -100,
          'rank': -1,
          'likesCount': -500,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.postCount, -100);
        expect(trend.rank, -1);
        expect(trend.likesCount, -500);
      });

      test('should handle large numbers', () {
        final json = {
          'id': 'large',
          'hashtag': '#Viral',
          'tweetCount': 999999999,
          'rank': 1,
          'likesCount': 888888888,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.postCount, 999999999);
        expect(trend.likesCount, 888888888);
      });

      test('should handle empty string values', () {
        final json = {
          'id': '',
          'hashtag': '',
          'tweetCount': 100,
          'rank': 2,
          'likesCount': 300,
        };

        final trend = TrendModel.fromJson(json);

        expect(trend.id, '');
        expect(trend.title, '');
      });
    });

    group('Equality and immutability', () {
      test('should be immutable (const constructor)', () {
        const trend1 = TrendModel(
          id: '123',
          title: '#Flutter',
          postCount: 1500,
          rank: 1,
          likesCount: 5000,
        );

        const trend2 = TrendModel(
          id: '123',
          title: '#Flutter',
          postCount: 1500,
          rank: 1,
          likesCount: 5000,
        );

        // Both should be compile-time constants
        expect(identical(trend1, trend2), isTrue);
      });

      test('should create different instances with different values', () {
        const trend1 = TrendModel(
          id: '1',
          title: '#A',
          postCount: 100,
          rank: 1,
          likesCount: 200,
        );

        const trend2 = TrendModel(
          id: '2',
          title: '#B',
          postCount: 200,
          rank: 2,
          likesCount: 400,
        );

        expect(identical(trend1, trend2), isFalse);
      });
    });
  });
}
