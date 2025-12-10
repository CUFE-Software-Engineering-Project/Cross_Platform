import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/media/download_media.dart';
import 'package:lite_x/features/profile/models/create_reply_model.dart';
import 'package:lite_x/features/profile/models/create_tweet_model.dart';
import 'package:lite_x/features/profile/models/follower_model.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/repositories/profile_storage_service.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/models/for_you_response_model.dart';
import 'package:lite_x/features/trends/models/trend_category.dart';

class ProfileRepoImpl implements ProfileRepo {
  Dio _dio;
  ProfileRepoImpl(Dio d) : _dio = d {}

  @override
  Future<Either<Failure, ProfileModel>> getProfileData(
    String userName,
    String currentUsername,
  ) async {
    final Response res;
    final ProfileStorageService storageService = ProfileStorageService();

    try {
      res = await _dio.get("api/users/$userName");
      final Map<String, dynamic> json = res.data;

      final profileData = ProfileModel.fromJson(json);

      if (userName == currentUsername) {
        await storageService.init();
        storageService.storeProfileData(profileData).then((onValue) {
          storageService.close();
        });
      }

      return Right(profileData);
    } on DioException catch (e) {
      print(e.toString());
      if (userName == currentUsername) {
        await storageService.init();
        final localData = await storageService.getProfileData(currentUsername);
        storageService.close();
        if (localData == null) {
          return Left(
            Failure('Failed to load profile data, try agian later...'),
          );
        } else {
          return Right(localData);
        }
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Left(Failure('connection timeout, please try agin...'));
        }
        return Left(Failure('Failed to load profile data, try agian later...'));
      }
    } catch (e) {
      if (userName == currentUsername) {
        await storageService.init();
        final localData = await storageService.getProfileData(currentUsername);
        storageService.close();
        if (localData == null)
          return Left(
            Failure('Failed to load profile data, try agian later...'),
          );
        else {
          return Right(localData);
        }
      }
      return Left(Failure('Failed to load profile data'));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile({
    required ProfileModel newModel,
  }) async {
    final formatedDob = parseFormattedDate(newModel.birthDate);
    String dob = "";
    if (formatedDob != null)
      dob = "${formatedDob.month}-${formatedDob.day}-${formatedDob.year}";

    try {
      final json = {
        "username": newModel.username,
        "name": newModel.displayName,
        "bio": newModel.bio,
        "protectedAccount": newModel.protectedAccount,
        "website": newModel.website,
        "address": newModel.location,
        "dateOfBirth": dob,
      };
      print(json.toString());
      final res = await _dio.patch("api/users/${newModel.id}", data: json);

      return Right(ProfileModel.fromJson(res.data));
    } catch (e) {
      print("----------\n${e.toString()}\n---------");
      return Left(Failure("can't update profile data"));
    }
  }

  @override
  Future<Either<Failure, List<ProfileTweetModel>>> getProfilePosts(
    String username,
  ) async {
    try {
      final res = await _dio.get("api/tweets/users/$username");

      final List<dynamic> jsonList = res.data["data"] ?? [];

      final tweets = convertJsonListToTweetList(jsonList);

      return Right(tweets);
    } catch (e) {
      // print(e.toString() + "--------------+++++++++++++++++");
      return Left(Failure('Failed to load profile posts'));
    }
  }

  Future<Either<Failure, ProfileTweetModel>> getProfileTweet(
    String tweetId,
  ) async {
    try {
      // print("Start api ---------------------**");
      final res = await _dio.get("api/tweets/$tweetId");
      // print("end api ---------------------**");

      final Map<String, dynamic> json = res.data as Map<String, dynamic>;
      // get profile photo url and tweet medial urls
      final String profilePhotoId = json["user"]?["profileMedia"]?["id"] ?? "";

      final List<dynamic> tweetMediaIdsDynamic = json["tweetMedia"] ?? [];
      final List<String> tweetMediaIds = tweetMediaIdsDynamic
          .map((media) => media["media"]?["id"] as String)
          .toList();

      // final List<String> userPhotoUrl = await getMediaUrls([profilePhotoId]);

      // final String profilePhotoUrl = userPhotoUrl[0];

      // get timeAgo
      final String createTime = json["createdAt"] ?? "";
      final String timeAgo = getTimeAgo(createTime);

      json["profileMediaId"] = profilePhotoId;
      json["mediaIds"] = tweetMediaIds;
      json["timeAgo"] = timeAgo;

      // print(
      //   "id$i" +
      //       "${json['profileMediaId']}--------------------*****--------------",
      // );

      // print("end repo posts ----------------**");
      return Right(ProfileTweetModel.fromJson(json));
    } catch (e) {
      print(e.toString() + "--------------+++++++++++++++++");
      return Left(Failure('Failed to load Tweet'));
    }
  }

  @override
  Future<Either<Failure, List<ProfileTweetModel>>> getMediaPosts(
    String username,
  ) async {
    try {
      // print("Start api ---------------------**");
      final res = await _dio.get("api/tweets/users/$username");
      // print("end api ---------------------**");
      final List<dynamic> jsonList = res.data["data"] ?? [];

      final tweets = convertJsonListToTweetList(jsonList);
      // print("end repo posts ----------------**");
      return Right(tweets);
    } catch (e) {
      // print(e.toString());
      return Left(Failure('Failed to load profile posts'));
    }
  }

  @override
  Future<Either<Failure, List<ProfileTweetModel>>> getProfileLikes(
    String username,
  ) async {
    try {
      try {
        // print("Start api ---------------------**");
        final res = await _dio.get("api/tweets/likedtweets");
        // print("end api ---------------------**");
        final List<dynamic> jsonList = res.data["data"] ?? [];

        final tweets = convertJsonListToTweetList(jsonList);

        return Right(tweets);
      } catch (e) {
        // print(e.toString());
        return Left(Failure('Failed to load profile posts'));
      }
    } catch (e) {
      // print(e.toString());
      return Left(Failure('Failed to load profile likes'));
    }
  }

  Future<Either<Failure, void>> updateProfileBanner(
    String userId,
    String mediaId,
  ) async {
    try {
      await _dio.patch("api/users/banner/$userId/$mediaId");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't update banner"));
    }
  }

  Future<Either<Failure, void>> updateProfilePhoto(
    String userId,
    String mediaId,
  ) async {
    try {
      await _dio.patch("api/users/profile-picture/$userId/$mediaId");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't update profile picture"));
    }
  }

  // user interactions

  Future<Either<Failure, List<UserModel>>> getFollowers(String userName) async {
    // await Future.delayed(const Duration(seconds: 1));

    try {
      final response = await _dio.get("api/followers/$userName");
      List<dynamic> jsonList = response.data['users'] as List<dynamic>;
      final List<UserModel> usersList = jsonList
          .map((json) => UserModel.fromJson(json))
          .toList();
      return Right(usersList);
    } catch (e) {
      // print("\n--------------\n$e\n-------------------\n");
      return Left(Failure("couldn't get user followers"));
    }
  }

  Future<Either<Failure, List<UserModel>>> getFollowings(
    String userName,
  ) async {
    try {
      final response = await _dio.get("api/followings/$userName");
      List<dynamic> jsonList = response.data['users'] as List<dynamic>;
      final List<UserModel> usersList = jsonList
          .map((json) => UserModel.fromJson(json))
          .toList();
      return Right(usersList);
    } catch (e) {
      // print("\n--------------\n$e\n-------------------\n");
      return Left(Failure("couldn't get user followings"));
    }
  }

  Future<Either<Failure, List<UserModel>>> getVerifiedFollowers(
    String userName,
  ) async {
    try {
      final response = await _dio.get("api/followers/$userName");
      List<dynamic> jsonList = response.data['users'] as List<dynamic>;
      final List<UserModel> usersList = jsonList
          .map((json) => UserModel.fromJson(json))
          .toList();
      final List<UserModel> verified = usersList
          .where((e) => e.isVerified == true)
          .toList();
      return Right(verified);
    } catch (e) {
      // print("\n--------------\n$e\n-------------------\n");
      return Left(Failure("couldn't get user verified followers"));
    }
  }

  Future<Either<Failure, List<UserModel>>> getFollowersYouKnow(
    String userName,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final response = await _dio.get("api/followers/$userName");
      List<dynamic> jsonList = response.data['users'] as List<dynamic>;
      final List<UserModel> usersList = jsonList
          .map((json) => UserModel.fromJson(json))
          .toList();
      final List<UserModel> youKnow = usersList
          .where((e) => e.isFollowing == true)
          .toList();
      return Right(youKnow);
    } catch (e) {
      // print("\n--------------\n$e\n-------------------\n");
      return Left(Failure("couldn't get user verified followers"));
    }
  }

