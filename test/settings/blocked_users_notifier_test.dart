
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';
import 'package:lite_x/features/settings/view_model/blocked_users_notifier.dart';

import 'settings_mocks.mocks.dart';
import 'mocks.dart' as utils;

void main() {
  group('BlockedUsersNotifier', () {
    late MockSettingsRepo mockRepo;

    setUp(() {
      mockRepo = MockSettingsRepo();
    });

    test('fetchInitial populates users', () async {
      final u1 = UserModel(displayName: 'A', userName: 'a', image: '', bio: '', isVerified: false);
            when(mockRepo.fetchBlockedAccounts(limit: 10, cursor: null))
              .thenAnswer((_) async => Right(MutedUsersResponse(users: [u1], nextCursor: null, hasMore: false)));

      final notifier = BlockedUsersNotifier(settingsRepo: mockRepo, pageSize: 10);
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.users.length, 1);
      expect(notifier.state.users.first.userName, 'a');
    });

    test('loadMore appends users when hasMore true', () async {
      final u1 = UserModel(displayName: 'A', userName: 'a', image: '', bio: '', isVerified: false);
      final u2 = UserModel(displayName: 'B', userName: 'b', image: '', bio: '', isVerified: false);

            when(mockRepo.fetchBlockedAccounts(limit: 10, cursor: null)).thenAnswer((_) async =>
              Right(MutedUsersResponse(users: [u1], nextCursor: 'c1', hasMore: true)));

            when(mockRepo.fetchBlockedAccounts(limit: 10, cursor: 'c1')).thenAnswer((_) async =>
          Right(MutedUsersResponse(users: [u2], nextCursor: null, hasMore: false)));

      final notifier = BlockedUsersNotifier(settingsRepo: mockRepo, pageSize: 10);
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.users.length, 1);
      expect(notifier.state.hasMore, true);

      await notifier.loadMore();
      await utils.waitForCondition(() => notifier.state.isLoadingMore == false);

      expect(notifier.state.users.length, 2);
      expect(notifier.state.users.map((u) => u.userName).toList(), ['a', 'b']);
    });

    test('reports error on fetch failure', () async {
            when(mockRepo.fetchBlockedAccounts(limit: 10, cursor: null)).thenAnswer((_) async => Left(Failure('err')));

      final notifier = BlockedUsersNotifier(settingsRepo: mockRepo, pageSize: 10);
      await utils.waitForCondition(() => notifier.state.isLoading == false);

      expect(notifier.state.errorMessage, 'err');
      expect(notifier.state.users.length, 0);
    });
  });
}
