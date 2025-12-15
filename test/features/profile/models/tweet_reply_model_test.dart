import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';

void main() {
  group('TweetReplyModel', () {
    group('fromJson', () {
      test('should create TweetReplyModel from valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'reply123',
          'userId': 'user123',
          'content': 'This is a reply',
          'createdAt': '2023-01-15T10:30:00.000Z',
          'lastActivityAt': '2023-01-15T11:00:00.000Z',
          'likesCount': 10,
          'retweetCount': 5,
          'repliesCount': 2,
          'quotesCount': 1,
          'replyControl': 'everyone',
          'parentId': 'parent123',
          'tweetType': 'reply',
          'user': {
            'id': 'user123',
            'name': 'Test User',
            'username': 'testuser',
            'profileMedia': 'media123',
            'protectedAccount': false,
            'verified': true,
          },
        };

        // Act
        final result = TweetReplyModel.fromJson(json);

        // Assert
        expect(result.id, 'reply123');
        expect(result.userId, 'user123');
        expect(result.content, 'This is a reply');
        expect(result.createdAt, '2023-01-15T10:30:00.000Z');
        expect(result.lastActivityAt, '2023-01-15T11:00:00.000Z');
        expect(result.likesCount, 10);
        expect(result.retweetCount, 5);
        expect(result.repliesCount, 2);
        expect(result.quotesCount, 1);
        expect(result.replyControl, 'everyone');
        expect(result.parentId, 'parent123');
        expect(result.tweetType, 'reply');
        expect(result.user.id, 'user123');
        expect(result.user.name, 'Test User');
        expect(result.user.verified, true);
      });

      test('should handle missing optional fields with defaults', () {
        // Arrange
        final json = {
          'user': <String, dynamic>{},
        };

        // Act
        final result = TweetReplyModel.fromJson(json);

        // Assert
        expect(result.id, '');
        expect(result.userId, '');
        expect(result.content, '');
        expect(result.likesCount, 0);
        expect(result.retweetCount, 0);
        expect(result.repliesCount, 0);
        expect(result.quotesCount, 0);
      });
    });

    group('toJson', () {
      test('should convert TweetReplyModel to JSON', () {
        // Arrange
        final user = UserReplyModel(
          id: 'user123',
          name: 'Test User',
          username: 'testuser',
          profileMedia: 'media123',
          protectedAccount: false,
          verified: true,
        );

        final reply = TweetReplyModel(
          id: 'reply123',
          userId: 'user123',
          content: 'Test reply',
          createdAt: '2023-01-15T10:30:00.000Z',
          lastActivityAt: '2023-01-15T11:00:00.000Z',
          likesCount: 10,
          retweetCount: 5,
          repliesCount: 2,
          quotesCount: 1,
          replyControl: 'everyone',
          parentId: 'parent123',
          tweetType: 'reply',
          user: user,
        );

        // Act
        final json = reply.toJson();

        // Assert
        expect(json['id'], 'reply123');
        expect(json['userId'], 'user123');
        expect(json['content'], 'Test reply');
        expect(json['likesCount'], 10);
        expect(json['user']['name'], 'Test User');
        expect(json['user']['verified'], true);
      });
    });
  });

  group('UserReplyModel', () {
    group('fromJson', () {
      test('should create UserReplyModel from valid JSON', () {
        // Arrange
        final json = {
          'id': 'user123',
          'name': 'Test User',
          'username': 'testuser',
          'profileMedia': 'media123',
          'protectedAccount': true,
          'verified': false,
        };

        // Act
        final result = UserReplyModel.fromJson(json);

        // Assert
        expect(result.id, 'user123');
        expect(result.name, 'Test User');
        expect(result.username, 'testuser');
        expect(result.profileMedia, 'media123');
        expect(result.protectedAccount, true);
        expect(result.verified, false);
      });

      test('should handle missing fields with defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final result = UserReplyModel.fromJson(json);

        // Assert
        expect(result.id, '');
        expect(result.name, '');
        expect(result.username, '');
        expect(result.profileMedia, null);
        expect(result.protectedAccount, false);
        expect(result.verified, false);
      });
    });

    group('toJson', () {
      test('should convert UserReplyModel to JSON', () {
        // Arrange
        final user = UserReplyModel(
          id: 'user123',
          name: 'Test User',
          username: 'testuser',
          profileMedia: 'media123',
          protectedAccount: true,
          verified: false,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], 'user123');
        expect(json['name'], 'Test User');
        expect(json['username'], 'testuser');
        expect(json['profileMedia'], 'media123');
        expect(json['protectedAccount'], true);
        expect(json['verified'], false);
      });
    });
  });
}
