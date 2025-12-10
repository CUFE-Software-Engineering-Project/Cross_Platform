import 'package:flutter_riverpod/legacy.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_states.dart';

class ProfileBasicDataNotifier extends StateNotifier<ProfileBasicDataStates> {
  final ProfileRepo profileRepo;
  final String userName;
  ProfileBasicDataNotifier({required this.profileRepo, required this.userName})
    : super(ProfileBasicDataStates.initial()) {
    loadProfileData(userName);
  }

  void loadProfileData(String userName) async {
    state = state.copyWith(isLoading: true);

    final Either<Failure, ProfileModel> result = await profileRepo
        .getProfileData(userName);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (profileData) {
        state = state.copyWith(isLoading: false, profileData: profileData);
      },
    );
  }
}
