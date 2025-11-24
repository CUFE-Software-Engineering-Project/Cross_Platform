import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';
import 'package:lite_x/features/settings/view_model/blocked_users_notifier.dart';

class _FakeRepo implements SettingsRepo {
  final Map<String?, MutedUsersResponse> responses;
  final bool shouldError;

  _FakeRepo({required this.responses, this.shouldError = false});

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchBlockedAccounts({int limit = 30, String? cursor}) async {
    if (shouldError) return Left(Failure('network error'));
    final resp = responses[cursor];
    if (resp != null) return Right(resp);
    return Right(MutedUsersResponse.empty());
  }

  // other methods not used in test
  @override
  Future<Either<Failure, SettingsModel>> getSettings(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, SettingsModel>> updateSettings({required SettingsModel newModel}) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<UserModel>>> getBlockedAccounts(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<UserModel>>> getMutedAccounts(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, MutedUsersResponse>> fetchMutedAccounts({int limit = 30, String? cursor}) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> blockAccount(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> unblockAccount(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> muteAccount(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> unMuteAccount(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> unFollowUser(String username) => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> followUser(String username) => throw UnimplementedError();
}

Future<void> waitForCondition(FutureOr<bool> Function() cond, {Duration timeout = const Duration(seconds: 2)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    final ok = await cond();
    if (ok) return;
    await Future.delayed(const Duration(milliseconds: 20));
  }
  throw Exception('timeout waiting for condition');
}

void main() {
  test('initial fetch populates blocked state', () async {
    final page1 = MutedUsersResponse(
      users: [
        UserModel(displayName: 'X', userName: 'x', image: '', bio: ''),
      ],
      nextCursor: 'c1',
      hasMore: true,
    );

    final fake = _FakeRepo(responses: {null: page1});
    final notifier = BlockedUsersNotifier(settingsRepo: fake, pageSize: 10);

    await waitForCondition(() async => notifier.state.isLoading == false);

    expect(notifier.state.users.length, 1);
    expect(notifier.state.hasMore, true);
  });

  test('blocked loadMore appends users', () async {
    final p1 = MutedUsersResponse(users: [UserModel(displayName: 'A', userName: 'a', image: '', bio: '')], nextCursor: 'c1', hasMore: true);
    final p2 = MutedUsersResponse(users: [UserModel(displayName: 'B', userName: 'b', image: '', bio: '')], nextCursor: null, hasMore: false);

    final fake = _FakeRepo(responses: {null: p1, 'c1': p2});
    final notifier = BlockedUsersNotifier(settingsRepo: fake);

    await waitForCondition(() async => notifier.state.isLoading == false);
    expect(notifier.state.users.length, 1);

    await notifier.loadMore();
    await waitForCondition(() async => notifier.state.users.length == 2);

    expect(notifier.state.users.length, 2);
    expect(notifier.state.hasMore, false);
  });

  test('blocked error surfaces errorMessage', () async {
    final fake = _FakeRepo(responses: {}, shouldError: true);
    final notifier = BlockedUsersNotifier(settingsRepo: fake);

    await waitForCondition(() async => notifier.state.isLoading == false);
    expect(notifier.state.errorMessage, isNotNull);
  });
}
