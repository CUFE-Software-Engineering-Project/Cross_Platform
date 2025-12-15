import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_normal_tweet_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_quote_widget.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_retweet_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

// Test notifier that returns a specific user
class TestCurrentUser extends CurrentUser {
  final UserModel? testUser;
  TestCurrentUser(this.testUser);
  
  @override
  UserModel? build() {
    return testUser;
  }
}

void main() {
  late ProfileModel testProfileModel;
  late ProfileTweetModel retweetModel;
  late ProfileTweetModel quoteRetweetModel;
  late ProfileTweetModel parentTweetModel;

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

    retweetModel = ProfileTweetModel(
      id: 'retweet1',
      text: 'Retweeted content',
      timeAgo: '1h',
      likes: 10,
      retweets: 2,
      replies: 5,
      activityNumber: 100,
      isLikedByMe: false,
      isSavedByMe: false,
      isRepostedWithMe: true,
      quotesCount: 0,
      userId: '2',
      userUserName: 'originaluser',
      userDisplayName: 'Original User',
      profileMediaId: 'avatar456',
      verified: false,
      protectedAccount: false,
      type: TweetType.ReTweet,
      mediaIds: [],
      parentId: '',
      retweeterName: 'Test User',
      retweeterUserName: 'testuser',
      hashtags: [],
    );

    parentTweetModel = ProfileTweetModel(
      id: 'parent1',
      text: 'Parent tweet text',
      timeAgo: '2h',
      likes: 50,
      retweets: 10,
      replies: 20,
      activityNumber: 500,
      isLikedByMe: false,
      isSavedByMe: false,
      isRepostedWithMe: false,
      quotesCount: 2,
      userId: '2',
      userUserName: 'parentuser',
      userDisplayName: 'Parent User',
      profileMediaId: 'avatar456',
      verified: false,
      protectedAccount: false,
      type: TweetType.Tweet,
      mediaIds: [],
      parentId: '',
      retweeterName: '',
      retweeterUserName: '',
      hashtags: [],
    );

    quoteRetweetModel = ProfileTweetModel(
      id: 'quote1',
      text: 'Quote retweet text',
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
      type: TweetType.Quote,
      mediaIds: [],
      parentId: 'parent1',
      retweeterName: 'Another User',
      retweeterUserName: 'anotheruser',
      hashtags: [],
    );
  });

  group('ProfileRetweetWidget', () {
    testWidgets('should render normal retweet widget with retweeter name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileRetweetWidget(
                profileModel: testProfileModel,
                tweetModel: retweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProfileRetweetWidget), findsOneWidget);
      expect(find.byType(ProfileNormalTweetWidget), findsOneWidget);
      expect(find.text('Test User reposted'), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('should show "You reposted" when current user is the retweeter', (tester) async {
      final currentUser = UserModel(
        id: '1',
        username: 'testuser',
        name: 'Test User',
        email: 'test@test.com',
        dob: '1990-01-01',
        isEmailVerified: true,
        isVerified: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(() => TestCurrentUser(currentUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileRetweetWidget(
                profileModel: testProfileModel,
                tweetModel: retweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('You reposted'), findsOneWidget);
      expect(find.byType(ProfileRetweetWidget), findsOneWidget);
      expect(find.byType(ProfileNormalTweetWidget), findsOneWidget);
    });

    testWidgets('should show retweeter name when current user is different', (tester) async {
      final differentUser = UserModel(
        id: '2',
        username: 'differentuser',
        name: 'Different User',
        email: 'different@test.com',
        dob: '1990-01-01',
        isEmailVerified: true,
        isVerified: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(() => TestCurrentUser(differentUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileRetweetWidget(
                profileModel: testProfileModel,
                tweetModel: retweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test User reposted'), findsOneWidget);
      expect(find.byType(ProfileRetweetWidget), findsOneWidget);
    });

    testWidgets('should render quote retweet widget when type is Quote', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileTweetProvider('parent1').overrideWith(
              (ref) => Future.value(Right(parentTweetModel)),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileRetweetWidget(
                profileModel: testProfileModel,
                tweetModel: quoteRetweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ProfileRetweetWidget), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(ProfileQuoteWidget), findsOneWidget);
      expect(find.text('Another User reposted'), findsOneWidget);
    });

    testWidgets('should display retweet indicator with correct styling', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileRetweetWidget(
                profileModel: testProfileModel,
                tweetModel: retweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final rotatedBox = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 1);

      final icon = tester.widget<Icon>(find.byIcon(Icons.repeat));
      expect(icon.size, 17);
      expect(icon.color, Colors.grey);
    });
  });
}
