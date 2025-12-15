import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normar_tweet_quot.dart';

void main() {
  late ProfileModel testProfileModel;
  late ProfileTweetModel testTweetModel;

  setUp(() {
    testProfileModel = ProfileModel(
      id: '1',
      username: 'testuser',
      displayName: 'Test User',
      bio: 'Test bio',
      followersCount: 100,
      followingCount: 50,
      tweetsCount: 10,
      isVerified: true,
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

    testTweetModel = ProfileTweetModel(
      id: 'tweet1',
      text: 'Test tweet in quote',
      timeAgo: '1h',
      likes: 10,
      retweets: 2,
      replies: 5,
      activityNumber: 100,
      isLikedByMe: false,
      isSavedByMe: false,
      isRepostedWithMe: false,
      quotesCount: 0,
      userId: '1',
      userUserName: 'testuser',
      userDisplayName: 'Test User',
      profileMediaId: 'avatar123',
      verified: true,
      protectedAccount: false,
      type: TweetType.Tweet,
      mediaIds: [],
      parentId: '',
      retweeterName: '',
      retweeterUserName: '',
      hashtags: [],
    );
  });

  group('ProfileNormarTweetQuot', () {
    testWidgets('should render widget successfully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileNormarTweetQuot(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ProfileNormarTweetQuot), findsOneWidget);
    });

    testWidgets('should render without actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileNormarTweetQuot(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ProfileNormarTweetQuot), findsOneWidget);
    });
  });
}
