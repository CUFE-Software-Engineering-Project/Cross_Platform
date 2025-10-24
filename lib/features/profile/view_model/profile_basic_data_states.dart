import 'package:lite_x/features/profile/models/profile_model.dart';

class ProfileBasicDataStates {
  final bool isLoading;
  final String? errorMessage;
  final ProfileModel? profileData;

  ProfileBasicDataStates({
    required this.isLoading,
    required this.errorMessage,
    required this.profileData,
  });

  ProfileBasicDataStates copyWith({
    bool? isLoading,
    String? errorMessage,
    ProfileModel? profileData,
  }) {
    return ProfileBasicDataStates(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      profileData: profileData ?? this.profileData,
    );
  }

  factory ProfileBasicDataStates.initial() {
    return ProfileBasicDataStates(
      isLoading: false,
      errorMessage: null,
      profileData: null,
    );
  }
}
