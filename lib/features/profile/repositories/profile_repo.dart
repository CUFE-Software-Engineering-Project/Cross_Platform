import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/create_reply_model.dart';
import 'package:lite_x/features/profile/models/create_tweet_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/trends/models/for_you_response_model.dart';
import 'package:lite_x/features/trends/models/paginated_tweets.dart';
import 'package:lite_x/features/trends/models/trend_category.dart';
import 'package:lite_x/features/trends/models/trend_model.dart';

abstract class ProfileRepo {
  Future<Either<Failure, ProfileModel>> getProfileData(
    String userName,
    String currentUsername,
  );

  Future<Either<Failure, List<UserModel>>> getFollowers(String userName);
  Future<Either<Failure, List<UserModel>>> getFollowings(String userName);
  Future<Either<Failure, List<UserModel>>> getVerifiedFollowers(
    String userName,
  );

  Future<Either<Failure, List<UserModel>>> getFollowersYouKnow(String userName);
  Future<Either<Failure, void>> followUser(String username, Ref ref);
  Future<Either<Failure, void>> unFollowUser(String username, Ref ref);
  Future<Either<Failure, ProfileModel>> updateProfile({
    required ProfileModel newModel,
  });

  // block and mute
  Future<Either<Failure, void>> blockUser(String username, Ref ref);

  Future<Either<Failure, void>> unBlockUser(String username, Ref ref);
  Future<Either<Failure, void>> muteUser(String username, Ref ref);
  Future<Either<Failure, void>> unMuteUser(String username, Ref ref);
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
  Future<Either<Failure, void>> deleteTweet(String tweetId, Ref ref);
  //profile search
  Future<Either<Failure, List<SearchUserModel>>> profileCurrentSearch(
    String query,
  );

  // tweets interactions
  Future<Either<Failure, void>> likeTweet(String tweetId, Ref ref);
  Future<Either<Failure, void>> unLikeTweet(String tweetId, Ref ref);
  Future<Either<Failure, void>> saveTweet(String tweetId);
  Future<Either<Failure, void>> unSaveTweet(String tweetId);
  Future<Either<Failure, void>> replyOnTweet(
    String tweetId,
    CreateReplyModel createreplyModel,
  );
  Future<Either<Failure, void>> retweetProfileTweet(String tweetId, Ref ref);
  Future<Either<Failure, void>> deleteRetweetProfileTweet(
    String tweetId,
    Ref ref,
  );

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

  Future<Either<Failure, ForYouResponseModel>> getForYouTrends();
  Future<Either<Failure, TrendCategory>> getTrenCategory(String catName);
  Future<Either<Failure, List<TrendModel>>> getAvailableTrends();
  Future<Either<Failure, List<UserModel>>> getWhoToFollow();
  Future<Either<Failure, List<ProfileTweetModel>>> getTweetsForHashtag(
    String hashtagId,
  );
  Future<Either<Failure, PaginatedTweets>> getTweetsForExploreCategory(
    String categoryName, {
    String? cursor,
  });
}
