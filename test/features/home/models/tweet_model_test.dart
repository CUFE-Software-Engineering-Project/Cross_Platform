import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';

void main() {
  group('TweetModel', () {
    late TweetModel testTweet;

    setUp(() {
      testTweet = TweetModel(
        id: '1',
        content: 'Test tweet content',
        authorName: 'John Doe',
        authorUsername: 'johndoe',
        authorAvatar: 'https://example.com/avatar.jpg',
        createdAt: DateTime(2024, 1, 1),
        likes: 10,
        retweets: 5,
        replies: 3,
        images: ['image1.jpg', 'image2.jpg'],
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
        quotes: 2,
        bookmarks: 1,
        userId: 'user123',
        tweetType: 'TWEET',
      );
    });

    test('should create TweetModel with required fields', () {
      expect(testTweet.id, '1');
      expect(testTweet.content, 'Test tweet content');
      expect(testTweet.authorName, 'John Doe');
      expect(testTweet.authorUsername, 'johndoe');
      expect(testTweet.authorAvatar, 'https://example.com/avatar.jpg');
      expect(testTweet.createdAt, DateTime(2024, 1, 1));
    });

    test('should have correct default values', () {
      final defaultTweet = TweetModel(
        id: '2',
        content: 'Default tweet',
        authorName: 'Jane Doe',
        authorUsername: 'janedoe',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
      );

      expect(defaultTweet.likes, 0);
      expect(defaultTweet.retweets, 0);
      expect(defaultTweet.replies, 0);
      expect(defaultTweet.images, const []);
      expect(defaultTweet.isLiked, false);
      expect(defaultTweet.isRetweeted, false);
      expect(defaultTweet.isBookmarked, false);
      expect(defaultTweet.replyIds, const []);
      expect(defaultTweet.quotes, 0);
      expect(defaultTweet.bookmarks, 0);
      expect(defaultTweet.tweetType, 'TWEET');
    });

    test('should create copy with modified fields', () {
      final copiedTweet = testTweet.copyWith(
        likes: 20,
        isLiked: true,
        content: 'Updated content',
      );

      expect(copiedTweet.likes, 20);
      expect(copiedTweet.isLiked, true);
      expect(copiedTweet.content, 'Updated content');
      expect(copiedTweet.id, testTweet.id);
      expect(copiedTweet.authorName, testTweet.authorName);
    });

    test('should preserve unmodified fields in copyWith', () {
      final copiedTweet = testTweet.copyWith(likes: 15);

      expect(copiedTweet.likes, 15);
      expect(copiedTweet.content, testTweet.content);
      expect(copiedTweet.authorUsername, testTweet.authorUsername);
      expect(copiedTweet.isRetweeted, testTweet.isRetweeted);
    });

    test('should handle quoted tweet', () {
      final quotedTweet = TweetModel(
        id: 'quoted1',
        content: 'Original tweet',
        authorName: 'Original Author',
        authorUsername: 'original',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
      );

      final tweetWithQuote = testTweet.copyWith(
        quotedTweetId: 'quoted1',
        quotedTweet: quotedTweet,
      );

      expect(tweetWithQuote.quotedTweetId, 'quoted1');
      expect(tweetWithQuote.quotedTweet, quotedTweet);
      expect(tweetWithQuote.quotedTweet?.content, 'Original tweet');
    });

    test('should handle reply relationships', () {
      final replyTweet = testTweet.copyWith(
        replyToId: 'parent123',
        replyIds: ['reply1', 'reply2', 'reply3'],
      );

      expect(replyTweet.replyToId, 'parent123');
      expect(replyTweet.replyIds.length, 3);
      expect(replyTweet.replyIds, ['reply1', 'reply2', 'reply3']);
    });

    test('should update interaction counts', () {
      expect(testTweet.likes, 10);
      testTweet.likes = 15;
      expect(testTweet.likes, 15);

      expect(testTweet.retweets, 5);
      testTweet.retweets = 8;
      expect(testTweet.retweets, 8);
    });

    test('should toggle boolean states', () {
      expect(testTweet.isLiked, false);
      testTweet.isLiked = true;
      expect(testTweet.isLiked, true);

      expect(testTweet.isRetweeted, false);
      testTweet.isRetweeted = true;
      expect(testTweet.isRetweeted, true);

      expect(testTweet.isBookmarked, false);
      testTweet.isBookmarked = true;
      expect(testTweet.isBookmarked, true);
    });

    test('should handle multiple images', () {
      expect(testTweet.images.length, 2);
      expect(testTweet.images, ['image1.jpg', 'image2.jpg']);

      final tweetWithMoreImages = testTweet.copyWith(
        images: ['img1.jpg', 'img2.jpg', 'img3.jpg', 'img4.jpg'],
      );
      expect(tweetWithMoreImages.images.length, 4);
    });

    test('should handle empty images list', () {
      final tweetNoImages = testTweet.copyWith(images: []);
      expect(tweetNoImages.images, isEmpty);
    });

    test('should handle different tweet types', () {
      final retweet = testTweet.copyWith(tweetType: 'RETWEET');
      expect(retweet.tweetType, 'RETWEET');

      final reply = testTweet.copyWith(tweetType: 'REPLY');
      expect(reply.tweetType, 'REPLY');

      final quote = testTweet.copyWith(tweetType: 'QUOTE');
      expect(quote.tweetType, 'QUOTE');
    });

    test('should handle null optional fields', () {
      final simpleTweet = TweetModel(
        id: '3',
        content: 'Simple tweet',
        authorName: 'Simple User',
        authorUsername: 'simple',
        authorAvatar: 'avatar.jpg',
        createdAt: DateTime.now(),
      );

      expect(simpleTweet.replyToId, isNull);
      expect(simpleTweet.quotedTweetId, isNull);
      expect(simpleTweet.quotedTweet, isNull);
      expect(simpleTweet.userId, isNull);
    });
  });
}
