import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';

void main() {
  group('ProfileTweetModel', () {
    group('fromJson', () {
      test('should create ProfileTweetModel from valid JSON - Tweet type', () {
        // Arrange
        final json = {
          'id': 'tweet123',
          'content': 'This is a test tweet',
          'timeAgo': '2h',
          'likesCount': 100,
          'retweetCount': 50,
          'repliesCount': 25,
          'quotesCount': 10,
          'isLiked': true,
          'isRetweeted': false,
          'activityNumber': 1000,
          'isBookmarked': true,
          'mediaIds': ['media1', 'media2'],
          'tweetType': 'TWEET',
          'user': {
            'name': 'Test User',
            'id': 'user123',
            'username': 'testuser',
            'protectedAccount': false,
            'verified': true,
          },
          'profileMediaId': 'profileMedia123',
          'parentId': '',
          'retweeter': {},
          'hashtags': [],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.id, 'tweet123');
        expect(result.text, 'This is a test tweet');
        expect(result.timeAgo, '2h');
        expect(result.likes, 100);
        expect(result.retweets, 50);
        expect(result.replies, 25);
        expect(result.quotesCount, 10);
        expect(result.isLikedByMe, true);
        expect(result.isRepostedWithMe, false);
        expect(result.isSavedByMe, true);
        expect(result.type, TweetType.Tweet);
        expect(result.userDisplayName, 'Test User');
        expect(result.userId, 'user123');
        expect(result.userUserName, 'testuser');
        expect(result.verified, true);
        expect(result.protectedAccount, false);
      });

      test('should parse ReTweet type correctly', () {
        // Arrange
        final json = {
          'id': 'retweet123',
          'content': 'Retweeted content',
          'tweetType': 'RETWEET',
          'user': {},
          'retweeter': {
            'name': 'Retweeter Name',
            'username': 'retweeter',
          },
          'hashtags': [],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.type, TweetType.ReTweet);
        expect(result.retweeterName, 'Retweeter Name');
        expect(result.retweeterUserName, 'retweeter');
      });

      test('should parse Quote type correctly', () {
        // Arrange
        final json = {
          'id': 'quote123',
          'content': 'Quote tweet',
          'tweetType': 'QUOTE',
          'user': {},
          'hashtags': [],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.type, TweetType.Quote);
      });

      test('should parse Reply type correctly', () {
        // Arrange
        final json = {
          'id': 'reply123',
          'content': 'Reply tweet',
          'tweetType': 'REPLY',
          'parentId': 'parent123',
          'user': {},
          'hashtags': [],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.type, TweetType.Reply);
        expect(result.parentId, 'parent123');
      });

      test('should handle hashtags correctly', () {
        // Arrange
        final json = {
          'id': 'tweet123',
          'content': 'Tweet with hashtags',
          'user': {},
          'hashtags': [
            {
              'hash': {
                'id': 'hash1',
                'tag_text': 'flutter',
              }
            },
            {
              'hash': {
                'id': 'hash2',
                'tag_text': 'dart',
              }
            },
          ],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.hashtags.length, 2);
        expect(result.hashtags[0]['hashtagName'], 'flutter');
        expect(result.hashtags[0]['id'], 'hash1');
        expect(result.hashtags[1]['hashtagName'], 'dart');
        expect(result.hashtags[1]['id'], 'hash2');
      });

      test('should handle missing optional fields with defaults', () {
        // Arrange
        final json = {
          'user': {},
          'hashtags': [],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.id, '');
        expect(result.text, '');
        expect(result.timeAgo, '');
        expect(result.likes, 0);
        expect(result.retweets, 0);
        expect(result.replies, 0);
        expect(result.quotesCount, 0);
        expect(result.isLikedByMe, false);
        expect(result.isRepostedWithMe, false);
        expect(result.isSavedByMe, false);
        expect(result.activityNumber, 0);
        expect(result.type, TweetType.Tweet);
        expect(result.mediaIds.isEmpty, true);
      });

      test('should handle null tweetType as Tweet', () {
        // Arrange
        final json = {
          'id': 'tweet123',
          'content': 'No type specified',
          'user': {},
          'hashtags': [],
          'tweetMedia': [],
        };

        // Act
        final result = ProfileTweetModel.fromJson(json);

        // Assert
        expect(result.type, TweetType.Tweet);
      });
    });
  });
}
