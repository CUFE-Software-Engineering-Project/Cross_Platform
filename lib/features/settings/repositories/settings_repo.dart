import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';

abstract class SettingsRepo {
  Future<Either<Failure, SettingsModel>> getSettings(String username);
  Future<Either<Failure, SettingsModel>> updateSettings({required SettingsModel newModel});

  Future<Either<Failure, List<UserModel>>> getBlockedAccounts(String username);
  Future<Either<Failure, List<UserModel>>> getMutedAccounts(String username);

  Future<Either<Failure, void>> blockAccount(String username);
  Future<Either<Failure, void>> unblockAccount(String username);
  Future<Either<Failure, void>> muteAccount(String username);
  Future<Either<Failure, void>> unMuteAccount(String username);
  Future<Either<Failure, void>> followUser(String username);
}
