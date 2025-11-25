import 'package:lite_x/features/profile/models/create_reply_model.dart';
import 'package:lite_x/features/profile/models/create_tweet_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';

abstract class ProfileRepo {
  Future<Either<Failure, ProfileModel>> getProfileData(String userName);

  Future<Either<Failure, List<UserModel>>> getFollowers(String userName);
  Future<Either<Failure, List<UserModel>>> getFollowings(String userName);
  Future<Either<Failure, List<UserModel>>> getVerifiedFollowers(
    String userName,
  );

  Future<Either<Failure, List<UserModel>>> getFollowersYouKnow(String userName);
  Future<Either<Failure, void>> followUser(String username);
  Future<Either<Failure, void>> unFollowUser(String username);
  Future<Either<Failure, ProfileModel>> updateProfile({
    required ProfileModel newModel,
  });

  // block and mute
  Future<Either<Failure, void>> blockUser(String username);

  Future<Either<Failure, void>> unBlockUser(String username);
  Future<Either<Failure, void>> muteUser(String username);
  Future<Either<Failure, void>> unMuteUser(String username);
  Future<Either<Failure, List<UserModel>>> getMutedList(String userName);
  Future<Either<Failure, List<UserModel>>> getBlockedList(String userName);

  Future<Either<Failure, void>> updateProfileBanner(
    String userId,
    String mediaId,
  );
  Future<Either<Failure, void>> updateProfilePhoto(
    String userId,
    String mediaId,
  );

  // tweets
  Future<Either<Failure, List<ProfileTweetModel>>> getProfilePosts(
    String username,
  );
  Future<Either<Failure, List<ProfileTweetModel>>> getMediaPosts(
    String username,
  );
  Future<Either<Failure, List<ProfileTweetModel>>> getProfileLikes(
    String username,
  );

  Future<Either<Failure, ProfileTweetModel>> getProfileTweet(String tweetId);
  Future<Either<Failure, void>> createTweet(CreateTweetModel createTweetModel);
  Future<Either<Failure, List<TweetReplyModel>>> getTweetReplies(
    String tweetId,
  );
  Future<Either<Failure, void>> deleteTweet(String tweetId);
  //profile search
  Future<Either<Failure, List<SearchUserModel>>> profileCurrentSearch(
    String query,
  );

  // tweets interactions
  Future<Either<Failure, void>> likeTweet(String tweetId);
  Future<Either<Failure, void>> unLikeTweet(String tweetId);
  Future<Either<Failure, void>> saveTweet(String tweetId);
  Future<Either<Failure, void>> unSaveTweet(String tweetId);
  Future<Either<Failure, void>> replyOnTweet(
    String tweetId,
    CreateReplyModel createreplyModel,
  );
  Future<Either<Failure, void>> retweetProfileTweet(
    String tweetId,
  );
  Future<Either<Failure, void>> deleteRetweetProfileTweet(String tweetId);
  

  // emain and password
  Future<Either<Failure, void>> changeEmailProfile(String newEmail);
  Future<Either<Failure, void>> verifyChangeEmailProfile(
    String newEmail,
    String code,
  );
  Future<Either<Failure, void>> changePasswordProfile(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  );
}
