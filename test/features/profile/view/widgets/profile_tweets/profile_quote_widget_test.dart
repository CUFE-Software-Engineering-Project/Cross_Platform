import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/profile_quote_widget.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

void main() {
  late ProfileModel testProfileModel;
  late ProfileTweetModel quoteTweetModel;
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

    quoteTweetModel = ProfileTweetModel(
      id: 'quote1',
      text: 'Quote tweet text',
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
      retweeterName: '',
      retweeterUserName: '',
      hashtags: [],
    );
  });

  group('ProfileQuoteWidget', () {
    testWidgets('should render widget successfully with parent tweet data',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileTweetProvider('parent1').overrideWith(
              (ref) => Future.value(Right(parentTweetModel)),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileQuoteWidget(
                profileModel: testProfileModel,
                tweetModel: quoteTweetModel,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ProfileQuoteWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle loading state when fetching parent tweet',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileTweetProvider('parent1').overrideWith(
              (ref) => Future.delayed(
                const Duration(milliseconds: 100),
                () => Right(parentTweetModel),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileQuoteWidget(
                profileModel: testProfileModel,
                tweetModel: quoteTweetModel,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ProfileQuoteWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should handle error state when fetching parent tweet fails',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileTweetProvider('parent1').overrideWith(
              (ref) => Future.value(
                Left(Failure('Network error')),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileQuoteWidget(
                profileModel: testProfileModel,
                tweetModel: quoteTweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should refresh when refresh button is tapped on error',
        (tester) async {
      var callCount = 0;
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileTweetProvider('parent1').overrideWith(
              (ref) {
                callCount++;
                if (callCount == 1) {
                  return Future.value(
                    Left(Failure('Network error')),
                  );
                }
                return Future.value(Right(parentTweetModel));
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileQuoteWidget(
                profileModel: testProfileModel,
                tweetModel: quoteTweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(callCount, 2);
    });

    testWidgets('should handle exception error when fetching parent tweet',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileTweetProvider('parent1').overrideWith(
              (ref) => Future.error(Exception('Something went wrong')),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProfileQuoteWidget(
                profileModel: testProfileModel,
                tweetModel: quoteTweetModel,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Can't get parent tweet"), findsOneWidget);
    });
  });
}
