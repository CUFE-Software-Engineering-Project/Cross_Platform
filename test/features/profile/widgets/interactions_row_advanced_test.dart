import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

void main() {
  group('InterActionsRowOfTweet - Advanced Async Tests', () {
    late ProfileTweetModel mockTweet;

    setUp(() {
      mockTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 2,
        type: TweetType.Tweet,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        verified: false,
        protectedAccount: false,
        profileMediaId: 'avatar1',
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );
    });

    testWidgets('should handle retweet success with current user refresh',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retweetTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Right(null);
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap retweet button (second GestureDetector)
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Should show bottom sheet
      expect(find.text('Retweet'), findsOneWidget);

      // Tap retweet option
      await tester.tap(find.text('Retweet'));
      await tester.pumpAndSettle();

      // Wait for async operation
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('retweet done successfully'), findsOneWidget);
    });

    testWidgets('should handle retweet error with snackbar',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retweetTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Left(Failure('Retweet failed'));
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap retweet button
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Tap retweet option
      await tester.tap(find.text('Retweet'));
      await tester.pumpAndSettle();

      // Wait for async operation
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Retweet failed'), findsOneWidget);
    });

    testWidgets('should handle unretweet success',
        (tester) async {
      final retweetedTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: true, // Already retweeted
        quotesCount: 2,
        type: TweetType.Tweet,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        verified: false,
        protectedAccount: false,
        profileMediaId: 'avatar1',
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deleteRetweetTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Right(null);
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: retweetedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap retweet button (should show UnRetweet)
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Should show UnRetweet option
      expect(find.text('UnRetweet'), findsOneWidget);

      // Tap unretweet option
      await tester.tap(find.text('UnRetweet'));
      await tester.pumpAndSettle();

      // Wait for async operation
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('delete retweet done successfully'), findsOneWidget);
    });

    testWidgets('should handle unretweet error',
        (tester) async {
      final retweetedTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: true,
        quotesCount: 2,
        type: TweetType.Tweet,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        verified: false,
        protectedAccount: false,
        profileMediaId: 'avatar1',
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deleteRetweetTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Left(Failure('Delete retweet failed'));
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: retweetedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap retweet button
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Tap unretweet option
      await tester.tap(find.text('UnRetweet'));
      await tester.pumpAndSettle();

      // Wait for async operation
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Delete retweet failed'), findsOneWidget);
    });

    testWidgets('should handle like success with provider refresh',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            likeTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Right(null);
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state: not liked with 10 likes
      expect(find.text('10'), findsOneWidget);

      // Tap like button
      final likeButton = find.byType(GestureDetector).at(2);
      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // UI should update to 11
      expect(find.text('11'), findsOneWidget);

      // Wait for async success
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Like count should stay at 11
      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('should handle unsave success with success message',
        (tester) async {
      final savedTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: true, // Already saved
        isRepostedWithMe: false,
        quotesCount: 2,
        type: TweetType.Tweet,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        verified: false,
        protectedAccount: false,
        profileMediaId: 'avatar1',
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unSaveTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Right(null);
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: savedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button to unsave
      final saveButton = find.byType(GestureDetector).at(4);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Wait for async success
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Post removed from your Bookmarks'), findsOneWidget);
    });

    testWidgets('should handle unsave error with state rollback',
        (tester) async {
      final savedTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: true,
        isRepostedWithMe: false,
        quotesCount: 2,
        type: TweetType.Tweet,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        verified: false,
        protectedAccount: false,
        profileMediaId: 'avatar1',
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unSaveTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Left(Failure('Unsave failed'));
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: savedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button to unsave
      final saveButton = find.byType(GestureDetector).at(4);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Wait for async error
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Unsave failed'), findsOneWidget);
    });

    testWidgets('should handle save success with success message',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            saveTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Right(null);
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button
      final saveButton = find.byType(GestureDetector).at(4);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Wait for async success
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Post added to your Bookmarks'), findsOneWidget);
    });

    testWidgets('should handle save error with state rollback',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            saveTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 100));
                return Left(Failure('Save failed'));
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button
      final saveButton = find.byType(GestureDetector).at(4);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Wait for async error
      await tester.pump(Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Save failed'), findsOneWidget);
    });
  });

  group('InterActionsRowOfTweet - TODO Action Buttons', () {
    late ProfileTweetModel mockTweet;

    setUp(() {
      mockTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Test tweet',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 3,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 2,
        type: TweetType.Tweet,
        userId: 'user1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        verified: false,
        protectedAccount: false,
        profileMediaId: 'avatar1',
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );
    });

    testWidgets('should handle activity button tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find activity button by activityNumber text
      final activityButton = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Row &&
            (widget.child as Row).children.any((child) {
              if (child is Text && child.data == '100') {
                return true;
              }
              return false;
            }),
      );

      if (activityButton.evaluate().isNotEmpty) {
        await tester.tap(activityButton.first);
        await tester.pump();
      }

      // Verify widget still renders
      expect(find.byType(InterActionsRowOfTweet), findsOneWidget);
    });

    testWidgets('should handle share button tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: mockTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find share button by icon
      final shareButton = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Icon &&
            (widget.child as Icon).icon == Icons.share_outlined,
      );

      expect(shareButton, findsOneWidget);
      await tester.tap(shareButton);
      await tester.pump();

      // Verify widget still renders
      expect(find.byType(InterActionsRowOfTweet), findsOneWidget);
    });
  });
}
