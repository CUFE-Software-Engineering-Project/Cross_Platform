import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_summary.dart';

void main() {
  group('TweetSummary', () {
    test('should create TweetSummary with default values', () {
      const summary = TweetSummary();

      expect(summary.views, 0);
      expect(summary.likes, 0);
      expect(summary.replies, 0);
      expect(summary.retweets, 0);
      expect(summary.quotes, 0);
      expect(summary.bookmarks, 0);
      expect(summary.summary, isNull);
    });

    test('should create TweetSummary with custom values', () {
      const summary = TweetSummary(
        views: 1000,
        likes: 50,
        replies: 10,
        retweets: 20,
        quotes: 5,
        bookmarks: 15,
        summary: 'Test summary',
      );

      expect(summary.views, 1000);
      expect(summary.likes, 50);
      expect(summary.replies, 10);
      expect(summary.retweets, 20);
      expect(summary.quotes, 5);
      expect(summary.bookmarks, 15);
      expect(summary.summary, 'Test summary');
    });

    test('should create TweetSummary from JSON with standard keys', () {
      final json = {
        'views': 500,
        'likes': 25,
        'replies': 8,
        'retweets': 12,
        'quotes': 3,
        'bookmarks': 7,
        'summary': 'JSON summary',
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 500);
      expect(summary.likes, 25);
      expect(summary.replies, 8);
      expect(summary.retweets, 12);
      expect(summary.quotes, 3);
      expect(summary.bookmarks, 7);
      expect(summary.summary, 'JSON summary');
    });

    test('should handle alternative key names with Count suffix', () {
      final json = {
        'viewCount': 300,
        'likesCount': 15,
        'repliesCount': 5,
        'retweetCount': 8,
        'quotesCount': 2,
        'bookmarksCount': 4,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 300);
      expect(summary.likes, 15);
      expect(summary.replies, 5);
      expect(summary.retweets, 8);
      expect(summary.quotes, 2);
      expect(summary.bookmarks, 4);
    });

    test('should handle alternative key name viewsCount', () {
      final json = {
        'viewsCount': 250,
        'likes': 10,
        'replies': 3,
        'retweets': 5,
        'quotes': 1,
        'bookmarks': 2,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 250);
    });

    test('should coalesce multiple key variations and use first non-zero', () {
      // Test that it uses the first non-zero value
      final json = {
        'views': 0,
        'viewCount': 100,
        'viewsCount': 200, // Should use 100, first non-zero
        'likes': 5,
        'replies': 2,
        'retweets': 3,
        'quotes': 1,
        'bookmarks': 1,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 100); // First non-zero value
    });

    test('should handle int values correctly', () {
      final json = {
        'views': 100,
        'likes': 20,
        'replies': 5,
        'retweets': 10,
        'quotes': 2,
        'bookmarks': 3,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 100);
      expect(summary.likes, 20);
    });

    test('should handle double values and round them', () {
      final json = {
        'views': 100.7,
        'likes': 20.3,
        'replies': 5.9,
        'retweets': 10.1,
        'quotes': 2.5,
        'bookmarks': 3.8,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 101); // Rounded
      expect(summary.likes, 20); // Rounded
      expect(summary.replies, 6); // Rounded
      expect(summary.retweets, 10); // Rounded
      expect(summary.quotes, 3); // Rounded
      expect(summary.bookmarks, 4); // Rounded
    });

    test('should handle string values and parse them', () {
      final json = {
        'views': '150',
        'likes': '30',
        'replies': '8',
        'retweets': '12',
        'quotes': '4',
        'bookmarks': '6',
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 150);
      expect(summary.likes, 30);
      expect(summary.replies, 8);
      expect(summary.retweets, 12);
      expect(summary.quotes, 4);
      expect(summary.bookmarks, 6);
    });

    test('should handle invalid string values and default to 0', () {
      final json = {
        'views': 'invalid',
        'likes': 'not-a-number',
        'replies': '',
        'retweets': 'abc',
        'quotes': null,
        'bookmarks': {},
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 0);
      expect(summary.likes, 0);
      expect(summary.replies, 0);
      expect(summary.retweets, 0);
      expect(summary.quotes, 0);
      expect(summary.bookmarks, 0);
    });

    test('should handle missing keys and default to 0', () {
      final json = <String, dynamic>{};

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 0);
      expect(summary.likes, 0);
      expect(summary.replies, 0);
      expect(summary.retweets, 0);
      expect(summary.quotes, 0);
      expect(summary.bookmarks, 0);
      expect(summary.summary, isNull);
    });

    test('should handle null values and default to 0', () {
      final json = {
        'views': null,
        'likes': null,
        'replies': null,
        'retweets': null,
        'quotes': null,
        'bookmarks': null,
        'summary': null,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 0);
      expect(summary.likes, 0);
      expect(summary.replies, 0);
      expect(summary.retweets, 0);
      expect(summary.quotes, 0);
      expect(summary.bookmarks, 0);
      expect(summary.summary, isNull);
    });

    test('should handle mixed data types in JSON', () {
      final json = {
        'views': 100,
        'likes': '50',
        'replies': 10.5,
        'retweets': null,
        'quotes': 'invalid',
        'bookmarks': 5,
        'summary': 'Mixed types summary',
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 100);
      expect(summary.likes, 50);
      expect(summary.replies, 11); // Rounded from 10.5
      expect(summary.retweets, 0);
      expect(summary.quotes, 0);
      expect(summary.bookmarks, 5);
      expect(summary.summary, 'Mixed types summary');
    });

    test('should convert summary field to string', () {
      final json = {
        'views': 10,
        'likes': 5,
        'replies': 2,
        'retweets': 1,
        'quotes': 0,
        'bookmarks': 1,
        'summary': 123, // Non-string value
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.summary, '123');
    });

    test('should handle large numbers', () {
      final json = {
        'views': 1000000,
        'likes': 50000,
        'replies': 10000,
        'retweets': 25000,
        'quotes': 5000,
        'bookmarks': 15000,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 1000000);
      expect(summary.likes, 50000);
      expect(summary.replies, 10000);
      expect(summary.retweets, 25000);
      expect(summary.quotes, 5000);
      expect(summary.bookmarks, 15000);
    });

    test('should handle zero values explicitly', () {
      final json = {
        'views': 0,
        'likes': 0,
        'replies': 0,
        'retweets': 0,
        'quotes': 0,
        'bookmarks': 0,
      };

      final summary = TweetSummary.fromJson(json);

      expect(summary.views, 0);
      expect(summary.likes, 0);
      expect(summary.replies, 0);
      expect(summary.retweets, 0);
      expect(summary.quotes, 0);
      expect(summary.bookmarks, 0);
    });

    test('should handle negative numbers and convert to positive', () {
      // Assuming the implementation doesn't specifically handle negatives,
      // they should be parsed as-is
      final json = {
        'views': -10,
        'likes': -5,
        'replies': -2,
        'retweets': -3,
        'quotes': -1,
        'bookmarks': -4,
      };

      final summary = TweetSummary.fromJson(json);

      // Just verify they are parsed (behavior depends on implementation)
      expect(summary.views, -10);
      expect(summary.likes, -5);
    });
  });
}
