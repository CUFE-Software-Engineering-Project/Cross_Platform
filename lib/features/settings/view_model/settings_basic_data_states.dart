import 'package:lite_x/features/settings/models/settings_model.dart';

class SettingsBasicDataStates {
  final bool isLoading;
  final String? errorMessage;
  final SettingsModel? settingsData;

  const SettingsBasicDataStates({
    required this.isLoading,
    required this.errorMessage,
    required this.settingsData,
  });

  SettingsBasicDataStates copyWith({
    bool? isLoading,
    String? errorMessage,
    SettingsModel? settingsData,
  }) => SettingsBasicDataStates(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        settingsData: settingsData ?? this.settingsData,
      );

  factory SettingsBasicDataStates.initial() => const SettingsBasicDataStates(
        isLoading: false,
        errorMessage: null,
        settingsData: null,
      );
}
