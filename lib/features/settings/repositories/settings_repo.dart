import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';

abstract class SettingsRepo {
  Future<Either<Failure, SettingsModel>> getSettings(String username);
  Future<Either<Failure, SettingsModel>> updateSettings({required SettingsModel newModel});

  Future<Either<Failure, List<UserModel>>> getBlockedAccounts(String username);
  Future<Either<Failure, List<UserModel>>> getMutedAccounts(String username);

  /// Paginated muted accounts endpoint (/api/mutes)
  /// limit: number of users per page
  /// cursor: opaque pagination cursor returned by previous response
  Future<Either<Failure, MutedUsersResponse>> fetchMutedAccounts({int limit = 30, String? cursor});
  Future<Either<Failure, MutedUsersResponse>> fetchBlockedAccounts({int limit = 30, String? cursor});

  Future<Either<Failure, void>> blockAccount(String username);
  Future<Either<Failure, void>> unblockAccount(String username);
  Future<Either<Failure, void>> muteAccount(String username);
  Future<Either<Failure, void>> unMuteAccount(String username);
  Future<Either<Failure, void>> followUser(String username);
  Future<Either<Failure, void>> unFollowUser(String username);
}
