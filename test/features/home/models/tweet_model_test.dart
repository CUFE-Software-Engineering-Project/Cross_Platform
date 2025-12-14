import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';

void main() {
  group('TweetModel Tests', () {
    final testDate = DateTime(2024, 1, 1);

    test('creates TweetModel with required fields', () {
      final tweet = TweetModel(
        id: '123',
        content: 'Test tweet content',
        authorName: 'Test User',
        authorUsername: 'testuser',
        authorAvatar: 'avatar123',
        createdAt: testDate,
      );

      expect(tweet.id, '123');
      expect(tweet.content, 'Test tweet content');
      expect(tweet.authorName, 'Test User');
      expect(tweet.authorUsername, 'testuser');
      expect(tweet.authorAvatar, 'avatar123');
      expect(tweet.createdAt, testDate);
      expect(tweet.likes, 0);
      expect(tweet.retweets, 0);
      expect(tweet.replies, 0);
      expect(tweet.isLiked, false);
      expect(tweet.isRetweeted, false);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = TweetModel(
        id: '123',
        content: 'Original content',
        authorName: 'Test User',
        authorUsername: 'testuser',
        authorAvatar: 'avatar123',
        createdAt: testDate,
        likes: 10,
        isLiked: false,
      );

      final updated = original.copyWith(likes: 20, isLiked: true);

      expect(updated.likes, 20);
      expect(updated.isLiked, true);
      expect(updated.content, 'Original content'); // unchanged
      expect(updated.id, '123'); // unchanged
    });

    test('toJson returns correct map', () {
      final tweet = TweetModel(
        id: '123',
        content: 'Test content',
        authorName: 'Test User',
        authorUsername: 'testuser',
        authorAvatar: 'avatar123',
        createdAt: testDate,
        likes: 10,
        retweets: 5,
      );

      final json = tweet.toJson();

      expect(json['id'], '123');
      expect(json['content'], 'Test content');
      expect(json['authorName'], 'Test User');
      expect(json['authorUsername'], 'testuser');
      expect(json['likes'], 10);
      expect(json['retweets'], 5);
      expect(json['createdAt'], testDate.toIso8601String());
    });

    test('fromJson creates TweetModel from basic JSON', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'likesCount': 10,
        'retweetCount': 5,
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.id, '123');
      expect(tweet.content, 'Test content');
      expect(tweet.authorName, 'Test User');
      expect(tweet.authorUsername, 'testuser');
      expect(tweet.likes, 10);
      expect(tweet.retweets, 5);
    });

    test('fromJson handles alternative field names', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'name': 'Test User',
        'username': 'testuser',
        'createdAt': testDate.toIso8601String(),
        'likes': 10,
        'retweets': 5,
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.authorName, 'Test User');
      expect(tweet.authorUsername, 'testuser');
      expect(tweet.likes, 10);
      expect(tweet.retweets, 5);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.likes, 0);
      expect(tweet.retweets, 0);
      expect(tweet.replies, 0);
      expect(tweet.isLiked, false);
      expect(tweet.isRetweeted, false);
      expect(tweet.isBookmarked, false);
      expect(tweet.tweetType, 'TWEET');
    });

    test('fromJson detects QUOTE tweet type from quotedTweetId', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'quotedTweetId': '456',
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.tweetType, 'QUOTE');
      expect(tweet.quotedTweetId, '456');
    });

    test('fromJson detects REPLY tweet type from parentId', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'parentId': '456',
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.tweetType, 'REPLY');
      expect(tweet.replyToId, '456');
    });

    test('fromJson parses nested quotedTweet', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'quotedTweet': {
          'id': '456',
          'content': 'Quoted content',
          'user': {'name': 'Another User', 'username': 'anotheruser'},
          'createdAt': testDate.toIso8601String(),
        },
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.quotedTweet, isNotNull);
      expect(tweet.quotedTweet!.id, '456');
      expect(tweet.quotedTweet!.content, 'Quoted content');
    });

    test('fromJson extracts hashtags from JSON', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'hashtags': [
          {
            'hash': {'id': '1', 'tag_text': 'flutter'},
          },
          {
            'hash': {'id': '2', 'tag_text': 'dart'},
          },
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.hashtags.length, 2);
      expect(tweet.hashtags[0].tagText, 'flutter');
      expect(tweet.hashtags[1].tagText, 'dart');
    });

    test('fromJson extracts categories from tweetCategories', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'tweetCategories': [
          {
            'category': {'name': 'technology'},
          },
          {
            'category': {'name': 'news'},
          },
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.categories.length, 2);
      expect(tweet.categories, contains('technology'));
      expect(tweet.categories, contains('news'));
    });

    test('fromJson handles verified and protected flags', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {
          'name': 'Test User',
          'username': 'testuser',
          'verified': true,
          'protectedAccount': true,
        },
        'createdAt': testDate.toIso8601String(),
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.isVerified, true);
      expect(tweet.isProtected, true);
    });

    test('fromJson extracts retweetedByUsernames', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'retweets': {
          'data': [
            {'username': 'user1'},
            {'username': 'user2'},
          ],
        },
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.retweetedByUsernames.length, 2);
      expect(tweet.retweetedByUsernames, contains('user1'));
      expect(tweet.retweetedByUsernames, contains('user2'));
    });

    test('fromJson handles image media extraction', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'images': ['image1.jpg', 'image2.jpg'],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.images.length, 2);
      expect(tweet.images, contains('image1.jpg'));
      expect(tweet.images, contains('image2.jpg'));
    });

    test('fromJson handles recommendation score and reasons', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'score': 0.95,
        'reasons': ['from_following', 'trending'],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.recommendationScore, 0.95);
      expect(tweet.recommendationReasons.length, 2);
      expect(tweet.isFollowed, true); // from_following reason
    });
  });

  group('TweetHashtag Tests', () {
    test('creates TweetHashtag correctly', () {
      const hashtag = TweetHashtag(id: '123', tagText: 'flutter');

      expect(hashtag.id, '123');
      expect(hashtag.tagText, 'flutter');
    });

    test('toJson returns correct map', () {
      const hashtag = TweetHashtag(id: '123', tagText: 'flutter');

      final json = hashtag.toJson();

      expect(json['id'], '123');
      expect(json['tag_text'], 'flutter');
    });
  });

  group('TweetModel Additional Coverage Tests', () {
    final testDate = DateTime(2024, 1, 1);

    test('fromJson handles parent as quotedTweet', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'parent': {
          'id': '456',
          'content': 'Parent content',
          'user': {'name': 'Parent User', 'username': 'parentuser'},
          'createdAt': testDate.toIso8601String(),
        },
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.quotedTweet, isNotNull);
      expect(tweet.quotedTweet!.id, '456');
      expect(tweet.quotedTweet!.content, 'Parent content');
    });

    test('fromJson handles parentTweet as quotedTweet', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'parentTweet': {
          'id': '456',
          'content': 'Parent tweet content',
          'user': {'name': 'Parent User', 'username': 'parentuser'},
          'createdAt': testDate.toIso8601String(),
        },
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.quotedTweet, isNotNull);
      expect(tweet.quotedTweet!.id, '456');
    });

    test('fromJson handles media as media source', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'media': ['media1.jpg', 'media2.jpg'],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.images.length, 2);
      expect(tweet.images, contains('media1.jpg'));
    });

    test('fromJson handles tweetMedia as media source', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'tweetMedia': [
          {'url': 'media1.jpg'},
          {'mediaUrl': 'media2.jpg'},
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.images.length, 2);
    });

    test('fromJson handles mediaIds as media source', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'mediaIds': ['id1', 'id2'],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.images.length, 2);
    });

    test('fromJson handles nested media in media array', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'media': [
          {
            'media': {'url': 'nested1.jpg'},
          },
          {
            'media': {'keyName': 'nested2.jpg'},
          },
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.images.length, 2);
    });

    test('fromJson handles profileMedia as string', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {
          'name': 'Test User',
          'username': 'testuser',
          'profileMedia': 'avatar123',
        },
        'createdAt': testDate.toIso8601String(),
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.authorAvatar, 'avatar123');
    });

    test('fromJson handles profileMedia as object with id', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {
          'name': 'Test User',
          'username': 'testuser',
          'profileMedia': {'id': 'avatar456'},
        },
        'createdAt': testDate.toIso8601String(),
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.authorAvatar, 'avatar456');
    });

    test('fromJson handles profilePicture fallback', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {
          'name': 'Test User',
          'username': 'testuser',
          'profilePicture': 'pic123',
        },
        'createdAt': testDate.toIso8601String(),
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.authorAvatar, 'pic123');
    });

    test('fromJson handles profileMediaKey field', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'profileMediaKey': 'key123',
        'createdAt': testDate.toIso8601String(),
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.authorAvatar, 'key123');
    });

    test('fromJson handles string values for numeric fields', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'likesCount': '42',
        'retweetCount': '10',
        'score': '0.85',
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.likes, 42);
      expect(tweet.retweets, 10);
      expect(tweet.recommendationScore, 0.85);
    });

    test('fromJson handles double values for integer fields', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'likesCount': 42.7,
        'retweetCount': 10.3,
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.likes, 43);
      expect(tweet.retweets, 10);
    });

    test('fromJson handles hashtags as strings', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'hashtags': ['flutter', 'dart', 'mobile'],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.hashtags.length, 3);
      expect(tweet.hashtags[0].tagText, 'flutter');
      expect(tweet.hashtags[1].tagText, 'dart');
    });

    test('fromJson handles hashtags with hashId field', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'hashtags': [
          {'hashId': 'hash123'},
          {'hashId': 'hash456'},
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.hashtags.length, 2);
      expect(tweet.hashtags[0].id, 'hash123');
    });

    test('fromJson handles hashtags with id and tag_text', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'hashtags': [
          {'id': 'id1', 'tag_text': 'flutter'},
          {'id': 'id2', 'tag_text': 'dart'},
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.hashtags.length, 2);
      expect(tweet.hashtags[0].tagText, 'flutter');
    });

    test('fromJson handles categories with direct name field', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'tweetCategories': [
          {'name': 'tech'},
          {'name': 'news'},
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.categories.length, 2);
      expect(tweet.categories, contains('tech'));
    });

    test('fromJson handles categories as strings', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'tweetCategories': ['sports', 'entertainment'],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.categories.length, 2);
      expect(tweet.categories, contains('sports'));
    });

    test('fromJson handles empty retweets data', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'retweets': {'data': []},
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.retweetedByUsernames, isEmpty);
    });

    test('fromJson handles retweets with trimming', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'retweets': {
          'data': [
            {'username': '  user1  '},
            {'username': ''},
            {'username': 'user2'},
          ],
        },
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.retweetedByUsernames.length, 2);
      expect(tweet.retweetedByUsernames, contains('user1'));
    });

    test('fromJson handles tweetType normalization', () {
      final json1 = {
        'id': '123',
        'content': 'Test',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'tweetType': 'retweet',
      };

      final tweet1 = TweetModel.fromJson(json1);
      expect(tweet1.tweetType, 'RETWEET');

      final json2 = {
        'id': '124',
        'content': 'Test',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'type': 'repost',
      };

      final tweet2 = TweetModel.fromJson(json2);
      expect(tweet2.tweetType, 'REPOST');
    });

    test('fromJson handles quotedTweetId for QUOTE type with parentId', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'tweetType': 'QUOTE',
        'parentId': '789',
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.tweetType, 'QUOTE');
      expect(tweet.quotedTweetId, '789');
    });

    test('fromJson handles invalid score value', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'score': 'invalid',
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.recommendationScore, isNull);
    });

    test('fromJson handles various media field alternatives', () {
      final json = {
        'id': '123',
        'content': 'Test content',
        'user': {'name': 'Test User', 'username': 'testuser'},
        'createdAt': testDate.toIso8601String(),
        'media': [
          {'media_url': 'url1.jpg'},
          {'path': 'url2.jpg'},
          {'mediaId': 'url3.jpg'},
          {'media_id': 'url4.jpg'},
          {'id': 'url5.jpg'},
        ],
      };

      final tweet = TweetModel.fromJson(json);

      expect(tweet.images.length, 5);
    });

    test('copyWith updates all fields correctly', () {
      final original = TweetModel(
        id: '123',
        content: 'Original',
        authorName: 'User',
        authorUsername: 'user',
        authorAvatar: 'avatar',
        createdAt: testDate,
      );

      final updated = original.copyWith(
        content: 'Updated',
        likes: 100,
        retweets: 50,
        replies: 10,
        isLiked: true,
        isRetweeted: true,
        isBookmarked: true,
        recommendationScore: 0.9,
        recommendationReasons: ['trending'],
        replyControl: 'FOLLOWERS',
        isFollowed: true,
        hashtags: [const TweetHashtag(id: '1', tagText: 'test')],
        categories: ['tech'],
        retweetedByUsernames: ['user1'],
      );

      expect(updated.content, 'Updated');
      expect(updated.likes, 100);
      expect(updated.isLiked, true);
      expect(updated.recommendationScore, 0.9);
      expect(updated.hashtags.length, 1);
    });
  });
}
