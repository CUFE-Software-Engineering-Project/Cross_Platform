import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/notifications/mentions_model.dart';

void main() {
  group('MediaInfo', () {
    test('fromJson creates instance from map', () {
      final json = {'url': 'https://example.com/image.jpg', 'keyName': 'image_key'};
      final mediaInfo = MediaInfo.fromJson(json);

      expect(mediaInfo.url, equals('https://example.com/image.jpg'));
      expect(mediaInfo.keyName, equals('image_key'));
    });

    test('copyWith updates values correctly', () {
      final mediaInfo = MediaInfo(url: 'old_url', keyName: 'old_key');
      final updated = mediaInfo.copyWith(url: 'new_url');

      expect(updated.url, equals('new_url'));
      expect(updated.keyName, equals('old_key'));
    });

    test('toJson returns correct map', () {
      final mediaInfo = MediaInfo(url: 'https://example.com', keyName: 'key');
      final json = mediaInfo.toJson();

      expect(json['url'], equals('https://example.com'));
      expect(json['keyName'], equals('key'));
    });
  });

  group('TweetMedia', () {
    test('fromJson creates instance', () {
      final media = TweetMedia.fromJson({'id': 'media123'});
      expect(media.id, equals('media123'));
    });

    test('copyWith creates new instance', () {
      final media = TweetMedia(id: 'old_id');
      final updated = media.copyWith(id: 'new_id');
      expect(updated.id, equals('new_id'));
    });

    test('toJson returns correct map', () {
      final media = TweetMedia(id: 'media123');
      final json = media.toJson();
      expect(json['id'], equals('media123'));
    });
  });

  group('TweetUser', () {
    test('fromJson parses full JSON correctly', () {
      final user = TweetUser.fromJson({
        'id': 'user123',
        'name': 'John Doe',
        'username': 'johndoe',
        'profileMedia': {'id': 'media123'},
        'verified': true,
        'protectedAccount': false,
      });

      expect(user.id, 'user123');
      expect(user.name, 'John Doe');
      expect(user.username, 'johndoe');
      expect(user.profileMedia!.id, 'media123');
      expect(user.verified, isTrue);
      expect(user.protectedAccount, isFalse);
    });

    test('fromJson handles null profileMedia', () {
      final user = TweetUser.fromJson({
        'id': 'user1',
        'name': 'John',
        'username': 'john',
        'profileMedia': null,
        'verified': false,
        'protectedAccount': false,
      });

      expect(user.profileMedia, isNull);
      expect(user.verified, isFalse);
    });

    test('copyWith updates specific fields', () {
      final user = TweetUser(
        id: 'id',
        name: 'old_name',
        username: 'old_username',
        verified: false,
        protectedAccount: false,
      );

      final updated = user.copyWith(name: 'new_name');

      expect(updated.name, 'new_name');
      expect(updated.username, 'old_username');
    });

    test('toJson returns correct map', () {
      final user = TweetUser(
        id: 'user1',
        name: 'John',
        username: 'john',
        profileMedia: TweetMedia(id: 'media1'),
        verified: true,
        protectedAccount: false,
      );

      final json = user.toJson();
      expect(json['id'], 'user1');
      expect(json['name'], 'John');
      expect(json['username'], 'john');
      expect(json['verified'], isTrue);
    });
  });

  group('Tweet', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'id': 'tweet1',
        'content': 'Hello World',
        'createdAt': '2024-01-01',
        'likesCount': 10,
        'retweetCount': 5,
        'repliesCount': 3,
        'quotesCount': 2,
        'replyControl': 'everyone',
        'parentId': null,
        'tweetType': 'tweet',
        'user': {'id': 'user1', 'name': 'John', 'username': 'john', 'verified': false, 'protectedAccount': false},
        'mediaIds': ['media1', 'media2'],
        'isLiked': true,
        'isRetweeted': false,
        'isBookmarked': true,
      };

      final tweet = Tweet.fromJson(json);

      expect(tweet.id, 'tweet1');
      expect(tweet.content, 'Hello World');
      expect(tweet.likesCount, 10);
      expect(tweet.mediaIds.length, 2);
      expect(tweet.isLiked, isTrue);
    });

    test('copyWith updates specific fields', () {
      final tweet = Tweet(
        id: 'id',
        content: 'content',
        createdAt: 'date',
        likesCount: 10,
        retweetCount: 5,
        repliesCount: 3,
        quotesCount: 0,
        replyControl: 'everyone',
        tweetType: 'tweet',
        user: TweetUser(id: 'user1', name: 'John', username: 'john', verified: false, protectedAccount: false),
        mediaIds: [],
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
      );

      final updated = tweet.copyWith(likesCount: 20, isLiked: true);

      expect(updated.likesCount, 20);
      expect(updated.isLiked, isTrue);
      expect(updated.retweetCount, 5);
    });

    test('toJson returns correct map', () {
      final tweet = Tweet(
        id: 'tweet1',
        content: 'Test',
        createdAt: '2024-01-01',
        likesCount: 10,
        retweetCount: 5,
        repliesCount: 3,
        quotesCount: 0,
        replyControl: 'everyone',
        tweetType: 'tweet',
        user: TweetUser(id: 'user1', name: 'John', username: 'john', verified: false, protectedAccount: false),
        mediaIds: [],
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
      );

      final json = tweet.toJson();
      expect(json['id'], 'tweet1');
      expect(json['content'], 'Test');
      expect(json['likesCount'], 10);
    });
  });

  group('MentionItem', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': '1',
        'content': 'Test',
        'createdAt': '2024-01-01',
        'likesCount': 5,
        'retweetCount': 2,
        'repliesCount': 1,
        'quotesCount': 0,
        'replyControl': 'everyone',
        'tweetType': 'tweet',
        'user': {'id': 'user1', 'name': 'John', 'username': 'john', 'verified': false, 'protectedAccount': false},
        'mediaIds': [],
        'mediaUrls': [],
        'isLiked': false,
        'isRetweeted': false,
        'isBookmarked': false,
      };

      final item = MentionItem.fromJson(json);

      expect(item.content, 'Test');
      expect(item.likesCount, 5);
    });

    test('copyWith updates values correctly', () {
      final item = MentionItem(
        id: '1',
        content: 'old content',
        createdAt: '2024-01-01',
        likesCount: 5,
        retweetCount: 2,
        repliesCount: 1,
        quotesCount: 0,
        replyControl: 'everyone',
        tweetType: 'tweet',
        user: TweetUser(id: 'user1', name: 'John', username: 'john', verified: false, protectedAccount: false),
        mediaIds: [],
        mediaUrls: [],
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
      );

      final updated = item.copyWith(content: 'new content', likesCount: 10);

      expect(updated.content, 'new content');
      expect(updated.likesCount, 10);
    });

    test('toJson returns correct map', () {
      final item = MentionItem(
        id: '1',
        content: 'Test',
        createdAt: '2024-01-01',
        likesCount: 5,
        retweetCount: 2,
        repliesCount: 1,
        quotesCount: 0,
        replyControl: 'everyone',
        tweetType: 'tweet',
        user: TweetUser(id: 'user1', name: 'John', username: 'john', verified: false, protectedAccount: false),
        mediaIds: [],
        mediaUrls: [],
        isLiked: false,
        isRetweeted: false,
        isBookmarked: false,
      );

      final json = item.toJson();
      expect(json['id'], '1');
      expect(json['content'], 'Test');
    });
  });
}
