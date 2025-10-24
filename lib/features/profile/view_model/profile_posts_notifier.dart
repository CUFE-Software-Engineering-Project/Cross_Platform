import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/profile_posts_states.dart';

class ProfilePostsNotifier extends StateNotifier<ProfilePostsStates> {

  final ProfileRepo profileRepo;
  ProfilePostsNotifier({required this.profileRepo})
      : super(ProfilePostsStates.initial()) {
    loadProfilePosts();
  }

  void loadProfilePosts() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await profileRepo.getProfilePosts();
      result.fold((failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      }, (posts) {
        state = state.copyWith(isLoading: false, posts: posts);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  
  }

}
