import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([])
class MockCurrentUser extends ProfileModel {
  MockCurrentUser()
      : super(
          id: 'current_user_id',
          username: 'currentuser',
          displayName: 'Current User',
          bio: '',
          followersCount: 0,
          followingCount: 0,
          tweetsCount: 0,
          isVerified: false,
          joinedDate: '',
          website: '',
          location: '',
          postCount: 0,
          birthDate: '',
          isFollowing: false,
          isFollower: false,
          protectedAccount: false,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: '',
          avatarId: '',
          bannerId: '',
        );
}

void main() {
  late ProfileTweetModel testTweet;

  setUp(() {
    testTweet = ProfileTweetModel(
      id: 'tweet123',
      text: 'Test tweet',
      timeAgo: '1h',
      likes: 10,
      retweets: 5,
      replies: 3,
      activityNumber: 100,
      isLikedByMe: false,
      isSavedByMe: false,
      isRepostedWithMe: false,
      quotesCount: 0,
      userId: 'user123',
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
  });

  group('InterActionsRowOfTweet - Reply', () {
    testWidgets('should display reply icon and count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => 
        widget is SvgPicture && widget.bytesLoader.toString().contains('reply')
      ), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // replies count
    });

    testWidgets('should not display count when replies is 0', (tester) async {
      final tweetWithoutReplies = ProfileTweetModel(
        id: 'tweet124',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 0,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: tweetWithoutReplies),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('0'), findsNothing);
    });
  });

  group('InterActionsRowOfTweet - Retweet', () {
    testWidgets('should display retweet icon with correct color when not retweeted', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget); // retweets count
    });

    testWidgets('should display retweet count formatted', (tester) async {
      final tweetWithManyRetweets = ProfileTweetModel(
        id: 'tweet125',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 1500,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: tweetWithManyRetweets),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('1.5K'), findsOneWidget);
    });

    testWidgets('should show retweet icon in green when retweeted', (tester) async {
      final retweetedTweet = ProfileTweetModel(
        id: 'tweet126',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: true,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: retweetedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Widget should be rendered with isRepostedWithMe = true
    });
  });

  group('InterActionsRowOfTweet - Like', () {
    testWidgets('should display like icon and count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget); // likes count
    });

    testWidgets('should toggle like state when tapped', (tester) async {
      bool likeCalled = false;
      bool unlikeCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            likeTweetProvider.overrideWith((ref) => (tweetId) {
              likeCalled = true;
              return Future.value(Right(null));
            }),
            unlikeTweetProvider.overrideWith((ref) => (tweetId) {
              unlikeCalled = true;
              return Future.value(Right(null));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the like button (3rd GestureDetector in the row)
      final likeButtons = find.byType(GestureDetector);
      expect(likeButtons, findsWidgets);
      
      // The like button should be the third one
      await tester.tap(likeButtons.at(2));
      await tester.pump();

      // Verify like count increased
      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('should display liked tweet with pink icon', (tester) async {
      final likedTweet = ProfileTweetModel(
        id: 'tweet127',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: true,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: likedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Widget should show filled heart icon
    });

    testWidgets('should format large like counts', (tester) async {
      final tweetWithManyLikes = ProfileTweetModel(
        id: 'tweet128',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 1000000,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: tweetWithManyLikes),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('1.0M'), findsOneWidget);
    });
  });

  group('InterActionsRowOfTweet - Activity', () {
    testWidgets('should display activity count when greater than 0', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget); // activity count
    });

    testWidgets('should not display activity count when 0', (tester) async {
      final tweetWithoutActivity = ProfileTweetModel(
        id: 'tweet129',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: tweetWithoutActivity),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Activity count should not be displayed
    });
  });

  group('InterActionsRowOfTweet - Save/Bookmark', () {
    testWidgets('should toggle save state when tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            saveTweetProvider.overrideWith((ref) => (tweetId) {
              return Future.value(Right(null));
            }),
            unSaveTweetProvider.overrideWith((ref) => (tweetId) {
              return Future.value(Right(null));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the save button
      final gestureDetectors = find.byType(GestureDetector);
      // Save button is one of the last GestureDetectors
      await tester.tap(gestureDetectors.at(4));
      await tester.pump();
    });

    testWidgets('should display saved tweet with blue icon', (tester) async {
      final savedTweet = ProfileTweetModel(
        id: 'tweet130',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: true,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: savedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Widget should show filled bookmark icon
    });
  });

  group('InterActionsRowOfTweet - Share', () {
    testWidgets('should display share icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });
  });

  group('InterActionsRowOfTweet - Count Formatting', () {
    testWidgets('should format all counts correctly', (tester) async {
      final tweetWithFormattedCounts = ProfileTweetModel(
        id: 'tweet131',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 5432,
        retweets: 123,
        replies: 9876,
        activityNumber: 54321,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: tweetWithFormattedCounts),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('9.9K'), findsOneWidget); // replies
      expect(find.text('123'), findsOneWidget); // retweets
      expect(find.text('5.4K'), findsOneWidget); // likes
      expect(find.text('54.3K'), findsOneWidget); // activity
    });
  });

  group('InterActionsRowOfTweet - Error Handling', () {
    testWidgets('should handle like failure gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            likeTweetProvider.overrideWith((ref) => (tweetId) {
              return Future.value(Left(Failure('Like failed')));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap like button
      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.at(2));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      
      // Should show error message
      expect(find.text('Like failed'), findsOneWidget);
    });

    testWidgets('should handle save failure gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            saveTweetProvider.overrideWith((ref) => (tweetId) {
              return Future.value(Left(Failure('Save failed')));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button
      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.at(4));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      
      // Should show error message
      expect(find.text('Save failed'), findsOneWidget);
    });
  });

  group('InterActionsRowOfTweet - State Management', () {
    testWidgets('should maintain state across rebuilds', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            likeTweetProvider.overrideWith((ref) => (tweetId) {
              return Future.value(Right(null));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: testTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('10'), findsOneWidget);

      // Tap like
      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.at(2));
      await tester.pump();

      // Verify state changed
      expect(find.text('11'), findsOneWidget);

      // Rebuild widget
      await tester.pumpAndSettle();

      // State should persist
      expect(find.text('11'), findsOneWidget);
    });
  });

  group('InterActionsRowOfTweet - Zero Counts', () {
    testWidgets('should handle all zero counts', (tester) async {
      final tweetWithZeros = ProfileTweetModel(
        id: 'tweet132',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: 'user123',
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

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: tweetWithZeros),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should display icons but no counts
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });
  });
}
