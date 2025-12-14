import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/notifications/notification_model.dart';

void main() {
  group('MediaInfo', () {
    test('creates instance from json', () {
      final json = {'url': 'https://example.com/image.jpg', 'keyName': 'test_key'};
      final mediaInfo = MediaInfo.fromJson(json);

      expect(mediaInfo.url, equals('https://example.com/image.jpg'));
      expect(mediaInfo.keyName, equals('test_key'));
    });

    test('copyWith updates url', () {
      final original = MediaInfo(url: 'url1', keyName: 'key1');
      final updated = original.copyWith(url: 'url2');

      expect(updated.url, equals('url2'));
      expect(updated.keyName, equals('key1'));
    });

    test('copyWith updates keyName', () {
      final original = MediaInfo(url: 'url1', keyName: 'key1');
      final updated = original.copyWith(keyName: 'key2');

      expect(updated.url, equals('url1'));
      expect(updated.keyName, equals('key2'));
    });

    test('copyWith returns same values when no parameters', () {
      final original = MediaInfo(url: 'url1', keyName: 'key1');
      final updated = original.copyWith();

      expect(updated.url, equals('url1'));
      expect(updated.keyName, equals('key1'));
    });

    test('toString returns expected format', () {
      final mediaInfo = MediaInfo(url: 'test_url', keyName: 'test_key');
      expect(mediaInfo.toString(), equals('MediaInfo(url: test_url, keyName: test_key)'));
    });
  });

  group('Actor', () {
    test('creates instance from json with all fields', () {
      final json = {
        'name': 'John Doe',
        'username': 'johndoe',
        'profileMediaId': '123',
      };
      final actor = Actor.fromJson(json);

      expect(actor.name, equals('John Doe'));
      expect(actor.username, equals('johndoe'));
      expect(actor.profileMediaId, equals('123'));
      expect(actor.media, isNull);
    });

    test('handles missing name', () {
      final json = {'username': 'test', 'profileMediaId': '123'};
      final actor = Actor.fromJson(json);

      expect(actor.name, equals(''));
    });

    test('handles null username', () {
      final json = {'name': 'Test', 'username': null, 'profileMediaId': '123'};
      final actor = Actor.fromJson(json);

      expect(actor.username, equals(''));
    });

    test('handles null profileMediaId', () {
      final json = {'name': 'Test', 'username': 'test', 'profileMediaId': null};
      final actor = Actor.fromJson(json);

      expect(actor.profileMediaId, equals(''));
    });

    test('copyWith updates name', () {
      final original = Actor(name: 'John', username: 'john', profileMediaId: '1');
      final updated = original.copyWith(name: 'Jane');

      expect(updated.name, equals('Jane'));
      expect(updated.username, equals('john'));
    });

    test('copyWith updates username', () {
      final original = Actor(name: 'John', username: 'john', profileMediaId: '1');
      final updated = original.copyWith(username: 'jane');

      expect(updated.username, equals('jane'));
      expect(updated.name, equals('John'));
    });

    test('copyWith updates profileMediaId', () {
      final original = Actor(name: 'John', username: 'john', profileMediaId: '1');
      final updated = original.copyWith(profileMediaId: '2');

      expect(updated.profileMediaId, equals('2'));
    });

    test('copyWith updates media', () {
      final original = Actor(name: 'John', username: 'john', profileMediaId: '1');
      final media = MediaInfo(url: 'url', keyName: 'key');
      final updated = original.copyWith(media: media);

      expect(updated.media, equals(media));
    });

    test('toString returns expected format', () {
      final actor = Actor(name: 'John', username: 'john', profileMediaId: '123');
      expect(actor.toString(), contains('Actor'));
      expect(actor.toString(), contains('John'));
      expect(actor.toString(), contains('john'));
    });
  });

  group('Notification', () {
    test('creates instance from json with all required fields', () {
      final json = {
        'id': '1',
        'title': 'Test Title',
        'body': 'Test Body',
        'isRead': false,
        'createdAt': '2024-01-01',
        'userId': 'user123',
        'tweetId': 'tweet456',
        'actorId': 'actor789',
        'actor': {
          'name': 'John',
          'username': 'john',
          'profileMediaId': '123',
        },
      };

      final notification = Notification.fromJson(json);

      expect(notification.id, equals('1'));
      expect(notification.title, equals('Test Title'));
      expect(notification.body, equals('Test Body'));
      expect(notification.isRead, isFalse);
      expect(notification.createdAt, equals('2024-01-01'));
      expect(notification.userId, equals('user123'));
      expect(notification.tweetId, equals('tweet456'));
      expect(notification.actorId, equals('actor789'));
      expect(notification.actor.name, equals('John'));
    });

    test('handles null tweetId', () {
      final json = {
        'id': '1',
        'title': 'Test',
        'body': 'Body',
        'isRead': true,
        'createdAt': '2024-01-01',
        'userId': 'user123',
        'tweetId': null,
        'actorId': 'actor789',
        'actor': {'name': 'John', 'username': 'john', 'profileMediaId': '123'},
      };

      final notification = Notification.fromJson(json);
      expect(notification.tweetId, isNull);
    });

    test('handles missing isRead defaults to false', () {
      final json = {
        'id': '1',
        'title': 'Test',
        'body': 'Body',
        'createdAt': '2024-01-01',
        'userId': 'user123',
        'actorId': 'actor789',
        'actor': {'name': 'John', 'username': 'john', 'profileMediaId': '123'},
      };

      final notification = Notification.fromJson(json);
      expect(notification.isRead, isFalse);
    });

    test('handles null id defaults to empty string', () {
      final json = {
        'id': null,
        'title': 'Test',
        'body': 'Body',
        'isRead': false,
        'createdAt': '2024-01-01',
        'userId': 'user123',
        'actorId': 'actor789',
        'actor': {'name': 'John', 'username': 'john', 'profileMediaId': '123'},
      };

      final notification = Notification.fromJson(json);
      expect(notification.id, equals(''));
    });

    test('handles null title defaults to empty string', () {
      final json = {
        'id': '1',
        'title': null,
        'body': 'Body',
        'isRead': false,
        'createdAt': '2024-01-01',
        'userId': 'user123',
        'actorId': 'actor789',
        'actor': {'name': 'John', 'username': 'john', 'profileMediaId': '123'},
      };

      final notification = Notification.fromJson(json);
      expect(notification.title, equals(''));
    });

    test('handles empty actor object', () {
      final json = <String, dynamic>{
        'id': '1',
        'title': 'Test',
        'body': 'Test Body',
        'isRead': false,
        'createdAt': '2024-01-01',
        'userId': 'user123',
        'actorId': 'actor789',
        'actor': <String, dynamic>{},
      };

      final notification = Notification.fromJson(json);
      expect(notification.actor.name, equals(''));
    });

    test('copyWith updates isRead', () {
      final original = Notification(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        userId: 'user123',
        actorId: 'actor789',
        actor: Actor(name: 'John', username: 'john', profileMediaId: '123'),
      );

      final updated = original.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.title, equals('Test'));
    });

    test('copyWith updates title', () {
      final original = Notification(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        userId: 'user123',
        actorId: 'actor789',
        actor: Actor(name: 'John', username: 'john', profileMediaId: '123'),
      );

      final updated = original.copyWith(title: 'New Title');
      expect(updated.title, equals('New Title'));
    });

    test('copyWith updates body', () {
      final original = Notification(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        userId: 'user123',
        actorId: 'actor789',
        actor: Actor(name: 'John', username: 'john', profileMediaId: '123'),
      );

      final updated = original.copyWith(body: 'New Body');
      expect(updated.body, equals('New Body'));
    });

    test('copyWith updates tweetId', () {
      final original = Notification(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        userId: 'user123',
        tweetId: 'tweet1',
        actorId: 'actor789',
        actor: Actor(name: 'John', username: 'john', profileMediaId: '123'),
      );

      final updated = original.copyWith(tweetId: 'tweet2');
      expect(updated.tweetId, equals('tweet2'));
    });

    test('copyWith updates actor', () {
      final original = Notification(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        userId: 'user123',
        actorId: 'actor789',
        actor: Actor(name: 'John', username: 'john', profileMediaId: '123'),
      );

      final newActor = Actor(name: 'Jane', username: 'jane', profileMediaId: '456');
      final updated = original.copyWith(actor: newActor);
      expect(updated.actor.name, equals('Jane'));
    });

    test('toString returns expected format', () {
      final notification = Notification(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        userId: 'user123',
        actorId: 'actor789',
        actor: Actor(name: 'John', username: 'john', profileMediaId: '123'),
      );

      final str = notification.toString();
      expect(str, contains('Notification'));
      expect(str, contains('Test'));
    });
  });

  group('EmbeddedTweet', () {
    test('creates instance from json', () {
      final json = {
        'id': 'tweet1',
        'content': 'Test tweet',
        'likesCount': 10,
        'retweetCount': 5,
        'repliesCount': 3,
        'isLiked': true,
        'isRetweeted': false,
      };

      final tweet = EmbeddedTweet.fromJson(json);
      expect(tweet.id, equals('tweet1'));
      expect(tweet.content, equals('Test tweet'));
      expect(tweet.likesCount, equals(10));
      expect(tweet.retweetCount, equals(5));
      expect(tweet.repliesCount, equals(3));
      expect(tweet.isLiked, isTrue);
      expect(tweet.isRetweeted, isFalse);
    });

    test('handles missing optional fields', () {
      final json = {
        'id': 'tweet1',
        'content': 'Test',
      };

      final tweet = EmbeddedTweet.fromJson(json);
      expect(tweet.id, equals('tweet1'));
      expect(tweet.content, equals('Test'));
    });
  });

  group('NotificationItem', () {
    test('creates instance with all fields', () {
      final actor = Actor(name: 'John', username: 'john', profileMediaId: '123');
      final item = NotificationItem(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        actor: actor,
        mediaUrl: 'https://example.com/image.jpg',
        tweetId: 'tweet1',
        repliesCount: 5,
        repostsCount: 3,
        likesCount: 10,
        isLiked: true,
        isRetweeted: false,
      );

      expect(item.id, equals('1'));
      expect(item.title, equals('Test'));
      expect(item.mediaUrl, equals('https://example.com/image.jpg'));
      expect(item.repliesCount, equals(5));
      expect(item.isLiked, isTrue);
    });

    test('handles null optional fields', () {
      final actor = Actor(name: 'John', username: 'john', profileMediaId: '123');
      final item = NotificationItem(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        actor: actor,
        mediaUrl: '',
        tweetId: null,
        quotedAuthor: null,
        quotedContent: null,
        repliesCount: 0,
        repostsCount: 0,
        likesCount: 0,
        isLiked: false,
        isRetweeted: false,
      );

      expect(item.tweetId, isNull);
      expect(item.quotedAuthor, isNull);
      expect(item.quotedContent, isNull);
    });

    test('copyWith updates isRead', () {
      final actor = Actor(name: 'John', username: 'john', profileMediaId: '123');
      final original = NotificationItem(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        actor: actor,
        mediaUrl: '',
        repliesCount: 0,
        repostsCount: 0,
        likesCount: 0,
        isLiked: false,
        isRetweeted: false,
      );

      final updated = original.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.title, equals('Test'));
    });

    test('copyWith updates likesCount and isLiked', () {
      final actor = Actor(name: 'John', username: 'john', profileMediaId: '123');
      final original = NotificationItem(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        actor: actor,
        mediaUrl: '',
        repliesCount: 0,
        repostsCount: 0,
        likesCount: 10,
        isLiked: false,
        isRetweeted: false,
      );

      final updated = original.copyWith(likesCount: 11, isLiked: true);
      expect(updated.likesCount, equals(11));
      expect(updated.isLiked, isTrue);
    });

    test('copyWith updates repostsCount and isRetweeted', () {
      final actor = Actor(name: 'John', username: 'john', profileMediaId: '123');
      final original = NotificationItem(
        id: '1',
        title: 'Test',
        body: 'Body',
        isRead: false,
        createdAt: '2024-01-01',
        actor: actor,
        mediaUrl: '',
        repliesCount: 0,
        repostsCount: 5,
        likesCount: 0,
        isLiked: false,
        isRetweeted: false,
      );

      final updated = original.copyWith(repostsCount: 6, isRetweeted: true);
      expect(updated.repostsCount, equals(6));
      expect(updated.isRetweeted, isTrue);
    });
  });
}
