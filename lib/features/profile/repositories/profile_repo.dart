import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';
import 'package:lite_x/features/profile/models/user_model.dart';

abstract class ProfileRepo {
  Future<Either<Failure, ProfileModel>> getProfileData(String userName);
  Future<Either<Failure, List<ProfilePostModel>>> getProfilePosts();
  Future<Either<Failure, List<UserModel>>> getFollowers(String userName);
  Future<Either<Failure, List<UserModel>>> getFollowings(String userName);
  Future<Either<Failure, List<UserModel>>> getVerifiedFollowers(
    String userName,
  );
  Future<Either<Failure, List<UserModel>>> getFollowersYouKnow(String userName);

  Future<Either<Failure, void>> followUser(String username);
  Future<Either<Failure, void>> unFollowUser(String username);
  Future<Either<Failure, ProfileModel>> updateProfile({required ProfileModel newModel});
}
