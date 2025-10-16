import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/repositories/profile_repo_impl.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_notifier.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_states.dart';
import 'package:lite_x/features/profile/view_model/profile_posts_notifier.dart';
import 'package:lite_x/features/profile/view_model/profile_posts_states.dart';

final profileRepoProvider = Provider<ProfileRepo>((ref) {
  return ProfileRepoImpl();
});

final profileBasicDataNotifierProvider =
    StateNotifierProvider.autoDispose<
      ProfileBasicDataNotifier,
      ProfileBasicDataStates
    >((ref) {
      final profileRepo = ref.watch(profileRepoProvider);
      return ProfileBasicDataNotifier(profileRepo: profileRepo);
    });


final profilePostsNotifierProvider =
    StateNotifierProvider.autoDispose<
      ProfilePostsNotifier,
      ProfilePostsStates
    >((ref) {
      final profileRepo = ref.watch(profileRepoProvider);
      return ProfilePostsNotifier(profileRepo: profileRepo);
    });