import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/settings/models/settings_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';
import 'settings_basic_data_states.dart';

class SettingsBasicDataNotifier extends StateNotifier<SettingsBasicDataStates> {
  final SettingsRepo settingsRepo;
  final String username;
  SettingsBasicDataNotifier({required this.settingsRepo, required this.username})
      : super(SettingsBasicDataStates.initial()) {
    loadSettingsData();
  }

  Future<void> loadSettingsData() async {
    state = state.copyWith(isLoading: true);
    final Either<Failure, SettingsModel> result =
        await settingsRepo.getSettings(username);
    result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }, (settings) {
      state = state.copyWith(isLoading: false, settingsData: settings);
    });
  }

  Future<void> updateSettings(SettingsModel newModel) async {
    state = state.copyWith(isLoading: true);
    final Either<Failure, SettingsModel> result =
        await settingsRepo.updateSettings(newModel: newModel);
    result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }, (settings) {
      state = state.copyWith(isLoading: false, settingsData: settings);
    });
  }
}
