import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/repositories/profile_repo_impl.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_notifier.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_states.dart';
import 'package:lite_x/features/profile/view_model/profile_posts_notifier.dart';
import 'package:lite_x/features/profile/view_model/profile_posts_states.dart';

final profileRepoProvider = Provider<ProfileRepo>((ref) {
  return ProfileRepoImpl(ref.watch(dioProvider));
});

final profileBasicDataNotifierProvider = StateNotifierProvider.autoDispose
    .family<ProfileBasicDataNotifier, ProfileBasicDataStates, String>((
      ref,
      username,
    ) {
      final profileRepo = ref.watch(profileRepoProvider);
      return ProfileBasicDataNotifier(
        profileRepo: profileRepo,
        userName: username,
      );
    });

final profilePostsNotifierProvider =
    StateNotifierProvider.autoDispose<ProfilePostsNotifier, ProfilePostsStates>(
      (ref) {
        final profileRepo = ref.watch(profileRepoProvider);
        return ProfilePostsNotifier(profileRepo: profileRepo);
      },
    );

final followersProvider =
    FutureProvider.family<Either<Failure, List<UserModel>>, String>((
      ref,
      username,
    ) async {
      final repo = ref.watch(profileRepoProvider);
      return repo.getFollowers(username);
    });

final followingsProvider =
    FutureProvider.family<Either<Failure, List<UserModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getFollowings(username);
    });

final followersYouKnowProvider =
    FutureProvider.family<Either<Failure, List<UserModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getFollowersYouKnow(username);
    });

final verifiedFollowersProvider =
    FutureProvider.family<Either<Failure, List<UserModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getVerifiedFollowers(username);
    });

final followControllerProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String username) {
    return repo.followUser(username);
  };
});

final unFollowControllerProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String username) {
    return repo.unFollowUser(username);
  };
});

final editProfileProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (ProfileModel newModel) {
    return repo.updateProfile(newModel: newModel);
  };
});

final tokenProvider = Provider<String>((_) => "");

final myUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider.select((e) => e!.username));
  return user;
});

// final myUserNameProvider = Provider<String>((ref) {
//   // final user = ref.watch(currentUserProvider.select((e) => e!.username));
//   return "hazememam";
// });
