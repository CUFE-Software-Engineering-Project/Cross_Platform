import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/trends/models/trend_category.dart';

void main() {
  group('TrendCategory', () {
    group('Constructor', () {
      test('should create TrendCategory with all fields', () {
        final category = TrendCategory(
          categoryName: 'Technology',
          viralTweets: [],
          trends: [],
        );

        expect(category.categoryName, 'Technology');
        expect(category.viralTweets, isEmpty);
        expect(category.trends, isEmpty);
      });

      test('should create TrendCategory with empty string category name', () {
        final category = TrendCategory(
          categoryName: '',
          viralTweets: [],
          trends: [],
        );

        expect(category.categoryName, '');
      });
    });

    group('fromJson', () {
      test('should create TrendCategory from JSON with empty lists', () {
        final json = {
          'category': 'Entertainment',
          'viralTweets': [],
          'trends': [],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.categoryName, 'Entertainment');
        expect(category.viralTweets, isEmpty);
        expect(category.trends, isEmpty);
      });

      test('should create TrendCategory with trends from JSON', () {
        final json = {
          'category': 'Music',
          'viralTweets': [],
          'trends': [
            {
              'id': 'trend1',
              'hashtag': '#NewRelease',
              'tweetCount': 3000,
              'rank': 1,
              'likesCount': 10000,
            },
          ],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.categoryName, 'Music');
        expect(category.trends.length, 1);
        expect(category.trends[0].title, '#NewRelease');
      });

      test('should handle missing category with empty string', () {
        final json = {
          'viralTweets': [],
          'trends': [],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.categoryName, '');
      });

      test('should handle null category', () {
        final json = {
          'category': null,
          'viralTweets': [],
          'trends': [],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.categoryName, '');
      });

      test('should handle missing viralTweets field', () {
        final json = {
          'category': 'Test',
          'trends': [],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.viralTweets, isEmpty);
      });

      test('should handle missing trends field', () {
        final json = {
          'category': 'Test',
          'viralTweets': [],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.trends, isEmpty);
      });

      test('should handle null viralTweets', () {
        final json = {
          'category': 'Test',
          'viralTweets': null,
          'trends': [],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.viralTweets, isEmpty);
      });

      test('should handle null trends', () {
        final json = {
          'category': 'Test',
          'viralTweets': [],
          'trends': null,
        };

        final category = TrendCategory.fromJson(json);

        expect(category.trends, isEmpty);
      });

      test('should handle multiple trends', () {
        final json = {
          'category': 'TopTrends',
          'viralTweets': [],
          'trends': [
            {
              'id': 't1',
              'hashtag': '#First',
              'tweetCount': 1000,
              'rank': 1,
              'likesCount': 5000,
            },
            {
              'id': 't2',
              'hashtag': '#Second',
              'tweetCount': 900,
              'rank': 2,
              'likesCount': 4500,
            },
          ],
        };

        final category = TrendCategory.fromJson(json);

        expect(category.trends.length, 2);
        expect(category.trends[0].title, '#First');
        expect(category.trends[1].title, '#Second');
      });
    });
  });
}
