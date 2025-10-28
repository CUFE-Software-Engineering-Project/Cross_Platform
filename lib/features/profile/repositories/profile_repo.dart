import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_post_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepo {
  Future<Either<Failure, ProfileModel>> getProfileData();
  Future<Either<Failure, List<ProfilePostModel>>> getProfilePosts();
}
