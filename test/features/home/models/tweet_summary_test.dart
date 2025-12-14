import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_summary.dart';

void main() {
  group('TweetSummary Tests', () {
    test('fromJson creates TweetSummary with all fields', () {
      final json = {
        'id': '123',
        'tweetId': '456',
        'summary': 'Test summary',
        'views': 1000,
        'likes': 50,
        'replies': 10,
        'retweets': 20,
        'quotes': 5,
        'bookmarks': 15,
      };

      final result = TweetSummary.fromJson(json);

      expect(result.id, '123');
      expect(result.tweetId, '456');
      expect(result.summary, 'Test summary');
      expect(result.views, 1000);
      expect(result.likes, 50);
      expect(result.replies, 10);
      expect(result.retweets, 20);
      expect(result.quotes, 5);
      expect(result.bookmarks, 15);
    });

    test('fromJson handles alternative field names', () {
      final json = {
        'id': '123',
        'tweetId': '456',
        'summary': 'Test summary',
        'viewCount': 1000,
        'likesCount': 50,
        'repliesCount': 10,
        'retweetCount': 20,
        'quotesCount': 5,
        'bookmarksCount': 15,
      };

      final result = TweetSummary.fromJson(json);

      expect(result.views, 1000);
      expect(result.likes, 50);
      expect(result.replies, 10);
      expect(result.retweets, 20);
      expect(result.quotes, 5);
      expect(result.bookmarks, 15);
    });

    test('fromJson handles viewsCount as alternative', () {
      final json = {'viewsCount': 2000};

      final result = TweetSummary.fromJson(json);

      expect(result.views, 2000);
    });

    test('fromJson handles double values and rounds them', () {
      final json = {'views': 1000.5, 'likes': 50.9, 'replies': 10.1};

      final result = TweetSummary.fromJson(json);

      expect(result.views, 1001);
      expect(result.likes, 51);
      expect(result.replies, 10);
    });

    test('fromJson handles string values and parses them', () {
      final json = {'views': '1000', 'likes': '50', 'replies': '10'};

      final result = TweetSummary.fromJson(json);

      expect(result.views, 1000);
      expect(result.likes, 50);
      expect(result.replies, 10);
    });

    test('fromJson handles invalid string values', () {
      final json = {'views': 'invalid', 'likes': 'abc'};

      final result = TweetSummary.fromJson(json);

      expect(result.views, 0);
      expect(result.likes, 0);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final result = TweetSummary.fromJson(json);

      expect(result.id, isNull);
      expect(result.tweetId, isNull);
      expect(result.summary, isNull);
      expect(result.views, 0);
      expect(result.likes, 0);
      expect(result.replies, 0);
      expect(result.retweets, 0);
      expect(result.quotes, 0);
      expect(result.bookmarks, 0);
    });

    test('fromJson prefers primary field names over alternatives', () {
      final json = {'views': 1000, 'viewCount': 2000, 'viewsCount': 3000};

      final result = TweetSummary.fromJson(json);

      // Should use the first non-zero value in order: views, viewCount, viewsCount
      expect(result.views, 1000);
    });

    test('fromJson uses fallback when primary field is zero', () {
      final json = {'views': 0, 'viewCount': 2000};

      final result = TweetSummary.fromJson(json);

      // Should fall back to viewCount when views is 0
      expect(result.views, 2000);
    });

    test('fromJson handles null values', () {
      final json = {
        'id': null,
        'tweetId': null,
        'summary': null,
        'views': null,
      };

      final result = TweetSummary.fromJson(json);

      expect(result.id, isNull);
      expect(result.tweetId, isNull);
      expect(result.summary, isNull);
      expect(result.views, 0);
    });

    test('const constructor creates TweetSummary correctly', () {
      const result = TweetSummary(
        id: '123',
        tweetId: '456',
        summary: 'Test',
        views: 100,
        likes: 50,
        replies: 10,
        retweets: 20,
        quotes: 5,
        bookmarks: 15,
      );

      expect(result.id, '123');
      expect(result.tweetId, '456');
      expect(result.summary, 'Test');
      expect(result.views, 100);
      expect(result.likes, 50);
      expect(result.replies, 10);
      expect(result.retweets, 20);
      expect(result.quotes, 5);
      expect(result.bookmarks, 15);
    });
  });
}
