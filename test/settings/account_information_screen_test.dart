import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/auth/view_model/auth_view_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/settings/screens/AccountInformation_Screen.dart';
import 'package:mockito/mockito.dart';

import 'account_info_mocks.mocks.dart';
import 'navigator_observer_mocks.mocks.dart';

void _registerMockitoDummies() {
  // Mockito needs dummy values for generic types used in generated mocks.
  provideDummy<Either<Failure, ProfileModel>>(const Left(Failure('dummy')));
}

// dummies will be registered in `main` before tests run

// Fake Notifier for testing
class FakeCurrentUser extends CurrentUser {
  final core_user.UserModel? _user;
  FakeCurrentUser(this._user);

  @override
  core_user.UserModel? build() {
    return _user;
  }
}

// Fake Notifier for testing that can also be mocked
class FakeAuthViewModel extends AuthViewModel with Mock {
  @override
  Future<void> logout() {
    return super.noSuchMethod(
      Invocation.method(#logout, []),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future.value(null),
    );
  }
}

void main() {
  setUpAll(() {
    _registerMockitoDummies();
  });
  group('AccountInformationScreen', () {
    final mockCoreUser = core_user.UserModel(
      id: 'mock_id',
      name: 'Mock User',
      email: 'mock@test.com',
      dob: '2000-01-01',
      username: 'testuser',
      isEmailVerified: true,
      isVerified: false,
    );

    late FakeAuthViewModel fakeAuthViewModel;
    late MockProfileRepo mockProfileRepo;
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      fakeAuthViewModel = FakeAuthViewModel();
      mockProfileRepo = MockProfileRepo();
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Future<void> pumpTheWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(() => FakeCurrentUser(mockCoreUser)),
            authViewModelProvider.overrideWith(() => fakeAuthViewModel),
            profileRepoProvider.overrideWithValue(mockProfileRepo),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/account_info',
              observers: [mockNavigatorObserver],
              routes: [
                GoRoute(
                  path: '/account_info',
                  builder: (context, state) => const AccountInformationScreen(),
                ),
                GoRoute(
                  path: '/changeEmailProfileScreen',
                  builder: (context, state) => const Scaffold(body: Text('Change Email Screen')),
                ),
                GoRoute(
                  path: '/intro',
                  name: RouteConstants.introscreen,
                  builder: (context, state) => const Scaffold(body: Text('Intro Screen')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders user information correctly', (tester) async {
      await pumpTheWidget(tester);

      expect(find.text('@testuser'), findsNWidgets(2));
      expect(find.text('mock@test.com'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('calls logout and navigates when "Log out" is tapped', (tester) async {
      when(fakeAuthViewModel.logout()).thenAnswer((_) async {});

      await pumpTheWidget(tester);

      await tester.scrollUntilVisible(
        find.text('Log out'),
        500.0,
      );

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      verify(fakeAuthViewModel.logout()).called(1);
      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Intro Screen'), findsOneWidget);
    });

    testWidgets('navigates to change email screen when email is tapped and data fetches successfully', (tester) async {
      final mockProfile = ProfileModel(
          id: 'id',
          username: 'username',
          displayName: 'displayName',
          bio: 'bio',
          avatarUrl: 'avatarUrl',
          bannerUrl: 'bannerUrl',
          followersCount: 0,
          followingCount: 0,
          tweetsCount: 0,
          isVerified: false,
          joinedDate: 'joinedDate',
          website: 'website',
          location: 'location',
          postCount: 0,
          birthDate: 'birthDate',
          isFollowing: false,
          isFollower: false,
          protectedAccount: false,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'email',
          avatarId: 'avatarId');
      when(mockProfileRepo.getProfileData('testuser')).thenAnswer((_) async => Right(mockProfile));

      await pumpTheWidget(tester);

      await tester.tap(find.text('mock@test.com'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.text('Change Email Screen'), findsOneWidget);
    });
  });
}