  Future<Either<Failure, void>> followUser(String username) async {
    try {
      await _dio.post("api/followers/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't follow user"));
    }
  }

  Future<Either<Failure, void>> unFollowUser(String username) async {
    try {
      await _dio.delete("api/followers/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unfollow user"));
    }
  }

  // block and mute
  Future<Either<Failure, void>> blockUser(String username) async {
    try {
      await _dio.post("api/blocks/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't block user"));
    }
  }

  Future<Either<Failure, void>> unBlockUser(String username) async {
    try {
      await _dio.delete("api/blocks/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unblock user"));
    }
  }

  Future<Either<Failure, void>> muteUser(String username) async {
    try {
      await _dio.post("api/mutes/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't mute user"));
    }
  }

  Future<Either<Failure, void>> unMuteUser(String username) async {
    try {
      await _dio.delete("api/mutes/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unmute user"));
    }
  }

  Future<Either<Failure, List<UserModel>>> getMutedList(String userName) async {
    try {
      final res = await _dio.get("api/mutes");
      final List<dynamic> jsonList = res.data["users"];
      final List<UserModel> users = jsonList.map((json) {
        final Map<String, dynamic> jsonMap = json as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }).toList();
      return Right(users);
    } catch (e) {
      return Left(Failure("Can't get muted users, try again later.."));
    }
  }

  Future<Either<Failure, List<UserModel>>> getBlockedList(
    String userName,
  ) async {
    try {
      final res = await _dio.get("api/blocks");
      final List<dynamic> jsonList = res.data["users"];
      final List<UserModel> users = jsonList.map((json) {
        final Map<String, dynamic> jsonMap = json as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }).toList();
      return Right(users);
    } catch (e) {
      return Left(Failure("Can't get Blocked users, try again later.."));
    }
  }

  // tweets
  Future<Either<Failure, String>> createTweet(
    CreateTweetModel createTweetModel,
  ) async {
    try {
      final response = await _dio.post(
        "api/tweets",
        data: createTweetModel.toJson(),
      );
      return Right((response.data["id"] ?? ""));
    } catch (e) {
      return Left(Failure("Can't create tweet"));
    }
  }

  Future<Either<Failure, void>> deleteTweet(String tweetId) async {
    try {
      await _dio.delete("api/tweets/$tweetId");
      return Right(());
    } catch (e) {
      return Left(Failure("Can't delete tweet"));
    }
  }

  Future<Either<Failure, List<TweetReplyModel>>> getTweetReplies(
    String tweetId,
  ) async {
    try {
      final response = await _dio.get("api/tweets/$tweetId/replies");
      final List<Map<String, dynamic>> rawReplies = response.data;
      final List<TweetReplyModel> replyModels = rawReplies
          .map((json) => TweetReplyModel.fromJson(json))
          .toList();
      return Right((replyModels));
    } catch (e) {
      return Left(Failure("Can't get tweet replies"));
    }
  }

  // tweets interactions
  Future<Either<Failure, void>> likeTweet(String tweetId) async {
    try {
      await _dio.post("api/tweets/$tweetId/likes");
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't like tweet"));
    }
  }

  Future<Either<Failure, void>> retweetProfileTweet(String tweetId) async {
    try {
      await _dio.post("api/tweets/$tweetId/retweets");
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't retweet tweet, try agail..."));
    }
  }

  Future<Either<Failure, void>> deleteRetweetProfileTweet(
    String tweetId,
  ) async {
    try {
      await _dio.delete("api/tweets/$tweetId/retweets");
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't delelte retweet tweet, try agail..."));
    }
  }

  Future<Either<Failure, void>> unLikeTweet(String tweetId) async {
    try {
      await _dio.delete("api/tweets/$tweetId/likes");
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't unlike tweet"));
    }
  }

  Future<Either<Failure, void>> saveTweet(String tweetId) async {
    try {
      await _dio.post("api/tweets/$tweetId/bookmark");
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't bookmark this tweet"));
    }
  }

  Future<Either<Failure, void>> unSaveTweet(String tweetId) async {
    try {
      await _dio.delete("api/tweets/$tweetId/bookmark");
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't remove bookmark from this tweet"));
    }
  }

  Future<Either<Failure, void>> replyOnTweet(
    String tweetId,
    CreateReplyModel createreplyModel,
  ) async {
    try {
      await _dio.post("api/tweets/$tweetId/replies", data: createreplyModel);
      return const Right(());
    } catch (e) {
      return Left(Failure("Can't reply on tweet"));
    }
  }

  // search
  Future<Either<Failure, List<SearchUserModel>>> profileCurrentSearch(
    String query,
  ) async {
    try {
      final res = await _dio.get(
        "api/users/search",
        queryParameters: {"query": query},
      );

      final List<Map<String, dynamic>> rawResults =
          List<Map<String, dynamic>>.from(res.data["users"] ?? []);
      for (int i = 0; i < rawResults.length; i++) {
        final String mediaId = rawResults[i]["profileMedia"]?["id"] ?? "";
        // final mediaUrls = await getMediaUrls([mediaId]);
        rawResults[i]["profileMedia"] = "";
        rawResults[i]["profileMediaId"] = mediaId;
      }
      final List<SearchUserModel> currentResults = rawResults.map((element) {
        SearchUserModel user = SearchUserModel.fromJson(element);
        return user;
      }).toList();
      return Right(currentResults);
    } catch (e) {
      print(e.toString() + "-----------@@##");
      return Left(Failure("Can't get search results"));
    }
  }

  Future<Either<Failure, void>> changeEmailProfile(String newEmail) async {
    try {
      await _dio.post("api/auth/change-email", data: {"email": newEmail});
      // await Future.delayed(Duration(seconds: 3));
      return Right(());
    } catch (e) {
      print(e);
      return Left(Failure("couldn't change email, Please try again later"));
    }
  }

  Future<Either<Failure, void>> verifyChangeEmailProfile(
    String newEmail,
    String code,
  ) async {
    try {
      print(newEmail);
      print(code);
      await _dio.post(
        "api/auth/verify-new-email",
        data: {"email": newEmail, "code": code.toString()},
      );
      return Right(());
    } on DioException catch (e) {
      final String errorMessage =
          e.response?.data["error"] ?? "can't verify code";
      return (Left(Failure(errorMessage)));
    } catch (e) {
      return (Left(Failure("can't verify code")));
    }
  }

  Future<Either<Failure, void>> changePasswordProfile(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      print(
        {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmNewPassword,
        }.toString(),
      );
      await _dio.post(
        "api/auth/change-password",
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmNewPassword,
        },
      );
      return Right(());
    } on DioException catch (e) {
      final String errorMessage =
          e.response?.data["error"] ?? "can't change, try again later";
      return (Left(Failure(errorMessage)));
    } catch (e) {
      return (Left(Failure("can't change password")));
    }
  }

  // trends
  Future<Either<Failure, ForYouResponseModel>> getForYouTrends() async {
    try {
      final response = await _dio.get("api/hashtags/categories");

      final json = response.data;
      final jsonCategories = json["categories"];
      final people = json["whoToFollow"];

      final List<UserModel> peoplemodels = people
          .map((p) {
            p["photo"] = p["profileMedia"]?["id"];
            p["isFollowing"] = p["isFollowed"];
            print(p.toString());
            return UserModel.fromJson(p as Map<String, dynamic>);
          })
          .toList()
          .cast<UserModel>();

      final List<TrendCategory> categories = jsonCategories
          .map((c) => TrendCategory.fromJson(c))
          .toList()
          .cast<TrendCategory>();

      return Right(
        ForYouResponseModel(
          categories: categories,
          suggestedUsers: peoplemodels,
        ),
      );
    } on DioException catch (e) {
      return (Left(Failure(e.toString())));
    } catch (e) {
      return (Left(Failure(e.toString())));
    }
  }

  Future<Either<Failure, TrendCategory>> getTrenCategory(String catName) async {
    try {
      final response = await _dio.get(
        "api/hashtags/categories",
        queryParameters: {"category": catName},
      );

      final TrendCategory category = TrendCategory.fromJson(response.data);
      return Right(category);
    } on DioException catch (_) {
      return (Left(
        Failure("cannot get trends at this time, try again later..."),
      ));
    } catch (e) {
      return (Left(
        Failure("cannot get trends at this time, try again later..."),
      ));
    }
  }
}
