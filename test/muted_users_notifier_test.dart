import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';
import 'package:lite_x/features/settings/view_model/muted_users_notifier.dart';

class _FakeRepo implements SettingsRepo {
  final Map<String?, MutedUsersResponse> responses;
  final bool shouldError;

  _FakeRepo({required this.responses, this.shouldError = false});

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchMutedAccounts({int limit = 30, String? cursor}) async {
    if (shouldError) return Left(Failure('network error'));
    final key = cursor;
    final resp = responses[key];
    if (resp != null) return Right(resp);
    // default empty
    return Right(MutedUsersResponse.empty());
  }

  // Unused remainder of interface -- provide trivial implementations
  @override
  Future<Either<Failure, SettingsModel>> getSettings(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SettingsModel>> updateSettings({required SettingsModel newModel}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<UserModel>>> getBlockedAccounts(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<UserModel>>> getMutedAccounts(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> blockAccount(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> unblockAccount(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> muteAccount(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> unMuteAccount(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> followUser(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> unFollowUser(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MutedUsersResponse>> fetchBlockedAccounts({int limit = 30, String? cursor}) async {
    // Not used in this test; return empty page
    return Right(MutedUsersResponse.empty());
  }
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
  test('initial fetch populates state', () async {
    final page1 = MutedUsersResponse(
      users: [
        UserModel(displayName: 'A', userName: 'a', image: '', bio: ''),
        UserModel(displayName: 'B', userName: 'b', image: '', bio: ''),
      ],
      nextCursor: 'cursor1',
      hasMore: true,
    );

    final fake = _FakeRepo(responses: {null: page1});
    final notifier = MutedUsersNotifier(settingsRepo: fake, pageSize: 2);

    await waitForCondition(() async => notifier.state.isLoading == false);

    expect(notifier.state.users.length, 2);
    expect(notifier.state.hasMore, true);
    expect(notifier.state.nextCursor, 'cursor1');
    expect(notifier.state.errorMessage, isNull);
  });

  test('loadMore appends pages', () async {
    final page1 = MutedUsersResponse(
      users: [
        UserModel(displayName: 'A', userName: 'a', image: '', bio: ''),
        UserModel(displayName: 'B', userName: 'b', image: '', bio: ''),
      ],
      nextCursor: 'cursor1',
      hasMore: true,
    );

    final page2 = MutedUsersResponse(
      users: [UserModel(displayName: 'C', userName: 'c', image: '', bio: '')],
      nextCursor: null,
      hasMore: false,
    );

    final fake = _FakeRepo(responses: {null: page1, 'cursor1': page2});
    final notifier = MutedUsersNotifier(settingsRepo: fake, pageSize: 2);

    await waitForCondition(() async => notifier.state.isLoading == false);
    expect(notifier.state.users.length, 2);

    await notifier.loadMore();
    await waitForCondition(() async => notifier.state.users.length == 3);

    expect(notifier.state.users.length, 3);
    expect(notifier.state.hasMore, false);
  });

  test('error from repo sets errorMessage', () async {
    final fake = _FakeRepo(responses: {}, shouldError: true);
    final notifier = MutedUsersNotifier(settingsRepo: fake);

    await waitForCondition(() async => notifier.state.isLoading == false);

    expect(notifier.state.errorMessage, isNotNull);
    expect(notifier.state.users.length, 0);
  });
}
