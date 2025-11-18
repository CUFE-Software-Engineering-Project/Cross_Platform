import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';
import 'package:lite_x/features/settings/repositories/settings_repo_impl.dart';
import 'package:lite_x/features/settings/view_model/settings_basic_data_notifier.dart';
import 'package:lite_x/features/settings/view_model/settings_basic_data_states.dart';

final settingsRepoProvider = Provider<SettingsRepo>((ref) {
	final dio = ref.watch(dioProvider);
	return SettingsRepoImpl(dio);
});

final settingsBasicDataNotifierProvider = StateNotifierProvider.autoDispose
		.family<SettingsBasicDataNotifier, SettingsBasicDataStates, String>((
	ref,
	username,
) {
	final repo = ref.watch(settingsRepoProvider);
	return SettingsBasicDataNotifier(settingsRepo: repo, username: username);
});

final blockedAccountsProvider = FutureProvider<Either<Failure, List<UserModel>>>((ref) async {
	final repo = ref.watch(settingsRepoProvider);
	final user = ref.watch(currentUserProvider);
	if (user == null) {
		return Left(Failure('No current user'));
	}
	return repo.getBlockedAccounts(user.username);
});

final mutedAccountsProvider = FutureProvider<Either<Failure, List<UserModel>>>((ref) async {
	final repo = ref.watch(settingsRepoProvider);
	final user = ref.watch(currentUserProvider);
	if (user == null) {
		return Left(Failure('No current user'));
	}
	return repo.getMutedAccounts(user.username);
});

final blockControllerProvider = Provider((ref) {
	final repo = ref.watch(settingsRepoProvider);
	return (String username) => repo.blockAccount(username);
});

final unblockControllerProvider = Provider((ref) {
	final repo = ref.watch(settingsRepoProvider);
	return (String username) => repo.unblockAccount(username);
});

final muteControllerProvider = Provider((ref) {
	final repo = ref.watch(settingsRepoProvider);
	return (String username) => repo.muteAccount(username);
});

final unMuteControllerProvider = Provider((ref) {
	final repo = ref.watch(settingsRepoProvider);
	return (String username) => repo.unMuteAccount(username);
});

final followMutedAccountControllerProvider = Provider((ref) {
	final repo = ref.watch(settingsRepoProvider);
	return (String username) => repo.followUser(username);
});

final updateSettingsControllerProvider = Provider((ref) {
  final repo = ref.watch(settingsRepoProvider);
  return (SettingsModel model) => repo.updateSettings(newModel: model);
});
