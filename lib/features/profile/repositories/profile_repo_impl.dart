import 'package:dio/dio.dart';
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

// String baseUrl =
//     "https://app-fd6adf10-3923-46c1-83f7-08c318e4c982.cleverapps.io";

class ProfileRepoImpl implements ProfileRepo {
  Dio _dio;
  ProfileRepoImpl(Dio d) : _dio = d {
    // _dio = Dio(
    //   BaseOptions(
    //     baseUrl:
    //         "https://app-dbef67eb-9a2e-44fa-abff-3e8b83204d9c.cleverapps.io/",
    //     headers: {
    //       "Authorization":
    //           "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VybmFtZSI6ImhhemVtZW1hbSIsImVtYWlsIjoiaGF6ZW1AenVkcGNrLmNvbSIsInJvbGUiOiJ1c2VyIiwiaWQiOiJmM2EwZDdmNC0zZDMwLTQ2NjgtOTkyZi1kN2E2ZGM0NjUyNDEiLCJleHAiOjE3NjM2NjczMjcsImlhdCI6MTc2MzY2MzcyNywidmVyc2lvbiI6MiwianRpIjoiNzkzOTI0ZDAtYzAxMi00NTk5LTk4NWYtOTgyNTdlYTIyZmRhIiwiZGV2aWQiOiJlNGY2YTRkZi03MzVkLTRlZGItYTIxZi0wZDZkMTA5Y2M1YmUifQ.PdXybFYl0DyMKIuwCeoi17awgHz72zQlBFR_W1m0IU4",
    //     },
    //   ),
    // );
  }

  @override
  Future<Either<Failure, ProfileModel>> getProfileData(String userName) async {
    final Response res;
    try {
      res = await _dio.get("api/users/$userName");
      final Map<String, dynamic> json = res.data;
      final String profilePhotoId = json["profileMediaId"] ?? "";
      final String profileBannerId = json["coverMediaId"] ?? "";

      List<String> urls = await getMediaUrls([profilePhotoId, profileBannerId]);

      print(urls[0]);
      print(urls[1]);
      final String profilePhotoUrl = urls[0];
      final String profileBannerUrl = urls[1];

      json["profileMedia"] = profilePhotoUrl;
      json["coverMedia"] = profileBannerUrl;

      final profileData = ProfileModel.fromJson(json);
      return Right(profileData);

      // final profileData2 = profileData.copyWith(
      //   avatarUrl:
      //       "https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg",
      // );

      // await Future.delayed(Duration(seconds: 1));

      // return Right(
      //   ProfileModel(
      //     id: "",
      //     username: "hazememam404",
      //     displayName: "Hazem Emam",
      //     bio:
      //         "Hello from hazem emam fffffffffffffffffffffffffffffffffffffffffffffddddddddddddddddddddddddddddddddddd",
      //     avatarUrl:
      //         "https://images.pexels.com/photos/31510092/pexels-photo-31510092.jpeg",
      //     bannerUrl:
      //         "https://images.pexels.com/photos/1765033/pexels-photo-1765033.jpeg",
      //     followersCount: 15,
      //     followingCount: 20,
      //     tweetsCount: 15,
      //     isVerified: false,
      //     joinedDate: formatDate(
      //       DateTime(2004, 8, 21),
      //       DateFormatType.fullDate,
      //     ),
      //     website: "https://google.cof",
      //     location:
      //         "cairo,Egyptfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddddddddddddddddddddddd",
      //     postCount: 2,
      //     birthDate: formatDate(DateTime(2004, 8, 21), DateFormatType.fullDate),
      //     isFollowing: false,
      //     isFollower: false,
      //     protectedAccount: false,
      //     isBlockedByMe: true,
      //     isMutedByMe: false,
      //   ),
      // );
    } catch (e) {
      print(e.toString());
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
      // print("----------\n${e.toString()}\n---------");
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

      List<ProfileTweetModel> tweets = [];
      for (int i = 0; i < jsonList.length; i++) {
        print(
          "***********************" +
              "media${i}" +
              "**************************",
        );
        final Map<String, dynamic> json = jsonList[i] as Map<String, dynamic>;
        if (json["tweetType"]?.toLowerCase() == "reply") continue;
        // get profile photo url and tweet medial urls
        final String profilePhotoId =
            json["user"]?["profileMedia"]?["id"] ?? "";

        final List<dynamic> tweetMediaIdsDynamic = json["tweetMedia"] ?? [];
        final List<String> tweetMediaIds = tweetMediaIdsDynamic
            .map((media) => media["mediaId"] as String)
            .toList();

        final List<String> urls = await getMediaUrls(
          [profilePhotoId] + tweetMediaIds,
        );

        for (int i = 0; i < urls.length; i++)
          print("--------------\n" + urls[i] + "\n---------------------------");
        final String profilePhotoUrl = urls[0];
        final List<String> tweetMediaUrls = urls.skip(1).toList();

        // get timeAgo
        final String createTime = json["createdAt"] ?? "";
        final String timeAgo = getTimeAgo(createTime);

        json["profileMedia"] = profilePhotoUrl;
        json["mediaUrls"] = tweetMediaUrls;
        json["timeAgo"] = timeAgo;

        tweets.add(ProfileTweetModel.fromJson(json));
        print("*****************************************");
      }

      return Right(tweets);
    } catch (e) {
      print(e.toString());
      return Left(Failure('Failed to load profile posts'));
    }
  }

