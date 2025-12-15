import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:dartz/dartz.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  group('showUnFollowDialog', () {
    testWidgets('should show unfollow dialog with correct text', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showUnFollowDialog(context, 'TestUser');
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Unfollow TestUser?'), findsOneWidget);
      expect(find.text('Their posts will no longer show up in your home timeline. You can still view their profile, unless their posts are protected.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Unfollow'), findsOneWidget);
    });

    testWidgets('should return false when Cancel is tapped', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showUnFollowDialog(context, 'TestUser');
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('should return true when Unfollow is tapped', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showUnFollowDialog(context, 'TestUser');
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unfollow'));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });

  group('showPopupMessage', () {
    testWidgets('should show popup with title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showPopupMessage(
                      context: context,
                      title: Text('Test Title'),
                      message: Text('Test Message'),
                    );
                  },
                  child: Text('Show Popup'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('should return true when Yes is tapped', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showPopupMessage(
                      context: context,
                      title: Text('Confirm'),
                      message: Text('Are you sure?'),
                    );
                  },
                  child: Text('Show Popup'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('should return false when No is tapped', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showPopupMessage(
                      context: context,
                      title: Text('Confirm'),
                      message: Text('Are you sure?'),
                    );
                  },
                  child: Text('Show Popup'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('should use custom button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showPopupMessage(
                      context: context,
                      title: Text('Delete'),
                      message: Text('Delete this item?'),
                      confirmText: 'Delete',
                      cancelText: 'Keep',
                    );
                  },
                  child: Text('Show Popup'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsNWidgets(2)); // Title and button
      expect(find.text('Keep'), findsOneWidget);
    });
  });

  group('showSmallPopUpMessage', () {
    testWidgets('should show snackbar with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSmallPopUpMessage(
                      context: context,
                      message: 'Test notification',
                      borderColor: Colors.blue,
                      icon: Icon(Icons.check, color: Colors.blue),
                    );
                  },
                  child: Text('Show Snackbar'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();

      expect(find.text('Test notification'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should show snackbar with error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showSmallPopUpMessage(
                      context: context,
                      message: 'Error occurred',
                      borderColor: Colors.red,
                      icon: Icon(Icons.error, color: Colors.red),
                    );
                  },
                  child: Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });

  group('showRetweetBottomSheet', () {
    testWidgets('should show bottom sheet with retweet options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showRetweetBottomSheet(context, 'Retweet', 'Quote');
                  },
                  child: Text('Show Bottom Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Retweet'), findsOneWidget);
      expect(find.text('Quote'), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.edit_square), findsOneWidget);
    });

    testWidgets('should return RetweetOption.retweet when Retweet is tapped', (tester) async {
      RetweetOption? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showRetweetBottomSheet(context, 'Retweet', 'Quote');
                  },
                  child: Text('Show Bottom Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retweet'));
      await tester.pumpAndSettle();

      expect(result, RetweetOption.retweet);
    });

    testWidgets('should return RetweetOption.quote when Quote is tapped', (tester) async {
      RetweetOption? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showRetweetBottomSheet(context, 'Retweet', 'Quote');
                  },
                  child: Text('Show Bottom Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quote'));
      await tester.pumpAndSettle();

      expect(result, RetweetOption.quote);
    });

    testWidgets('should show UnRetweet option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showRetweetBottomSheet(context, 'UnRetweet', 'Quote');
                  },
                  child: Text('Show Bottom Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('UnRetweet'), findsOneWidget);
    });
  });

  group('BuildSmallProfileImage', () {
    testWidgets('should render with mediaId', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('avatar123').overrideWith((ref) => Future.value('https://example.com/avatar.jpg')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildSmallProfileImage(
                radius: 20,
                mediaId: 'avatar123',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should render with username', (tester) async {
      final testProfile = ProfileModel(
        id: 'user1',
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
        birthDate: '',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: '',
        avatarId: 'avatar123',
        bannerId: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileDataProvider('testuser').overrideWith((ref) => Future.value(Right(testProfile))),
            mediaUrlProvider('avatar123').overrideWith((ref) => Future.value('https://example.com/avatar.jpg')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildSmallProfileImage(
                radius: 20,
                username: 'testuser',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should render default avatar when no mediaId or username', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BuildSmallProfileImage(
                radius: 20,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });

  group('BuildProfileBanner', () {
    testWidgets('should render banner with valid bannerId', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('banner123').overrideWith((ref) => Future.value('https://example.com/banner.jpg')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileBanner(bannerId: 'banner123'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render empty banner with empty bannerId', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileBanner(bannerId: ''),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('banner123').overrideWith((ref) => Future.error('Error')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileBanner(bannerId: 'banner123'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Container), findsOneWidget);
    });
  });

  group('BuildProfileImage', () {
    testWidgets('should render profile image with valid avatarId', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('avatar123').overrideWith((ref) => Future.value('https://example.com/avatar.jpg')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileImage(avatarId: 'avatar123'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsNWidgets(2)); // Outer and inner
    });

    testWidgets('should handle error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('avatar123').overrideWith((ref) => Future.error('Error')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileImage(avatarId: 'avatar123'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });

    testWidgets('should use default avatar on empty url', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('avatar123').overrideWith((ref) => Future.value('')),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileImage(avatarId: 'avatar123'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });
  });

  group('BuildSmallProfileImage - Error States', () {
    testWidgets('should handle profileData error when username provided',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileDataProvider('testuser').overrideWith((ref) {
              return Future.value(Left(Failure('Error loading profile')));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildSmallProfileImage(
                username: 'testuser',
                radius: 20,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should handle mediaUrl error in nested when',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileDataProvider('testuser').overrideWith((ref) {
              return Future.value(Right(ProfileModel(
                id: '1',
                username: 'testuser',
                displayName: 'Test User',
                email: 'test@test.com',
                birthDate: '1990-01-01',
                isVerified: false,
                followersCount: 0,
                followingCount: 0,
                bio: '',
                avatarId: 'avatar123',
                bannerId: '',
                tweetsCount: 0,
                joinedDate: '',
                website: '',
                location: '',
                postCount: 0,
                isFollowing: false,
                isFollower: false,
                protectedAccount: false,
                isBlockedByMe: false,
                isMutedByMe: false,
              )));
            }),
            mediaUrlProvider('avatar123').overrideWith((ref) {
              throw Exception('Media load error');
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildSmallProfileImage(
                username: 'testuser',
                radius: 20,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should handle mediaUrl loading state in nested when',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileDataProvider('testuser').overrideWith((ref) {
              return Future.value(Right(ProfileModel(
                id: '1',
                username: 'testuser',
                displayName: 'Test User',
                email: 'test@test.com',
                birthDate: '1990-01-01',
                isVerified: false,
                followersCount: 0,
                followingCount: 0,
                bio: '',
                avatarId: 'avatar123',
                bannerId: '',
                tweetsCount: 0,
                joinedDate: '',
                website: '',
                location: '',
                postCount: 0,
                isFollowing: false,
                isFollower: false,
                protectedAccount: false,
                isBlockedByMe: false,
                isMutedByMe: false,
              )));
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildSmallProfileImage(
                username: 'testuser',
                radius: 20,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  group('BuildProfileBanner - Error State', () {
    testWidgets('should handle error state with refresh call',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('banner123').overrideWith((ref) {
              throw Exception('Banner load error');
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileBanner(bannerId: 'banner123'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('BuildProfileImage - Error State', () {
    testWidgets('should handle error state with read call',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaUrlProvider('avatar123').overrideWith((ref) {
              throw Exception('Avatar load error');
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BuildProfileImage(avatarId: 'avatar123'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });
  });
}
