import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/core/providers/dio_interceptor.dart';
import 'package:lite_x/features/media/download_media.dart';
import 'package:lite_x/features/profile/models/create_reply_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/repositories/profile_repo_impl.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_notifier.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_states.dart';

final profileRepoProvider = Provider<ProfileRepo>((ref) {
  return ProfileRepoImpl(ref.watch(dioProvider));
});

final profileDataProvider =
    FutureProvider.family<Either<Failure, ProfileModel>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getProfileData(username);
    });

final updateProfileBannerProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String userId, String mediaId) {
    return repo.updateProfileBanner(userId, mediaId);
  };
});

final updateProfilePhotoProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String userId, String mediaId) {
    return repo.updateProfilePhoto(userId, mediaId);
  };
});

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

final blockUserProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String username) {
    return repo.blockUser(username);
  };
});

final unBlockUserProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String username) {
    return repo.unBlockUser(username);
  };
});

final getBlockedUsersProvider =
    FutureProvider.family<Either<Failure, List<UserModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getBlockedList(username);
    });

final getMutedUsersProvider =
    FutureProvider.family<Either<Failure, List<UserModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getMutedList(username);
    });

final muteUserProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String username) {
    return repo.muteUser(username);
  };
});

final unMuteUserProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String username) {
    return repo.unMuteUser(username);
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

//tweets

final profilePostsProvider =
    FutureProvider.family<Either<Failure, List<ProfileTweetModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getProfilePosts(username);
    });

final profileLikesProvider =
    FutureProvider.family<Either<Failure, List<ProfileTweetModel>>, String>((
      ref,
      username,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getProfileLikes(username);
    });

final tweetRepliesProvider =
    FutureProvider.family<Either<Failure, List<TweetReplyModel>>, String>((
      ref,
      tweetId,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.getTweetReplies(tweetId);
    });

final deleteTweetProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String tweetId) {
    return repo.deleteTweet(tweetId);
  };
});

// tweets reactions
final likeTweetProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String tweetId) {
    return repo.likeTweet(tweetId);
  };
});

final unlikeTweetProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String tweetId) {
    return repo.unLikeTweet(tweetId);
  };
});

final saveTweetProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String tweetId) {
    return repo.saveTweet(tweetId);
  };
});

final unSaveTweetProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String tweetId) {
    return repo.unSaveTweet(tweetId);
  };
});

final replyOnTweetProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String tweetId, CreateReplyModel createReplyModel) {
    return repo.replyOnTweet(tweetId, createReplyModel);
  };
});

// search
final profileCurrentSearchProvider =
    FutureProvider.family<Either<Failure, List<SearchUserModel>>, String>((
      ref,
      query,
    ) {
      final repo = ref.watch(profileRepoProvider);
      return repo.profileCurrentSearch(query);
    });

// change email & password
final changeEmailProfileProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String newEmail) {
    return repo.changeEmailProfile(newEmail);
  };
});

final verifyChangeEmailProfileProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return (String newEmail, String code) {
    return repo.verifyChangeEmailProfile(newEmail, code);
  };
});

final changePasswordProfileProvider = Provider((ref) {
  final repo = ref.watch(profileRepoProvider);
  return ({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return repo.changePasswordProfile(
      oldPassword,
      newPassword,
      confirmNewPassword,
    );
  };
});

final myUserNameProvider = Provider<String>((ref) {
  final Myusername = ref.watch(currentUserProvider.select((e) => e!.username));
  return Myusername;
});

// final myUserNameProvider = Provider<String>((ref) {
//   // final user = ref.watch(currentUserProvider.select((e) => e!.username));
//   return "hazememam";
// });

final mediaUrlsProvider = FutureProvider.family<List<String>, List<String>>((
  ref,
  mediaIds,
) async {
  // Replace this with your actual function that fetches media URLs
  return await getMediaUrls(mediaIds);
});
