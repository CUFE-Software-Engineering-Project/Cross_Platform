import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/trends/models/paginated_tweets.dart';

void main() {
  group('PaginatedTweets', () {
    test('should create PaginatedTweets with empty tweets list and null cursor', () {
      final paginated = PaginatedTweets(
        tweets: [],
        nextCursor: null,
      );

      expect(paginated.tweets, isEmpty);
      expect(paginated.nextCursor, isNull);
    });

    test('should create PaginatedTweets with cursor string', () {
      final paginated = PaginatedTweets(
        tweets: [],
        nextCursor: 'cursor123',
      );

      expect(paginated.tweets, isEmpty);
      expect(paginated.nextCursor, 'cursor123');
    });

    test('should create PaginatedTweets with empty string cursor', () {
      final paginated = PaginatedTweets(
        tweets: [],
        nextCursor: '',
      );

      expect(paginated.nextCursor, '');
    });

    test('should allow access to tweets and nextCursor fields', () {
      final paginated = PaginatedTweets(
        tweets: [],
        nextCursor: 'test',
      );

      expect(paginated.tweets, isNotNull);
      expect(paginated.nextCursor, isNotNull);
      expect(paginated.nextCursor, isA<String>());
    });
  });
}
