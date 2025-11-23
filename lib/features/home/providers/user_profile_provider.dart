import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/home/models/user_profile_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';

final userProfileProvider = StateProvider<AsyncValue<UserProfileModel?>>((ref) {
  return const AsyncValue.data(null);
});

class UserProfileController {
  final Ref _ref;

  UserProfileController(this._ref);

  Future<void> loadCurrentUserProfile() async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser != null) {
      await fetchUserProfile(currentUser.username);
    }
  }

  Future<void> fetchUserProfile(String username) async {
    _ref.read(userProfileProvider.notifier).state = const AsyncValue.loading();

    try {
      final repository = _ref.read(homeRepositoryProvider);
      final profile = await repository.getUserProfile(username);
      print(
        '✅ Profile loaded: ${profile.name}, Photo URL: ${profile.profilePhotoUrl}',
      );
      _ref.read(userProfileProvider.notifier).state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      print('❌ Error loading profile: $e');
      _ref.read(userProfileProvider.notifier).state = AsyncValue.error(
        e,
        stackTrace,
      );
    }
  }

  void clear() {
    _ref.read(userProfileProvider.notifier).state = const AsyncValue.data(null);
  }
}

final userProfileControllerProvider = Provider<UserProfileController>((ref) {
  return UserProfileController(ref);
});
