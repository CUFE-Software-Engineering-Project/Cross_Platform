import 'package:dio/dio.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';

String baseUrl =
    "https://app-fd6adf10-3923-46c1-83f7-08c318e4c982.cleverapps.io";

class ProfileRepoImpl implements ProfileRepo {
  Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Authorization":
            "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VybmFtZSI6ImhhemVtYWhtZWQiLCJlbWFpbCI6Imppd29ub205NjFAaGg3Zi5jb20iLCJpZCI6IjY4ZGIxN2U1LTE3Y2UtNGQzNS1hY2MyLTY1ZTk4NDRmOWEyMyIsImV4cCI6MTc2MjAxNzg0OSwiaWF0IjoxNzYyMDE0MjQ5LCJ2ZXJzaW9uIjowLCJqdGkiOiI3NjdjNzYxOS0yZmZmLTQ0ODItOTFiNC0wNTI2YTBkNjk5ZDciLCJkZXZpZCI6IjM2NGVkZjUyLWU2MTgtNGJmZS1hYTIzLWYwNTBlMzdiZTMxMiJ9.xnBbAkZ6-GyZF_nhzk3qRe25MLa2eZ7bM33lMcj1vfs",
      },
    ),
  );
  @override
  Future<Either<Failure, ProfileModel>> getProfileData(String userName) async {
    final Response res;
    try {
      res = await _dio.get("/api/users/$userName");

      final profileData = ProfileModel.fromJson(res.data);
      final profileData2 = profileData.copyWith(
        avatarUrl:
            "https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg",
      );

      return Right(profileData2);
    } catch (e) {
      return Left(Failure('Failed to load profile data'));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile({
    required ProfileModel newModel,
  }) async {
    try {
      final json = {
        "id": newModel.id,
        "username": newModel.username,
        if (newModel.displayName.isNotEmpty) "name": newModel.displayName,
        if (newModel.bio.isNotEmpty) "bio": newModel.bio,
        "protectedAccount": true,
      };
      print(json.toString());
      final res = await _dio.patch("/api/users/${newModel.id}", data: json);

      return Right(ProfileModel.fromJson(res.data));
    } catch (e) {
      print("----------\n${e.toString()}\n---------");
      return Left(Failure("can't update profile data"));
    }
  }

  @override
  Future<Either<Failure, List<ProfilePostModel>>> getProfilePosts() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    try {
      final List<Map<String, dynamic>> rawPostData = [
        {
          "id": "post_001",
          "text":
              "Excited to share my latest project! Flutter makes UI development",
          "timeAgo": "5m",
          "likes": 25,
          "retweets": 8,
          "repost": 50,
          "replies": 3,
          "isLiked": false,
          "activityNumber": 36,
          "mediaUrls": [
            "https://images.pexels.com/photos/34188568/pexels-photo-34188568.jpeg",
            "https://images.pexels.com/photos/34182536/pexels-photo-34182536.jpeg",
            "https://images.pexels.com/photos/34182536/pexels-photo-34182536.jpeg",
            "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
          ],
        },
        {
          "id": "post_002",
          "text":
              "A quick update on the server migration: everything went smoothly! Downtime was minimal. Thanks to the team!",
          "timeAgo": "2h",
          "likes": 120,
          "retweets": 8,
          "replies": 10,
          "isLiked": true,
          "activityNumber": 20,
          "mediaUrls": [
            "https://media.istockphoto.com/id/158002966/photo/painted-x-mark.jpg?b=1&s=612x612&w=0&k=20&c=W-XB39kzx5Y1U5eHU7gBZzgd4k2oqo0G3bRrch3jUZk=",
          ],
        },
      ];

      final List<ProfilePostModel> profilePosts = rawPostData
          .map((json) => ProfilePostModel.fromJson(json))
          .toList();
      return Right(profilePosts);
    } catch (e) {
      return Left(Failure('Failed to load profile posts'));
    }
  }

  Future<Either<Failure, List<UserModel>>> getFollowers(String userName) async {
    // await Future.delayed(const Duration(seconds: 1));

    try {
      final response = await _dio.get("/api/followers/$userName");
      List<dynamic> jsonList = response.data['users'] as List<dynamic>;
      final List<UserModel> usersList = jsonList
          .map((json) => UserModel.fromJson(json))
          .toList();
      return Right(usersList);
    } catch (e) {
      // print("\n--------------\n$e\n-------------------\n");
      return Left(Failure("couldn't get user followers"));
    }
    // List<UserModel> users;
    // return Right([
    //   UserModel(
    //     displayName: 'Hazem Emam',
    //     userName: 'hazememam',
    //     image:
    //         'https://images.pexels.com/photos/1462980/pexels-photo-1462980.jpeg',
    //     bio:
    //         'Software engineer and web developer. Software engineer and web developer. Software engineer and web developer.',
    //     isFollowing: true,
    //     isFollower: false,
    //     isVerified: true,
    //   ),
    //   UserModel(
    //     displayName: 'Sara Ali',
    //     userName: 'sara_ali',
    //     image: 'https://example.com/images/sara.jpg',
    //     bio: 'UI/UX designer and artist.',
    //     isFollowing: true,
    //     isFollower: true,
    //     isVerified: false,
    //   ),
    //   UserModel(
    //     displayName: 'Omar Hassan',
    //     userName: 'omar_hassan',
    //     image: 'https://example.com/images/omar.jpg',
    //     bio: 'Data scientist and AI enthusiast.',
    //     isFollowing: true,
    //     isFollower: true,
    //     isVerified: true,
    //   ),
    //   UserModel(
    //     displayName: 'Laila Mohamed',
    //     userName: 'laila_m',
    //     image: 'https://example.com/images/laila.jpg',
    //     bio: 'Mobile app developer.',
    //     isFollowing: false,
    //     isFollower: false,
    //     isVerified: true,
    //   ),
    // ]);
  }

  Future<Either<Failure, List<UserModel>>> getFollowings(
    String userName,
  ) async {
    try {
      final response = await _dio.get("/api/followings/$userName");
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
      final response = await _dio.get("/api/followers/$userName");
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
      final response = await _dio.get("/api/followers/$userName");
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
      await _dio.post("/api/followers/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't follow user"));
    }
  }

  Future<Either<Failure, void>> unFollowUser(String username) async {
    try {
      await _dio.delete("/api/followers/$username");
      return const Right(());
    } catch (e) {
      return Left(Failure("couldn't unfollow user"));
    }
  }
}
