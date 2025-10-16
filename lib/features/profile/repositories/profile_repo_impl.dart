import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  @override
  Future<Either<Failure, ProfileModel>> getProfileData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    try {
      final profileData = ProfileModel.fromJson({
        "username": "HazemEmam40",
        "displayName": "Hazem Emam",
        "bio": "I'm Hazem Emam 2004/7/21",
        "avatarUrl":
            "https://static.vecteezy.com/system/resources/previews/024/183/525/non_2x/avatar-of-a-man-portrait-of-a-young-guy-illustration-of-male-character-in-modern-color-style-vector.jpg",
        "bannerUrl":
            "https://images.pexels.com/photos/34188568/pexels-photo-34188568.jpeg",

        "followersCount": 3200000,
        "followingCount": 3150,
        "tweetsCount": 0,
        "isVerified": false,
        "joinedDate": DateTime(2025, 3, 15).toString(),
        "website": "www.facebook.com",
        "location": "Cairo",
        "postCount": 1,
        "birthDate": DateTime(2004, 7, 21).toString(),
      });
      return Right(profileData);
    } catch (e) {
      return Left(Failure('Failed to load profile data'));
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
}
