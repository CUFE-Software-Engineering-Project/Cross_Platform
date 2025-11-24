import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/models/usermodel.dart' as core_user;
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';
import 'package:lite_x/features/settings/view_model/providers.dart';
import 'package:lite_x/features/settings/screens/BlockedAccounts_Screen.dart';
import 'package:lite_x/features/settings/screens/MutedAccounts_Screen.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';

class _FakeSettingsRepo implements SettingsRepo {
  final List<UserModel> blocked;
  final List<UserModel> muted;
  _FakeSettingsRepo({required this.blocked, required this.muted});

  @override
  Future<Either<Failure, List<UserModel>>> getBlockedAccounts(String username) async {
    return Right(blocked);
  }

  @override
  Future<Either<Failure, List<UserModel>>> getMutedAccounts(String username) async {
    return Right(muted);
  }

  @override
  Future<Either<Failure, void>> blockAccount(String username) async => const Right(());

  @override
  Future<Either<Failure, void>> unblockAccount(String username) async => const Right(());

  @override
  Future<Either<Failure, void>> muteAccount(String username) async => const Right(());

  @override
  Future<Either<Failure, void>> unMuteAccount(String username) async => const Right(());

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchMutedAccounts({int limit = 30, String? cursor}) async {
    return Right(MutedUsersResponse(users: muted, nextCursor: null, hasMore: false));
  }

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchBlockedAccounts({int limit = 30, String? cursor}) async {
    return Right(MutedUsersResponse(users: blocked, nextCursor: null, hasMore: false));
  }

  @override
  Future<Either<Failure, void>> followUser(String username) async => const Right(());

  @override
  Future<Either<Failure, SettingsModel>> getSettings(String username) async => Right(SettingsModel.initial(username));

  @override
  Future<Either<Failure, SettingsModel>> updateSettings({required SettingsModel newModel}) async => Right(newModel);

  @override
  Future<Either<Failure, void>> unFollowUser(String username) async => const Right(());
}

void main() {
  final fakeUser = core_user.UserModel(
    name: 'Tester',
    email: 't@example.com',
    dob: '2000-01-01',
    username: 'tester',
    id: '1',
    isEmailVerified: true,
    isVerified: false,
  );

  final blocked = [
    UserModel(displayName: 'CentreGoals.', userName: 'centregoals', image: '', bio: 'An all-round coverage', isVerified: true),
    UserModel(displayName: 'Polymarket', userName: 'Polymarket', image: '', bio: "The world's largest prediction market.", isVerified: true),
  ];
  final muted = [
    UserModel(displayName: 'Hasan Ismaik', userName: 'HasanIsmaik', image: '', bio: 'Businessman, writer, researcher', isVerified: true),
  ];

  ProviderScope _scope(Widget child) => ProviderScope(
        overrides: [
          settingsRepoProvider.overrideWithValue(_FakeSettingsRepo(blocked: blocked, muted: muted)),
          currentUserProvider.overrideWithValue(fakeUser),
        ],
        child: MaterialApp(home: child),
      );

  testWidgets('BlockedAccountsScreen shows blocked list', (tester) async {
    await tester.pumpWidget(_scope(const BlockedAccountsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Blocked accounts'), findsOneWidget);
    expect(find.text('CentreGoals.'), findsOneWidget);
    expect(find.text('@centregoals'), findsOneWidget);
    expect(find.text('Polymarket'), findsOneWidget);
    expect(find.text('@Polymarket'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
  });

  testWidgets('MutedAccountsScreen shows muted list', (tester) async {
    await tester.pumpWidget(_scope(const MutedAccountsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Muted accounts'), findsOneWidget);
    expect(find.textContaining('Hasan Ismaik'), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
  });
}
