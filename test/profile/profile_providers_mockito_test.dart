import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';

import 'profile_providers_mockito_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProfileRepo>()])
void main() {
  setUpAll(() {
    // register dummy values for Mockito where generic Either are used in generated mocks
    provideDummy<Either<Failure, void>>(Left(Failure('dummy')));
    provideDummy<Either<Failure, ProfileModel>>(Left(Failure('dummy')));
    provideDummy<Either<Failure, List<UserModel>>>(Left(Failure('dummy')));
  });

  group('Profile providers (mockito)', () {
    late MockProfileRepo mockRepo;

    setUp(() {
      mockRepo = MockProfileRepo();
    });

    test('profileDataProvider returns profile on success', () async {
      final mockProfile = ProfileModel(
        id: '1',
        username: 'testuser',
        displayName: 'Test User',
        bio: '',
        avatarUrl: '',
        bannerUrl: '',
        followersCount: 0,
        followingCount: 0,
        tweetsCount: 0,
        isVerified: false,
        joinedDate: '',
        website: '',
        location: '',
        postCount: 0,
        birthDate: '',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: '',
        avatarId: '',
      );

      when(mockRepo.getProfileData('testuser')).thenAnswer((_) async => Right(mockProfile));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(profileDataProvider('testuser').future);
      expect(either.isRight(), isTrue);
      either.fold((l) => fail('expected Right'), (r) => expect(r.username, 'testuser'));
    });

    test('profileDataProvider returns failure on error', () async {
      when(mockRepo.getProfileData('baduser')).thenAnswer((_) async => Left(Failure('not found')));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final either = await container.read(profileDataProvider('baduser').future);
      expect(either.isLeft(), isTrue);
      either.fold((l) => expect(l.message, 'not found'), (r) => null);
    });

    test('followControllerProvider calls repo.followUser and returns Right', () async {
      when(mockRepo.followUser('other')).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(followControllerProvider);
      final res = await fn('other');

      expect(res.isRight(), isTrue);
      verify(mockRepo.followUser('other')).called(1);
    });

    test('updateProfileProvider calls repo.updateProfile and returns updated model', () async {
      final input = ProfileModel(
        id: '2',
        username: 'u2',
        displayName: 'U2',
        bio: '',
        avatarUrl: '',
        bannerUrl: '',
        followersCount: 0,
        followingCount: 0,
        tweetsCount: 0,
        isVerified: false,
        joinedDate: '',
        website: '',
        location: '',
        postCount: 0,
        birthDate: '',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: '',
        avatarId: '',
      );
      when(mockRepo.updateProfile(newModel: anyNamed('newModel'))).thenAnswer((_) async => Right(input));

      final container = ProviderContainer(overrides: [
        profileRepoProvider.overrideWithValue(mockRepo),
      ]);

      final fn = container.read(editProfileProvider);
      final res = await fn(input);

      expect(res.isRight(), isTrue);
      res.fold((l) => fail('expected Right'), (r) => expect(r.username, 'u2'));
      verify(mockRepo.updateProfile(newModel: input)).called(1);
    });
  });
}
