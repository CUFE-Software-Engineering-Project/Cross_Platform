import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/create_tweet_model.dart';
import 'package:lite_x/features/profile/models/tweet_reply_model.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/create_reply_model.dart';

class _FakeProfileRepo implements ProfileRepo {
  final Either<Failure, void> result;
  _FakeProfileRepo(this.result);

  @override
  Future<Either<Failure, void>> changePasswordProfile(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    return result;
  }

  // The rest of the methods are not used by these tests; return dummy failures
  @override
  Future<Either<Failure, ProfileModel>> getProfileData(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<UserModel>>> getFollowers(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<UserModel>>> getFollowings(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<UserModel>>> getVerifiedFollowers(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<UserModel>>> getFollowersYouKnow(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> followUser(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> unFollowUser(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, ProfileModel>> updateProfile({required ProfileModel newModel}) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> blockUser(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> unBlockUser(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> muteUser(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> unMuteUser(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<UserModel>>> getMutedList(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<UserModel>>> getBlockedList(String userName) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> updateProfileBanner(String userId, String mediaId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> updateProfilePhoto(String userId, String mediaId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<ProfileTweetModel>>> getProfilePosts(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<ProfileTweetModel>>> getProfileLikes(String username) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> createTweet(CreateTweetModel createTweetModel) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<TweetReplyModel>>> getTweetReplies(String tweetId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> deleteTweet(String tweetId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, List<SearchUserModel>>> profileCurrentSearch(String query) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> likeTweet(String tweetId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> unLikeTweet(String tweetId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> saveTweet(String tweetId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> unSaveTweet(String tweetId) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> replyOnTweet(String tweetId, CreateReplyModel createreplyModel) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> changeEmailProfile(String newEmail) async => Left(Failure('not implemented'));
  @override
  Future<Either<Failure, void>> verifyChangeEmailProfile(String newEmail, String code) async => Left(Failure('not implemented'));
}

void main() {
  group('changePasswordProfileProvider', () {
    test('returns Right on success', () async {
      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(_FakeProfileRepo(const Right(null))),
      ]);

      final fn = container.read(changePasswordProfileProvider);

      final res = await fn(oldPassword: 'old', newPassword: 'newPassword1', confirmNewPassword: 'newPassword1');

      expect(res.isRight(), isTrue);
    });

    test('returns Left on failure', () async {
      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(_FakeProfileRepo(const Left(Failure('failed')))),
      ]);

      final fn = container.read(changePasswordProfileProvider);

      final res = await fn(oldPassword: 'old', newPassword: 'new', confirmNewPassword: 'new');

      expect(res.isLeft(), isTrue);
      res.match((l) => expect(l.message, 'failed'), (_) => null);
    });
  });
}
