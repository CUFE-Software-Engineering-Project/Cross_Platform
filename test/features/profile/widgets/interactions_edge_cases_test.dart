import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

void main() {
  group('InterActionsRowOfTweet - Edge Cases with CurrentUser', () {
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

    testWidgets('should handle retweet success when currentUser is null',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            retweetTweetProvider.overrideWith(
              (ref) => (String tweetId) async {
                await Future.delayed(Duration(milliseconds: 50));
                return Right(null);
              },
            ),
            // currentUserProvider not overridden - will be null
            profilePostsProvider.overrideWith(
              (ref, username) => Future.value(Right([])),
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
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should still show success message even with null user
      expect(find.text('retweet done successfully'), findsOneWidget);
    });

    testWidgets('should handle unretweet success when currentUser is null',
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
                await Future.delayed(Duration(milliseconds: 50));
                return Right(null);
              },
            ),
            // currentUserProvider not overridden - will be null
            profilePostsProvider.overrideWith(
              (ref, username) => Future.value(Right([])),
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

      // Tap unretweet button
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Tap unretweet option
      await tester.tap(find.text('UnRetweet'));
      await tester.pumpAndSettle();

      // Wait for async operation
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should still show success message even with null user
      expect(find.text('delete retweet done successfully'), findsOneWidget);
    });

    testWidgets('should handle bottom sheet cancel for retweet',
        (tester) async {
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

      // Tap retweet button
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Bottom sheet should appear
      expect(find.text('Retweet'), findsWidgets);
      expect(find.text('Quote'), findsOneWidget);

      // Tap outside to dismiss (or tap Cancel if available)
      await tester.tapAt(Offset(10, 10));
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed
      expect(find.text('Quote'), findsNothing);
    });

    testWidgets('should handle bottom sheet cancel for unretweet',
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
          child: MaterialApp(
            home: Scaffold(
              body: InterActionsRowOfTweet(tweet: retweetedTweet),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap unretweet button
      final retweetButton = find.byType(GestureDetector).at(1);
      await tester.tap(retweetButton);
      await tester.pumpAndSettle();

      // Bottom sheet should appear
      expect(find.text('UnRetweet'), findsOneWidget);
      expect(find.text('Quote'), findsOneWidget);

      // Tap outside to dismiss
      await tester.tapAt(Offset(10, 10));
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed
      expect(find.text('Quote'), findsNothing);
    });
  });
}