  @override
  Future<Either<Failure, List<ProfileTweetModel>>> getProfileLikes(
    String username,
  ) async {
    // await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    try {
      final List<Map<String, dynamic>> rawPostData = [
        {
          "id": "post_001",
          "text":
              "Excited to share my latest project! Flutter makes UI development",
          "timeAgo": "5m",
          "likes": 1,
          "retweets": 8,
          "repost": 50,
          "replies": 3,
          "tweetType": "reTweet",
          "isLikedByMe": true,
          "isSaveByMe": true,
          "activityNumber": 36,
          "mediaUrls": [
            "https://images.pexels.com/photos/34188568/pexels-photo-34188568.jpeg",
            "https://images.pexels.com/photos/34051342/pexels-photo-34051342.jpeg",
            "https://images.pexels.com/photos/34182536/pexels-photo-34182536.jpeg",
            "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
          ],
        },
        {
          "id": "post_002",
          "text":
              "A quick update on the server migration: everything went smoothly! Downtime was minimal. Thanks to the team! A quick update on the server migration: everything went smoothly! Downtime was minimal. Thanks to the team! \n A quick update on the server migration: everything went smoothly! Downtime was minimal. Thanks to the team!",
          "timeAgo": "2h",
          "likes": 120,
          "retweets": 6,
          "replies": 10,
          "isLikedByMe": true,
          "activityNumber": 20,
          "mediaUrls": [
            "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
          ],
        },
      ];

      await Future.delayed(Duration(seconds: 2));
      final List<ProfileTweetModel> profilePosts = rawPostData
          .map((json) => ProfileTweetModel.fromJson(json))
          .toList();
      return Right(profilePosts);
    } catch (e) {
      return Left(Failure('Failed to load profile posts'));
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
      final List<SearchUserModel> currentResults = rawResults.map((element) {
        SearchUserModel user = SearchUserModel.fromJson(element);
        return user.copyWith(profileMedia: "https://picsum.photos/200/300");
      }).toList();
      return Right(currentResults);
    } catch (e) {
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
      await _dio.post(
        "api/auth/change-password",
        data: {
          {
            "oldPassword": oldPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmNewPassword,
          },
        },
      );
      return Right(());
    } on DioException catch (e) {
      final String errorMessage =
          e.response?.data["error"] ?? "can't change password";
      return (Left(Failure(errorMessage)));
    } catch (e) {
      return (Left(Failure("can't change password")));
    }
  }
}
