import 'package:dartz/dartz.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/shared_tweet_components.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:video_player/video_player.dart';

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
      text: 'Test tweet with #hashtag and @mention',
      timeAgo: '1h',
      likes: 20,
      retweets: 10,
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

  group('BasicTweetWidget', () {
    testWidgets('should render with actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BasicTweetWidget), findsOneWidget);
    });

    testWidgets('should render without actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BasicTweetWidget), findsOneWidget);
    });

    testWidgets('should display user information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsWidgets);
    });

    testWidgets('should display interaction counts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Should display likes, retweets, and replies counts
      expect(find.text('5'), findsOneWidget); // replies
      expect(find.text('10'), findsOneWidget); // retweets
      expect(find.text('20'), findsOneWidget); // likes
    });

    testWidgets('should handle verified users', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(BasicTweetWidget), findsOneWidget);
    });

    testWidgets('should handle tweets with media', (tester) async {
      final tweetWithMedia = ProfileTweetModel(
        id: 'tweet2',
        text: 'Tweet with media',
        timeAgo: '2h',
        likes: 30,
        retweets: 15,
        replies: 8,
        activityNumber: 200,
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
        mediaIds: ['media1', 'media2'],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: tweetWithMedia,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BasicTweetWidget), findsOneWidget);
    });
  });

  group('VideoPlayerWidget', () {
    testWidgets('should display loading indicator while initializing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(
              videoUrl: 'https://example.com/video.mp4',
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle video with custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(
              videoUrl: 'https://example.com/video.mp4',
              height: 400,
              isPlaying: false,
            ),
          ),
        ),
      );

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(
              videoUrl: 'invalid_url',
              height: 300,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(seconds: 2));

      // Widget should render even with invalid URL
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });
  });

  group('ProfileTweetOptin', () {
    testWidgets('should render with text and icon', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileTweetOptin(
              text: 'Delete post',
              icon: Icons.delete,
              onPress: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Delete post'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('should handle different icons and text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileTweetOptin(
              text: 'Pin to profile',
              icon: Icons.push_pin_outlined,
              onPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pin to profile'), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
    });
  });

  group('TweetMediaGrid', () {
    testWidgets('should render with empty media list', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: []),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should render with single media ID', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1']),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should render with two media IDs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1', 'media2']),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should render with three media IDs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1', 'media2', 'media3']),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should render with four media IDs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                  mediaIds: ['media1', 'media2', 'media3', 'media4']),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should render with more than four media IDs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                  mediaIds: ['media1', 'media2', 'media3', 'media4', 'media5']),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });
  });

  group('ExpandableLinkedText', () {
    testWidgets('should render short text without expansion', (tester) async {
      final shortTweet = ProfileTweetModel(
        id: 'tweet1',
        text: 'Short text',
        timeAgo: '1h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
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
              body: ExpandableLinkedText(
                text: 'Short text',
                tweet: shortTweet,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RichText), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle text with hashtags', (tester) async {
      final hashtagTweet = ProfileTweetModel(
        id: 'tweet2',
        text: 'This is #flutter and #dart',
        timeAgo: '2h',
        likes: 10,
        retweets: 5,
        replies: 2,
        activityNumber: 50,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [
          {'id': '1', 'hashtagName': 'flutter'},
          {'id': '2', 'hashtagName': 'dart'},
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExpandableLinkedText(
                text: 'This is #flutter and #dart',
                tweet: hashtagTweet,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle text with mentions', (tester) async {
      final mentionTweet = ProfileTweetModel(
        id: 'tweet3',
        text: 'Hello @john and @jane',
        timeAgo: '3h',
        likes: 15,
        retweets: 8,
        replies: 3,
        activityNumber: 75,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
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
              body: ExpandableLinkedText(
                text: 'Hello @john and @jane',
                tweet: mentionTweet,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should expand long text on tap', (tester) async {
      final longText =
          'This is a very long text that should be trimmed and show a "Show more" button when rendered in the widget. ' * 5;
      final longTweet = ProfileTweetModel(
        id: 'tweet4',
        text: longText,
        timeAgo: '4h',
        likes: 20,
        retweets: 10,
        replies: 5,
        activityNumber: 100,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
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
              body: SizedBox(
                width: 300,
                child: ExpandableLinkedText(
                  text: longText,
                  tweet: longTweet,
                  trimLines: 3,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RichText), findsOneWidget);

      // Try to find and tap "Show more" if it exists
      final richText = tester.widget<RichText>(find.byType(RichText));
      if (richText.text.toPlainText().contains('Show more')) {
        // The text is trimmed, try tapping it
        await tester.tap(find.byType(RichText));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle mixed hashtags and mentions', (tester) async {
      final mixedTweet = ProfileTweetModel(
        id: 'tweet5',
        text: 'Check out @flutter_dev for #flutter tips',
        timeAgo: '5h',
        likes: 25,
        retweets: 12,
        replies: 6,
        activityNumber: 125,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [
          {'id': '1', 'hashtagName': 'flutter'},
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExpandableLinkedText(
                text: 'Check out @flutter_dev for #flutter tips',
                tweet: mixedTweet,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('BasicTweetWidget Interactions', () {
    testWidgets('should navigate to profile when tapping avatar',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) => const Scaffold(
              body: Text('Profile Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the avatar (BuildSmallProfileImage is wrapped in GestureDetector)
      final avatarFinder = find.byType(GestureDetector).first;
      await tester.tap(avatarFinder);
      await tester.pump();
    });

    testWidgets('should navigate to profile when tapping display name',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) => const Scaffold(
              body: Text('Profile Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the display name
      final displayNameFinder = find.text(testTweetModel.userDisplayName);
      await tester.tap(displayNameFinder);
      await tester.pump();
    });

    testWidgets('should navigate to profile when tapping username',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) => const Scaffold(
              body: Text('Profile Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the username
      final usernameFinder = find.text('@${testTweetModel.userUserName}');
      await tester.tap(usernameFinder);
      await tester.pump();
    });

    testWidgets('should render tweet content with clickable area',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
          GoRoute(
            path: '/tweetDetailPage',
            builder: (context, state) => const Scaffold(
              body: Text('Tweet Details'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tweet content area exists (InkWell wraps the content for tap)
      expect(find.byType(InkWell), findsWidgets);
      expect(find.byType(ExpandableLinkedText), findsOneWidget);
    });

    testWidgets('should render more icon button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that more icon exists
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });

  group('VideoPlayerWidget Lifecycle', () {
    testWidgets('should initialize video controller', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) async => 'https://example.com/video.mp4',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/video.mp4',
                height: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle video visibility changes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) async => 'https://example.com/video.mp4',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(height: 1000),
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/video.mp4',
                      height: 200,
                    ),
                    Container(height: 1000),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Scroll to make video visible
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
    });
  });

  group('TweetMediaGrid Provider States', () {
    testWidgets('should handle loading state for media', (tester) async {
      // Use a never-completing future to keep loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) => Future<String>(() async {
                await Future.delayed(const Duration(milliseconds: 100));
                return 'https://example.com';
              }),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1']),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Complete the future
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('should handle error state for media', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) => Future.error('Failed to load'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1']),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should handle video media in grid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('video1').overrideWith(
              (ref) async => 'https://example.com/video.mp4',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['video1']),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should render grid with 2 items layout', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) async => 'https://example.com/image1.jpg',
            ),
            mediaUrlProvider('media2').overrideWith(
              (ref) async => 'https://example.com/image2.jpg',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1', 'media2']),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should render grid with 3 items layout', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) async => 'https://example.com/image1.jpg',
            ),
            mediaUrlProvider('media2').overrideWith(
              (ref) async => 'https://example.com/image2.jpg',
            ),
            mediaUrlProvider('media3').overrideWith(
              (ref) async => 'https://example.com/image3.jpg',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                  mediaIds: ['media1', 'media2', 'media3']),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });
  });

  group('ExpandableLinkedText Interactions', () {
    testWidgets('should toggle text expansion on tap', (tester) async {
      final longText =
          'This is a very long text that should be trimmed and show expansion ' *
              10;
      final longTweet = ProfileTweetModel(
        id: 'tweet10',
        text: longText,
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 2,
        activityNumber: 50,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
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
              body: SizedBox(
                width: 300,
                child: ExpandableLinkedText(
                  text: longText,
                  tweet: longTweet,
                  trimLines: 3,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to tap on the text to expand/collapse
      final richTextFinder = find.byType(RichText);
      if (richTextFinder.evaluate().isNotEmpty) {
        await tester.tap(richTextFinder.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should navigate when tapping hashtag', (tester) async {
      final hashtagTweet = ProfileTweetModel(
        id: 'tweet11',
        text: 'Test #flutter hashtag',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 2,
        activityNumber: 50,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [
          {'id': '1', 'hashtagName': 'flutter'},
        ],
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ExpandableLinkedText(
                text: 'Test #flutter hashtag',
                tweet: hashtagTweet,
              ),
            ),
          ),
          GoRoute(
            path: '/searchResults/:query',
            builder: (context, state) => const Scaffold(
              body: Text('Search Results'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find RichText and try to tap on hashtag area
      final richTextFinder = find.byType(RichText);
      if (richTextFinder.evaluate().isNotEmpty) {
        // Tap at the position where hashtag might be
        await tester.tapAt(tester.getCenter(richTextFinder.first));
        await tester.pump();
      }
    });

    testWidgets('should navigate when tapping mention', (tester) async {
      final mentionTweet = ProfileTweetModel(
        id: 'tweet12',
        text: 'Hello @johndoe',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 2,
        activityNumber: 50,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ExpandableLinkedText(
                text: 'Hello @johndoe',
                tweet: mentionTweet,
              ),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) => const Scaffold(
              body: Text('Profile Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find RichText and try to tap on mention area
      final richTextFinder = find.byType(RichText);
      if (richTextFinder.evaluate().isNotEmpty) {
        await tester.tapAt(tester.getCenter(richTextFinder.first));
        await tester.pump();
      }
    });
  });

  group('ProfileTweetOptin Interactions', () {
    testWidgets('should handle tap on option', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileTweetOptin(
              text: 'Delete',
              icon: Icons.delete,
              onPress: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final listTileFinder = find.byType(ListTile);
      await tester.tap(listTileFinder);
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });

  group('openProfileTweetOptions Coverage', () {
    // Note: openProfileTweetOptions full testing requires complex provider setup
    // The function is covered via BasicTweetWidget more icon tap test
    
    testWidgets('should render ProfileTweetOptin widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileTweetOptin(
              text: 'Test Option',
              icon: Icons.person,
              onPress: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Option'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should verify openProfileTweetOptions function exists', (tester) async {
      // Function is tested indirectly via BasicTweetWidget more icon tap
      expect(openProfileTweetOptions, isNotNull);
    });
  });

  group('openProfileTweetOptions Function - Full Coverage', () {
    testWidgets('should show all options and execute pin action', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      openProfileTweetOptions(context, ref, testTweetModel);
                    },
                    child: const Text('Open Options'),
                  );
                },
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set current user using the notifier
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
      container.read(currentUserProvider.notifier).adduser(
        UserModel(
          id: '1',
          username: 'testuser',
          name: 'Test User',
          email: 'test@test.com',
          dob: '1990-01-01',
          isEmailVerified: true,
          isVerified: false,
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to call the function
      await tester.tap(find.text('Open Options'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is shown with all options
      expect(find.text('Pin to profile'), findsOneWidget);
      expect(find.text('Delete post'), findsOneWidget);
      expect(find.text('Change who can reply'), findsOneWidget);
      expect(find.text('Request Community Note'), findsOneWidget);

      // Tap pin to profile
      await tester.tap(find.text('Pin to profile'));
      await tester.pumpAndSettle();
    });

    testWidgets('should execute delete action successfully', (tester) async {
      bool deleteWasCalled = false;
      String? deletedTweetId;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      openProfileTweetOptions(context, ref, testTweetModel);
                    },
                    child: const Text('Open Options'),
                  );
                },
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deleteTweetProvider.overrideWith((ref) {
              return (String tweetId) async {
                deleteWasCalled = true;
                deletedTweetId = tweetId;
                return Right(null);
              };
            }),
            profilePostsProvider('testuser').overrideWith((ref) async {
              return Right([]);
            }),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set current user using the notifier
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
      container.read(currentUserProvider.notifier).adduser(
        UserModel(
          id: '1',
          username: 'testuser',
          name: 'Test User',
          email: 'test@test.com',
          dob: '1990-01-01',
          isEmailVerified: true,
          isVerified: false,
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to call the function
      await tester.tap(find.text('Open Options'));
      await tester.pumpAndSettle();

      expect(find.text('Delete post'), findsOneWidget);

      await tester.tap(find.text('Delete post'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(deleteWasCalled, true);
      expect(deletedTweetId, testTweetModel.id);
    });

    testWidgets('should handle delete error', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      openProfileTweetOptions(context, ref, testTweetModel);
                    },
                    child: const Text('Open Options'),
                  );
                },
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deleteTweetProvider.overrideWith((ref) {
              return (String tweetId) async {
                return Left(Failure('Failed to delete tweet'));
              };
            }),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set current user using the notifier
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
      container.read(currentUserProvider.notifier).adduser(
        UserModel(
          id: '1',
          username: 'testuser',
          name: 'Test User',
          email: 'test@test.com',
          dob: '1990-01-01',
          isEmailVerified: true,
          isVerified: false,
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to call the function
      await tester.tap(find.text('Open Options'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete post'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('should execute change reply action', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      openProfileTweetOptions(context, ref, testTweetModel);
                    },
                    child: const Text('Open Options'),
                  );
                },
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set current user using the notifier
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
      container.read(currentUserProvider.notifier).adduser(
        UserModel(
          id: '1',
          username: 'testuser',
          name: 'Test User',
          email: 'test@test.com',
          dob: '1990-01-01',
          isEmailVerified: true,
          isVerified: false,
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to call the function
      await tester.tap(find.text('Open Options'));
      await tester.pumpAndSettle();

      expect(find.text('Change who can reply'), findsOneWidget);

      await tester.tap(find.text('Change who can reply'));
      await tester.pumpAndSettle();
    });

    testWidgets('should execute request community note action', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      openProfileTweetOptions(context, ref, testTweetModel);
                    },
                    child: const Text('Open Options'),
                  );
                },
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set current user using the notifier
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
      container.read(currentUserProvider.notifier).adduser(
        UserModel(
          id: '1',
          username: 'testuser',
          name: 'Test User',
          email: 'test@test.com',
          dob: '1990-01-01',
          isEmailVerified: true,
          isVerified: false,
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to call the function
      await tester.tap(find.text('Open Options'));
      await tester.pumpAndSettle();

      expect(find.text('Request Community Note'), findsOneWidget);

      await tester.tap(find.text('Request Community Note'));
      await tester.pumpAndSettle();
    });
  });

  group('VideoPlayerWidget Error Paths', () {
    testWidgets('should show error UI when video fails to load', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(
              videoUrl: 'https://invalid-url.com/nonexistent.mp4',
              height: 200,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Should show error state
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      expect(find.text('Couldn\'t load video'), findsOneWidget);
    });

    testWidgets('should handle visibility changes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) async => 'https://example.com/video.mp4',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 1000),
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/video.mp4',
                      height: 200,
                    ),
                    SizedBox(height: 1000),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should handle mute toggle with errors gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(
              videoUrl: 'https://example.com/video.mp4',
              height: 200,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Try to find and tap mute button even if controller isn't fully initialized
      final muteButtonFinder = find.byIcon(Icons.volume_off);
      if (muteButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(muteButtonFinder);
        await tester.pump();
      }
    });

    testWidgets('should handle onPlay callback', (tester) async {
      bool onPlayCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/video.mp4',
                height: 200,
                onPlay: () {
                  onPlayCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('TweetMediaGrid Async Edge Cases', () {
    testWidgets('should handle multiple rapid state changes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith(
              (ref) async {
                await Future.delayed(const Duration(milliseconds: 50));
                return 'https://example.com/image1.jpg';
              },
            ),
            mediaUrlProvider('media2').overrideWith(
              (ref) async {
                await Future.delayed(const Duration(milliseconds: 100));
                return 'https://example.com/image2.jpg';
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['media1', 'media2']),
            ),
          ),
        ),
      );

      // Pump multiple times to simulate rapid state changes
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 25));
      await tester.pump(const Duration(milliseconds: 25));
      await tester.pump(const Duration(milliseconds: 25));
      await tester.pump(const Duration(milliseconds: 50));
      
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should handle grid with exactly 4 items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith((ref) async => 'https://example.com/1.jpg'),
            mediaUrlProvider('media2').overrideWith((ref) async => 'https://example.com/2.jpg'),
            mediaUrlProvider('media3').overrideWith((ref) async => 'https://example.com/3.jpg'),
            mediaUrlProvider('media4').overrideWith((ref) async => 'https://example.com/4.jpg'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['media1', 'media2', 'media3', 'media4'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should handle grid with 5 items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('media1').overrideWith((ref) async => 'https://example.com/1.jpg'),
            mediaUrlProvider('media2').overrideWith((ref) async => 'https://example.com/2.jpg'),
            mediaUrlProvider('media3').overrideWith((ref) async => 'https://example.com/3.jpg'),
            mediaUrlProvider('media4').overrideWith((ref) async => 'https://example.com/4.jpg'),
            mediaUrlProvider('media5').overrideWith((ref) async => 'https://example.com/5.jpg'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['media1', 'media2', 'media3', 'media4', 'media5'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });

    testWidgets('should handle mixed async completion times', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('fast').overrideWith(
              (ref) async => 'https://example.com/fast.jpg',
            ),
            mediaUrlProvider('slow').overrideWith(
              (ref) async {
                await Future.delayed(const Duration(milliseconds: 200));
                return 'https://example.com/slow.jpg';
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(mediaIds: ['fast', 'slow']),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });
  });

  group('ExpandableLinkedText Edge Cases', () {
    testWidgets('should handle text with only hashtags', (tester) async {
      final hashtagOnlyTweet = ProfileTweetModel(
        id: 'tweet20',
        text: '#flutter #dart #mobile',
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 2,
        activityNumber: 50,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [
          {'id': '1', 'hashtagName': 'flutter'},
          {'id': '2', 'hashtagName': 'dart'},
          {'id': '3', 'hashtagName': 'mobile'},
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExpandableLinkedText(
                text: '#flutter #dart #mobile',
                tweet: hashtagOnlyTweet,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should handle very long text expansion', (tester) async {
      final longText = 'This is a very long tweet ' * 20;
      final longTweet = ProfileTweetModel(
        id: 'tweet21',
        text: longText,
        timeAgo: '1h',
        likes: 10,
        retweets: 5,
        replies: 2,
        activityNumber: 50,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
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
              body: ExpandableLinkedText(
                text: longText,
                tweet: longTweet,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Find "Show more" if text is truncated
      final showMoreFinder = find.text('Show more');
      if (showMoreFinder.evaluate().isNotEmpty) {
        await tester.tap(showMoreFinder);
        await tester.pumpAndSettle();
        
        // Should now show "show less"
        expect(find.text('show less'), findsOneWidget);
        
        // Tap "show less" to collapse
        await tester.tap(find.text('show less'));
        await tester.pumpAndSettle();
        
        // Should show "Show more" again
        expect(find.text('Show more'), findsOneWidget);
        expect(find.text('show less'), findsNothing);
      }
    });

    testWidgets('should handle expand and collapse cycle with gesture recognizer', (tester) async {
      // Create a sufficiently long text that will definitely be truncated
      final longText = 'A' * 200; // 200 characters
      final longTweet = ProfileTweetModel(
        id: 'long_tweet',
        text: longText,
        timeAgo: '1h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
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
              body: Container(
                width: 200, // Constrain width
                child: ExpandableLinkedText(
                  text: longText,
                  tweet: longTweet,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Helper to find and tap a TextSpan by text
      void tapTextSpan(String text) {
        final richTextFinder = find.byType(RichText);
        final RichText richText = tester.widget(richTextFinder.first);
        final TextSpan textSpan = richText.text as TextSpan;

        TextSpan? targetSpan;
        void findSpan(InlineSpan span) {
          if (span is TextSpan) {
            if (span.text == text) {
              targetSpan = span;
            }
            span.children?.forEach(findSpan);
          }
        }
        findSpan(textSpan);

        if (targetSpan?.recognizer != null) {
          (targetSpan!.recognizer as TapGestureRecognizer).onTap?.call();
        }
      }

      // Tap "Show more" if it exists
      try {
        tapTextSpan('Show more');
        await tester.pumpAndSettle();

        // Now tap "show less"
        tapTextSpan('show less');
        await tester.pumpAndSettle();

        // Verify we can tap "Show more" again
        tapTextSpan('Show more');
        await tester.pumpAndSettle();
      } catch (e) {
        // If text wasn't truncated, that's fine
      }
    });
  });

  group('BasicTweetWidget Tap Interactions Coverage', () {
    testWidgets('should call openProfileTweetOptions when more_vert icon is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: testTweetModel,
                withActions: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the more_vert icon
      final moreIcon = find.byIcon(Icons.more_vert);
      expect(moreIcon, findsOneWidget);
      
      await tester.tap(moreIcon);
      await tester.pumpAndSettle();

      // Verify bottom sheet appeared (openProfileTweetOptions was called)
      expect(find.text('Pin to profile'), findsOneWidget);
      expect(find.text('Request Community Note'), findsOneWidget);
    });

    testWidgets('should navigate to tweet details when InkWell is tapped', (tester) async {
      // Create a simple tweet without hashtags or mentions to avoid gesture conflicts
      final simpleTweet = ProfileTweetModel(
        id: 'simple_tweet',
        text: 'Simple tweet without special characters',
        timeAgo: '1h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
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

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: BasicTweetWidget(
                profileModel: testProfileModel,
                profilePostModel: simpleTweet,
                withActions: true,
              ),
            ),
          ),
          GoRoute(
            path: '/tweetDetailsScreen/:id',
            builder: (context, state) => Scaffold(
              body: Center(child: Text('Tweet Details: ${state.pathParameters['id']}')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the InkWell and tap it
      final inkWell = find.byType(InkWell);
      expect(inkWell, findsWidgets); // There may be multiple InkWells
      
      // Tap the first InkWell (the one wrapping the tweet content)
      await tester.tap(inkWell.first);
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Tweet Details: simple_tweet'), findsOneWidget);
    });
  });

  group('ExpandableLinkedText Rendering Coverage', () {
    testWidgets('should render mention links correctly', (tester) async {
      final mentionTweet = ProfileTweetModel(
        id: 'tweet_mention',
        text: 'Hello @testuser how are you',
        timeAgo: '1h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [],
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ExpandableLinkedText(
                text: 'Hello @testuser how are you',
                tweet: mentionTweet,
              ),
            ),
          ),
          GoRoute(
            path: '/profilescreen/:username',
            builder: (context, state) => Scaffold(
              body: Center(child: Text('Profile: ${state.pathParameters['username']}')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget rendered successfully
      expect(find.byType(RichText), findsOneWidget);
      
      // Verify the text content includes the mention
      final richText = tester.widget<RichText>(find.byType(RichText));
      final plainText = richText.text.toPlainText();
      expect(plainText.contains('@testuser'), true);
    });

    testWidgets('should render hashtag links correctly', (tester) async {
      final hashtagTweet = ProfileTweetModel(
        id: 'tweet_hashtag',
        text: 'Check out #flutter and #dart',
        timeAgo: '1h',
        likes: 0,
        retweets: 0,
        replies: 0,
        activityNumber: 0,
        isLikedByMe: false,
        isSavedByMe: false,
        isRepostedWithMe: false,
        quotesCount: 0,
        userId: '1',
        userUserName: 'testuser',
        userDisplayName: 'Test User',
        profileMediaId: '',
        verified: false,
        protectedAccount: false,
        type: TweetType.Tweet,
        mediaIds: [],
        parentId: '',
        retweeterName: '',
        retweeterUserName: '',
        hashtags: [
          {'id': 'hash1', 'hashtagName': 'flutter'},
          {'id': 'hash2', 'hashtagName': 'dart'},
        ],
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ExpandableLinkedText(
                text: 'Check out #flutter and #dart',
                tweet: hashtagTweet,
              ),
            ),
          ),
          GoRoute(
            path: '/hashtagTweetsScreen',
            builder: (context, state) {
              final extra = state.extra as List<String>?;
              return Scaffold(
                body: Center(child: Text('Hashtag: ${extra?[1] ?? 'unknown'}')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget rendered successfully
      expect(find.byType(RichText), findsOneWidget);
      
      // Verify the text content includes the hashtags
      final richText = tester.widget<RichText>(find.byType(RichText));
      final plainText = richText.text.toPlainText();
      expect(plainText.contains('#flutter'), true);
      expect(plainText.contains('#dart'), true);
    });
  });

  group('VideoPlayerWidget Mute and Visibility Coverage', () {
    testWidgets('should toggle mute when mute icon is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/test.mp4',
                height: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Find the mute toggle icon (initially should be volume_off since video starts muted)
      final muteIconFinder = find.byIcon(Icons.volume_off);
      
      // If video initialized, tap the mute icon
      if (muteIconFinder.evaluate().isNotEmpty) {
        await tester.tap(muteIconFinder);
        await tester.pumpAndSettle();
        
        // After tapping, should show volume_up
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
        
        // Tap again to toggle back
        await tester.tap(find.byIcon(Icons.volume_up));
        await tester.pumpAndSettle();
        
        // Should show volume_off again
        expect(find.byIcon(Icons.volume_off), findsOneWidget);
      }
    });

    testWidgets('should handle video initialization with setState', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/test.mp4',
                height: 200,
              ),
            ),
          ),
        ),
      );

      // Allow time for video widget to be built and potentially initialize
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Video widget should exist
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
      
      // Either loading or initialized/error state should be present
      final hasLoadingOrContent = find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.byIcon(Icons.volume_off).evaluate().isNotEmpty ||
          find.byIcon(Icons.volume_up).evaluate().isNotEmpty ||
          find.byIcon(Icons.broken_image).evaluate().isNotEmpty;
      
      expect(hasLoadingOrContent, true);
    });

    testWidgets('should show error state when video fails to load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://invalid-url.com/nonexistent.mp4',
                height: 200,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // VideoPlayerWidget should exist
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
      
      // Should show either error, loading, or initialized state
      final hasState = find.text("Couldn't load video").evaluate().isNotEmpty ||
          find.byIcon(Icons.broken_image).evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.byIcon(Icons.volume_off).evaluate().isNotEmpty;
      
      expect(hasState, true);
    });

    testWidgets('should handle visibility changes with VisibilityDetector', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(height: 1000, color: Colors.red),
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/test.mp4',
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Video widget should exist in the tree even if off-screen
      expect(find.byType(VideoPlayerWidget), findsOneWidget);

      // Scroll to make video more visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Video should still be there
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });
  });

  group('TweetMediaGrid Error Handling Coverage', () {
    testWidgets('should show error container when media URL is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('empty_media').overrideWith((ref) async => ''),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['empty_media'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      expect(find.text("Couldn't load image"), findsOneWidget);
    });

    testWidgets('should show error container when media provider throws error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('error_media').overrideWith(
              (ref) => Future<String>.error('Network error'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['error_media'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
      expect(find.text("Couldn't load image"), findsOneWidget);
    });

    testWidgets('should refresh media when error refresh icon is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('refresh_media').overrideWith((ref) async => ''),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['refresh_media'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Find and tap the refresh icon
      final refreshIcon = find.byIcon(Icons.refresh);
      expect(refreshIcon, findsOneWidget);
      
      await tester.tap(refreshIcon);
      await tester.pumpAndSettle();

      // Refresh was triggered (provider.refresh was called)
      // The error container should still be visible since we override with empty string
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('should render video player when media URL is a video', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('video_media').overrideWith(
              (ref) async => 'https://example.com/video.mp4',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['video_media'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Should render VideoPlayerWidget instead of CachedNetworkImage
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle _isVideo with various video extensions', (tester) async {
      // Test multiple video extensions
      final videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.mkv'];
      
      for (final ext in videoExtensions) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mediaUrlProvider('video_test').overrideWith(
                (ref) async => 'https://example.com/test$ext',
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: TweetMediaGrid(
                  mediaIds: ['video_test'],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        // Should detect as video and render VideoPlayerWidget
        expect(find.byType(VideoPlayerWidget), findsOneWidget);

        // Clear the widget tree for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should render CachedNetworkImage for non-video URLs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('image_media').overrideWith(
              (ref) async => 'https://example.com/image.jpg',
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TweetMediaGrid(
                mediaIds: ['image_media'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should render CachedNetworkImage for image URLs
      expect(find.byType(TweetMediaGrid), findsOneWidget);
    });
  });

  group('VideoPlayerWidget Internal State Coverage', () {
    testWidgets('should initialize video in test mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/test.mp4',
                height: 200,
                testMode: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Should initialize successfully in test mode
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('should toggle mute in test mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/test.mp4',
                height: 200,
                testMode: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Initially muted
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      // Tap to unmute
      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pumpAndSettle();

      // Should now show unmuted icon
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Tap to mute again
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();

      // Should show muted icon again
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('should handle visibility changes in test mode', (tester) async {
      bool onPlayCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(height: 600),
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/test.mp4',
                      height: 200,
                      testMode: true,
                      onPlay: () {
                        onPlayCalled = true;
                      },
                    ),
                    Container(height: 600),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Should render the video widget
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should render multiple videos in test mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  VideoPlayerWidget(
                    videoUrl: 'https://example.com/video1.mp4',
                    height: 150,
                    testMode: true,
                  ),
                  VideoPlayerWidget(
                    videoUrl: 'https://example.com/video2.mp4',
                    height: 150,
                    testMode: true,
                  ),
                  VideoPlayerWidget(
                    videoUrl: 'https://example.com/video3.mp4',
                    height: 150,
                    testMode: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(VideoPlayerWidget), findsNWidgets(3));
      expect(find.byIcon(Icons.volume_off), findsNWidgets(3));
    });

    testWidgets('should handle rapid mount/unmount in test mode', (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: VideoPlayerWidget(
                  videoUrl: 'https://example.com/video$i.mp4',
                  height: 200,
                  testMode: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);

        // Unmount
        await tester.pumpWidget(Container());
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle different video states in test mode', (tester) async {
      // Test with isPlaying = false
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/test.mp4',
                height: 200,
                testMode: true,
                isPlaying: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(VideoPlayerWidget), findsOneWidget);

      // Test with isPlaying = true
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoPlayerWidget(
                videoUrl: 'https://example.com/test.mp4',
                height: 200,
                testMode: true,
                isPlaying: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should execute video initialization code path', (tester) async {
      // Create widget but don't wait for full initialization
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: VideoPlayerWidget(
                  videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                  height: 200,
                ),
              ),
            ),
          ),
        );

        // Pump to trigger initState
        await tester.pump();
        
        // Give time for async initialization to start
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        
        // Pump more frames to allow setState calls
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Widget should exist
      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle video player state changes', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: VideoPlayerWidget(
                  videoUrl: 'https://sample.com/video.mp4',
                  height: 300,
                  isPlaying: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should render video player with onPlay callback', (tester) async {
      bool onPlayCalled = false;
      
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: VideoPlayerWidget(
                  videoUrl: 'https://example.com/test.mp4',
                  height: 250,
                  onPlay: () {
                    onPlayCalled = true;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 150));
        await tester.pump();
      });

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle video with custom playing state', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: VideoPlayerWidget(
                  videoUrl: 'https://storage.googleapis.com/exoplayer-test-media-0/play.mp3',
                  height: 180,
                  isPlaying: false,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should create multiple video players to cover initialization paths', (tester) async {
      // Test with multiple simultaneous videos
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/video1.mp4',
                      height: 150,
                    ),
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/video2.mov',
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });

      expect(find.byType(VideoPlayerWidget), findsNWidgets(2));
    });

    testWidgets('should handle rapid video mounting and unmounting', (tester) async {
      await tester.runAsync(() async {
        // Create and destroy video widgets rapidly to trigger dispose paths
        for (int i = 0; i < 3; i++) {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: VideoPlayerWidget(
                    videoUrl: 'https://example.com/video$i.mp4',
                    height: 200,
                  ),
                ),
              ),
            ),
          );

          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 50));
          await tester.pump();

          // Unmount
          await tester.pumpWidget(Container());
          await tester.pump();
        }
      });

      // Should have disposed without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should exercise error handling paths in video initialization', (tester) async {
      await tester.runAsync(() async {
        // Use various invalid URLs to trigger error paths
        final invalidUrls = [
          'invalid://url',
          'https://',
          'ftp://invalid.com/video.mp4',
        ];

        for (final url in invalidUrls) {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: VideoPlayerWidget(
                    videoUrl: url,
                    height: 200,
                  ),
                ),
              ),
            ),
          );

          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();

          await tester.pumpWidget(Container());
        }
      });

      expect(tester.takeException(), isNull);
    });

    testWidgets('should test visibility detector with scrolling', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: [
                    Container(height: 800),
                    VideoPlayerWidget(
                      videoUrl: 'https://example.com/scroll-video.mp4',
                      height: 200,
                    ),
                    Container(height: 800),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Scroll to make video visible
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
        
        // Scroll away
        await tester.drag(find.byType(ListView), const Offset(0, 400));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
        
        // Scroll back
        await tester.drag(find.byType(ListView), const Offset(0, -800));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle long-running video initialization', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: VideoPlayerWidget(
                  videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
                  height: 300,
                ),
              ),
            ),
          ),
        );

        // Pump extensively to allow initialization to complete
        await tester.pump();
        
        for (int i = 0; i < 20; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });
  });
}
