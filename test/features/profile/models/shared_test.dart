import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_model.dart' hide mapMonth, formatDate, parseFormattedDate;
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_quote_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_retweet_widget.dart';
import 'package:lite_x/features/home/models/tweet_model.dart';

void main() {
  group('Shared.formatCount', () {
    test('should format count less than 1000 as is', () {
      expect(Shared.formatCount(0), '0');
      expect(Shared.formatCount(1), '1');
      expect(Shared.formatCount(999), '999');
    });

    test('should format count in thousands with K suffix', () {
      expect(Shared.formatCount(1000), '1.0K');
      expect(Shared.formatCount(1500), '1.5K');
      expect(Shared.formatCount(2000), '2.0K');
      expect(Shared.formatCount(999999), '1000.0K');
    });

    test('should format exact thousands without decimal', () {
      expect(Shared.formatCount(5000), '5.0K');
      expect(Shared.formatCount(10000), '10.0K');
    });

    test('should format count in millions with M suffix', () {
      expect(Shared.formatCount(1000000), '1.0M');
      expect(Shared.formatCount(1500000), '1.5M');
      expect(Shared.formatCount(2000000), '2.0M');
      expect(Shared.formatCount(999999999), '1000.0M');
    });

    test('should format exact millions without decimal', () {
      expect(Shared.formatCount(5000000), '5.0M');
      expect(Shared.formatCount(10000000), '10.0M');
    });
  });

  group('mapMonth', () {
    test('should return correct month name for each month number', () {
      expect(mapMonth(1), 'January');
      expect(mapMonth(2), 'February');
      expect(mapMonth(3), 'March');
      expect(mapMonth(4), 'April');
      expect(mapMonth(5), 'May');
      expect(mapMonth(6), 'June');
      expect(mapMonth(7), 'July');
      expect(mapMonth(8), 'August');
      expect(mapMonth(9), 'September');
      expect(mapMonth(10), 'October');
      expect(mapMonth(11), 'November');
      expect(mapMonth(12), 'December');
    });
  });

  group('formatDate', () {
    test('should return empty string for null date', () {
      expect(formatDate(null, DateFormatType.fullDate), '');
    });

    test('should format date as month and day only', () {
      final date = DateTime(2024, 3, 15);
      expect(formatDate(date, DateFormatType.monthAndDayOnly), 'March 15');
    });

    test('should format date as year only', () {
      final date = DateTime(2024, 3, 15);
      expect(formatDate(date, DateFormatType.yearOnly), '2024');
    });

    test('should format date as full date', () {
      final date = DateTime(2024, 3, 15);
      expect(formatDate(date, DateFormatType.fullDate), 'March 15, 2024');
    });

    test('should handle different months correctly', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 12, 31);
      
      expect(formatDate(date1, DateFormatType.fullDate), 'January 1, 2024');
      expect(formatDate(date2, DateFormatType.fullDate), 'December 31, 2024');
    });
  });

  group('parseFormattedDate', () {
    test('should return null for empty string', () {
      expect(parseFormattedDate(''), null);
    });

    test('should parse valid date string correctly', () {
      final result = parseFormattedDate('March 15, 2024');
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 3);
      expect(result.day, 15);
    });

    test('should parse different months correctly', () {
      final result1 = parseFormattedDate('January 1, 2024');
      expect(result1!.month, 1);
      
      final result2 = parseFormattedDate('December 31, 2024');
      expect(result2!.month, 12);
    });

    test('should return null for invalid format', () {
      expect(parseFormattedDate('invalid date'), null);
      expect(parseFormattedDate('15/03/2024'), null);
      expect(parseFormattedDate('March 2024'), null);
    });

    test('should handle single digit days', () {
      final result = parseFormattedDate('March 5, 2024');
      expect(result!.day, 5);
    });

    test('should handle double digit days', () {
      final result = parseFormattedDate('March 25, 2024');
      expect(result!.day, 25);
    });
  });

  group('getTimeAgo', () {
    test('should return seconds for time less than 60 seconds ago', () {
      final now = DateTime.now().toUtc();
      final time30SecondsAgo = now.subtract(Duration(seconds: 30));
      expect(getTimeAgo(time30SecondsAgo.toIso8601String()), '30s');
      
      final time45SecondsAgo = now.subtract(Duration(seconds: 45));
      expect(getTimeAgo(time45SecondsAgo.toIso8601String()), '45s');
    });

    test('should return minutes for time less than 60 minutes ago', () {
      final now = DateTime.now().toUtc();
      final time5MinutesAgo = now.subtract(Duration(minutes: 5));
      expect(getTimeAgo(time5MinutesAgo.toIso8601String()), '5m');
      
      final time30MinutesAgo = now.subtract(Duration(minutes: 30));
      expect(getTimeAgo(time30MinutesAgo.toIso8601String()), '30m');
    });

    test('should return hours for time less than 24 hours ago', () {
      final now = DateTime.now().toUtc();
      final time5HoursAgo = now.subtract(Duration(hours: 5));
      expect(getTimeAgo(time5HoursAgo.toIso8601String()), '5h');
      
      final time12HoursAgo = now.subtract(Duration(hours: 12));
      expect(getTimeAgo(time12HoursAgo.toIso8601String()), '12h');
    });

    test('should return days for time less than 7 days ago', () {
      final now = DateTime.now().toUtc();
      final time3DaysAgo = now.subtract(Duration(days: 3));
      expect(getTimeAgo(time3DaysAgo.toIso8601String()), '3d');
      
      final time6DaysAgo = now.subtract(Duration(days: 6));
      expect(getTimeAgo(time6DaysAgo.toIso8601String()), '6d');
    });

    test('should return weeks for time less than 30 days ago', () {
      final now = DateTime.now().toUtc();
      final time14DaysAgo = now.subtract(Duration(days: 14));
      expect(getTimeAgo(time14DaysAgo.toIso8601String()), '2w');
      
      final time21DaysAgo = now.subtract(Duration(days: 21));
      expect(getTimeAgo(time21DaysAgo.toIso8601String()), '3w');
    });

    test('should return months for time less than 365 days ago', () {
      final now = DateTime.now().toUtc();
      final time60DaysAgo = now.subtract(Duration(days: 60));
      expect(getTimeAgo(time60DaysAgo.toIso8601String()), '2mo');
      
      final time180DaysAgo = now.subtract(Duration(days: 180));
      expect(getTimeAgo(time180DaysAgo.toIso8601String()), '6mo');
    });

    test('should return years for time more than 365 days ago', () {
      final now = DateTime.now().toUtc();
      final time365DaysAgo = now.subtract(Duration(days: 365));
      expect(getTimeAgo(time365DaysAgo.toIso8601String()), '1y');
      
      final time730DaysAgo = now.subtract(Duration(days: 730));
      expect(getTimeAgo(time730DaysAgo.toIso8601String()), '2y');
    });

    test('should return now for negative difference (future time)', () {
      final now = DateTime.now().toUtc();
      final futureTime = now.add(Duration(hours: 1));
      expect(getTimeAgo(futureTime.toIso8601String()), 'now');
    });

    test('should return now for invalid date string', () {
      expect(getTimeAgo('invalid date'), 'now');
      expect(getTimeAgo(''), 'now');
    });

    test('should return 0s for very recent time (less than 1 second)', () {
      final now = DateTime.now().toUtc();
      expect(getTimeAgo(now.toIso8601String()), '0s');
    });
  });

  group('Failure', () {
    test('should create Failure with message', () {
      final failure = Failure('Error message');
      expect(failure.message, 'Error message');
    });
  });

  group('EditProfileStatus enum', () {
    test('should have correct enum values', () {
      expect(EditProfileStatus.changedSuccessfully, isNotNull);
      expect(EditProfileStatus.unChanged, isNotNull);
      expect(EditProfileStatus.failedToChange, isNotNull);
    });
  });

  group('DateFormatType enum', () {
    test('should have correct enum values', () {
      expect(DateFormatType.monthAndDayOnly, isNotNull);
      expect(DateFormatType.yearOnly, isNotNull);
      expect(DateFormatType.fullDate, isNotNull);
    });
  });

  group('TweetType enum', () {
    test('should have correct enum values', () {
      expect(TweetType.Tweet, isNotNull);
      expect(TweetType.ReTweet, isNotNull);
      expect(TweetType.Quote, isNotNull);
      expect(TweetType.Reply, isNotNull);
    });
  });

  group('ProfileTabType enum', () {
    test('should have correct enum values', () {
      expect(ProfileTabType.Posts, isNotNull);
      expect(ProfileTabType.Media, isNotNull);
      expect(ProfileTabType.Likes, isNotNull);
      expect(ProfileTabType.Replies, isNotNull);
      expect(ProfileTabType.Highlights, isNotNull);
      expect(ProfileTabType.Articles, isNotNull);
    });
  });

  group('RetweetOption enum', () {
    test('should have correct enum values', () {
      expect(RetweetOption.retweet, isNotNull);
      expect(RetweetOption.quote, isNotNull);
    });
  });

  group('FollowingFollowersInitialTab', () {
    test('should have correct constant values', () {
      expect(FollowingFollowersInitialTab.VerifiedFollowers, 0);
      expect(FollowingFollowersInitialTab.FollowersYouKnow, 1);
      expect(FollowingFollowersInitialTab.Followers, 2);
      expect(FollowingFollowersInitialTab.Following, 3);
      expect(FollowingFollowersInitialTab.Subscribed, 4);
      expect(FollowingFollowersInitialTab.Subscriptions, 5);
    });
  });

  group('ProfilePhotoScreenArgs', () {
    test('should create ProfilePhotoScreenArgs with correct values', () {
      final profileModel = ProfileModel(
        id: '123',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Bio',
        followersCount: 100,
        followingCount: 50,
        tweetsCount: 10,
        isVerified: false,
        joinedDate: 'January 2024',
        website: '',
        location: '',
        postCount: 10,
        birthDate: 'January 1, 2000',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: 'test@test.com',
        avatarId: 'avatar123',
        bannerId: 'banner123',
      );
      
      final args = ProfilePhotoScreenArgs(
        isMe: true,
        profileModel: profileModel,
      );
      
      expect(args.isMe, true);
      expect(args.profileModel, profileModel);
    });
  });

  group('unkownUserAvatar constant', () {
    test('should have correct default avatar URL', () {
      expect(unkownUserAvatar, contains('myloview.com'));
      expect(unkownUserAvatar, contains('default-avatar'));
    });
  });

  group('getCorrectTweetType', () {
    late ProfileModel testProfileModel;
    late ProfileTweetModel normalTweet;
    late ProfileTweetModel quoteTweet;
    late ProfileTweetModel retweetTweet;

    setUp(() {
      testProfileModel = ProfileModel(
        id: '123',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Bio',
        followersCount: 100,
        followingCount: 50,
        tweetsCount: 10,
        isVerified: false,
        joinedDate: 'January 2024',
        website: '',
        location: '',
        postCount: 10,
        birthDate: 'January 1, 2000',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: 'test@test.com',
        avatarId: 'avatar123',
        bannerId: 'banner123',
      );

      normalTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Normal tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 2,
        replies: 5,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '123',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: 'avatar123',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      quoteTweet = ProfileTweetModel(
        id: 'tweet2',
        text: 'Quote tweet',
        timeAgo: '2h',
        likes: 20,
        retweets: 5,
        replies: 10,
        activityNumber: 200,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 1,
        userId: '123',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: 'avatar123',
        verified: false,
        protectedAccount: false,
        type: TweetType.Quote,
        mediaIds: [],
        parentId: 'parent123',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      retweetTweet = ProfileTweetModel(
        id: 'tweet3',
        text: 'Retweet',
        timeAgo: '3h',
        likes: 30,
        retweets: 10,
        replies: 15,
        activityNumber: 300,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: true,
        quotesCount: 0,
        userId: '456',
        userUserName: 'originaluser',
        userDisplayName: 'Original User',
        profileMediaId: 'avatar456',
        verified: false,
        protectedAccount: false,
        type: TweetType.ReTweet,
        mediaIds: [],
        parentId: '',
        retweeterName: 'Retweeter',
        retweeterUserName: 'retweeteruser',
        hashtags: [],
      );
    });

    test('should return ProfileNormalTweetWidget for normal tweet', () {
      final result = getCorrectTweetType(normalTweet, testProfileModel);
      expect(result, isA<ProfileNormalTweetWidget>());
    });

    test('should return ProfileQuoteWidget for quote tweet', () {
      final result = getCorrectTweetType(quoteTweet, testProfileModel);
      expect(result, isA<ProfileQuoteWidget>());
    });

    test('should return ProfileRetweetWidget when retweeter username exists', () {
      final result = getCorrectTweetType(retweetTweet, testProfileModel);
      expect(result, isA<ProfileRetweetWidget>());
    });

    test('should prioritize retweet over quote type', () {
      final retweetQuote = ProfileTweetModel(
        id: 'tweet4',
        text: 'Retweet of quote',
        timeAgo: '4h',
        likes: 40,
        retweets: 15,
        replies: 20,
        activityNumber: 400,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: true,
        quotesCount: 0,
        userId: '789',
        userUserName: 'anotheruser',
        userDisplayName: 'Another User',
        profileMediaId: 'avatar789',
        verified: false,
        protectedAccount: false,
        type: TweetType.Quote,
        mediaIds: [],
        parentId: 'parent456',
        retweeterName: 'Retweeter',
        retweeterUserName: 'retweeteruser',
        hashtags: [],
      );

      final result = getCorrectTweetType(retweetQuote, testProfileModel);
      expect(result, isA<ProfileRetweetWidget>());
    });

    test('should handle Reply type as normal tweet', () {
      final replyTweet = ProfileTweetModel(
        id: 'tweet5',
        text: 'Reply tweet',
        timeAgo: '5h',
        likes: 50,
        retweets: 20,
        replies: 25,
        activityNumber: 500,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '123',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: 'avatar123',
        verified: false,
        protectedAccount: false,
        type: TweetType.Reply,
        mediaIds: [],
        parentId: 'parent789',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final result = getCorrectTweetType(replyTweet, testProfileModel);
      expect(result, isA<ProfileNormalTweetWidget>());
    });
  });

  group('TrendsCategoriesTabs', () {
    test('should have correct constant values', () {
      expect(TrendsCategoriesTabs.Global, 'global');
      expect(TrendsCategoriesTabs.News, 'news');
      expect(TrendsCategoriesTabs.Sports, 'Sports');
      expect(TrendsCategoriesTabs.Entertainment, 'entertainment');
    });
  });

  group('convertJsonListToTweetList', () {
    test('should convert JSON list to ProfileTweetModel list', () {
      final jsonList = [
        {
          "id": "tweet1",
          "content": "Test tweet",
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "likesCount": 10,
          "retweetCount": 5,
          "repliesCount": 3,
          "activityNumber": 100,
          "isLiked": false,
          "isBookmarked": false,
          "isRetweeted": false,
          "quotesCount": 0,
          "tweetType": "TWEET",
          "user": {
            "id": "user1",
            "username": "testuser",
            "name": "Test User",
            "verified": false,
            "protectedAccount": false,
            "profileMedia": {
              "id": "avatar123"
            }
          },
          "tweetMedia": [
            {
              "media": {
                "id": "media1"
              }
            }
          ],
          "parent": null,
          "retweeter": null,
          "hashtags": [],
          "profileMediaId": "avatar123",
          "mediaIds": ["media1"],
          "timeAgo": "1h",
          "parentId": ""
        }
      ];

      final result = convertJsonListToTweetList(jsonList, false);
      
      expect(result.length, 1);
      expect(result[0].id, 'tweet1');
      expect(result[0].text, 'Test tweet');
      expect(result[0].profileMediaId, 'avatar123');
      expect(result[0].mediaIds, ['media1']);
    });

    test('should skip reply tweets when getReplies is false', () {
      final jsonList = [
        {
          "id": "tweet1",
          "content": "Normal tweet",
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "likesCount": 10,
          "retweetCount": 5,
          "repliesCount": 3,
          "activityNumber": 100,
          "isLiked": false,
          "isBookmarked": false,
          "isRetweeted": false,
          "quotesCount": 0,
          "tweetType": "TWEET",
          "user": {
            "id": "user1",
            "username": "testuser",
            "name": "Test User",
            "verified": false,
            "protectedAccount": false,
            "profileMedia": {"id": "avatar123"}
          },
          "tweetMedia": [],
          "parent": null,
          "retweeter": null,
          "hashtags": [],
          "profileMediaId": "avatar123",
          "mediaIds": [],
          "timeAgo": "1h",
          "parentId": ""
        },
        {
          "id": "tweet2",
          "content": "Reply tweet",
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "likesCount": 5,
          "retweetCount": 2,
          "repliesCount": 1,
          "activityNumber": 50,
          "isLiked": false,
          "isBookmarked": false,
          "isRetweeted": false,
          "quotesCount": 0,
          "tweetType": "reply",
          "user": {
            "id": "user2",
            "username": "replyuser",
            "name": "Reply User",
            "verified": false,
            "protectedAccount": false,
            "profileMedia": {"id": "avatar456"}
          },
          "tweetMedia": [],
          "parent": {"id": "parent1"},
          "retweeter": null,
          "hashtags": [],
          "profileMediaId": "avatar456",
          "mediaIds": [],
          "timeAgo": "2h",
          "parentId": "parent1"
        }
      ];

      final result = convertJsonListToTweetList(jsonList, false);
      
      expect(result.length, 1);
      expect(result[0].id, 'tweet1');
    });

    test('should include reply tweets when getReplies is true', () {
      final jsonList = [
        {
          "id": "tweet1",
          "content": "Reply tweet",
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "likesCount": 5,
          "retweetCount": 2,
          "repliesCount": 1,
          "activityNumber": 50,
          "isLiked": false,
          "isBookmarked": false,
          "isRetweeted": false,
          "quotesCount": 0,
          "tweetType": "Reply",
          "user": {
            "id": "user2",
            "username": "replyuser",
            "name": "Reply User",
            "verified": false,
            "protectedAccount": false,
            "profileMedia": {"id": "avatar456"}
          },
          "tweetMedia": [],
          "parent": {"id": "parent1"},
          "retweeter": null,
          "hashtags": [],
          "profileMediaId": "avatar456",
          "mediaIds": [],
          "timeAgo": "1h",
          "parentId": "parent1"
        }
      ];

      final result = convertJsonListToTweetList(jsonList, true);
      
      expect(result.length, 1);
      expect(result[0].id, 'tweet1');
    });

    test('should handle empty media list', () {
      final jsonList = [
        {
          "id": "tweet1",
          "content": "No media tweet",
          "createdAt": DateTime.now().toUtc().toIso8601String(),
          "likesCount": 0,
          "retweetCount": 0,
          "repliesCount": 0,
          "activityNumber": 0,
          "isLiked": false,
          "isBookmarked": false,
          "isRetweeted": false,
          "quotesCount": 0,
          "tweetType": "TWEET",
          "user": {
            "id": "user1",
            "username": "testuser",
            "name": "Test User",
            "verified": false,
            "protectedAccount": false,
            "profileMedia": null
          },
          "tweetMedia": [],
          "parent": null,
          "retweeter": null,
          "hashtags": [],
          "profileMediaId": "",
          "mediaIds": [],
          "timeAgo": "1h",
          "parentId": ""
        }
      ];

      final result = convertJsonListToTweetList(jsonList, false);
      
      expect(result.length, 1);
      expect(result[0].mediaIds, isEmpty);
      expect(result[0].profileMediaId, '');
    });
  });

  group('fromProfileTweetModel', () {
    test('should convert ProfileTweetModel to TweetModel with Tweet type', () {
      final profileTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '2h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: true,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: 'avatar1',
        verified: true,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: ['media1', 'media2'],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final result = fromProfileTweetModel(profileTweet);

      expect(result.id, 'tweet1');
      expect(result.content, 'Test tweet');
      expect(result.authorName, 'Test User');
      expect(result.authorUsername, 'testuser');
      expect(result.likes, 10);
      expect(result.retweets, 5);
      expect(result.replies, 3);
      expect(result.isLiked, true);
      expect(result.isRetweeted, false);
      expect(result.isBookmarked, false);
      expect(result.tweetType, 'TWEET');
      expect(result.replyToId, null);
      expect(result.quotedTweetId, null);
    });

    test('should convert ProfileTweetModel with Quote type', () {
      final profileTweet = ProfileTweetModel(
        id: 'tweet2',
        text: 'Quote tweet',
        timeAgo: '3h',
        likes: 20,
        retweets: 10,
        replies: 5,
        activityNumber: 200,
        isLikedByMe: false,
        isSavedByMe: true,
        isRepostedWithMe: true,
        quotesCount: 2,
        userId: 'user2',
        userUserName: 'quoteuser',
        userDisplayName: 'Quote User',
        profileMediaId: 'avatar2',
        verified: false,
        protectedAccount: false,
        type: TweetType.Quote,
        mediaIds: [],
        parentId: 'parent123',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final result = fromProfileTweetModel(profileTweet);

      expect(result.tweetType, 'QUOTE');
      expect(result.quotedTweetId, 'parent123');
      expect(result.replyToId, null);
      expect(result.isBookmarked, true);
    });

    test('should convert ProfileTweetModel with Reply type', () {
      final profileTweet = ProfileTweetModel(
        id: 'tweet3',
        text: 'Reply tweet',
        timeAgo: '1h',
        likes: 5,
        retweets: 2,
        replies: 1,
        activityNumber: 50,
        isLikedByMe: true,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user3',
        userUserName: 'replyuser',
        userDisplayName: 'Reply User',
        profileMediaId: 'avatar3',
        verified: true,
        protectedAccount: true,
        type: TweetType.Reply,
        mediaIds: [],
        parentId: 'parent456',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final result = fromProfileTweetModel(profileTweet);

      expect(result.tweetType, 'REPLY');
      expect(result.replyToId, 'parent456');
      expect(result.quotedTweetId, null);
    });

    test('should handle mediaIds correctly', () {
      final profileTweet = ProfileTweetModel(
        id: 'tweet4',
        text: 'Tweet with media',
        timeAgo: '4h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user4',
        userUserName: 'mediauser',
        userDisplayName: 'Media User',
        profileMediaId: 'avatar4',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: ['media1', 'media2', 'media3'],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final result = fromProfileTweetModel(profileTweet);

      expect(result.images.length, 3);
      expect(result.images, ['media1', 'media2', 'media3']);
    });
  });
}
