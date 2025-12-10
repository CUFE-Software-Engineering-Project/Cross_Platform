import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/repositories/profile_repo.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_notifier.dart';
import 'package:lite_x/features/profile/view_model/profile_basic_data_states.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_extended_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProfileRepo>()])
void main() {
  late MockProfileRepo mockRepo;
  
  setUp(() {
    mockRepo = MockProfileRepo();
  });

  final testProfile = ProfileModel(
    id: '123',
    username: 'testuser',
    displayName: 'Test User',
    email: 'test@example.com',
    bio: 'Test bio',
    birthDate: '1990-01-01',
    location: 'Test Location',
    website: 'https://test.com',
    avatarUrl: '',
    bannerUrl: '',
    isVerified: false,
    isFollowing: false,
    isFollower: false,
    isBlockedByMe: false,
    isMutedByMe: false,
    followersCount: 100,
    followingCount: 50,
    tweetsCount: 10,
    postCount: 10,
    joinedDate: '2020-01-01',
    protectedAccount: false,
    avatarId: '',
  );

  group('ProfileBasicDataNotifier', () {
    test('initial state should be loading with null data', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      final notifier = ProfileBasicDataNotifier(
        profileRepo: mockRepo,
        userName: 'testuser',
      );

      // Initial state before async call completes
      expect(notifier.state.isLoading, isTrue);
      expect(notifier.state.profileData, isNull);
      expect(notifier.state.errorMessage, isNull);
      
      await Future.delayed(Duration(milliseconds: 100));
      notifier.dispose();
    });

    test('loadProfileData should update state with profile on success', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      final notifier = ProfileBasicDataNotifier(
        profileRepo: mockRepo,
        userName: 'testuser',
      );

      // Wait for the async operation to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.profileData, equals(testProfile));
      expect(notifier.state.errorMessage, isNull);
      verify(mockRepo.getProfileData('testuser')).called(1);
      
      notifier.dispose();
    });

    test('loadProfileData should update state with error on failure', () async {
      final failure = Failure('Profile not found');
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Left(failure));

      final notifier = ProfileBasicDataNotifier(
        profileRepo: mockRepo,
        userName: 'testuser',
      );

      // Wait for the async operation to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.profileData, isNull);
      expect(notifier.state.errorMessage, equals('Profile not found'));
      verify(mockRepo.getProfileData('testuser')).called(1);
      
      notifier.dispose();
    });

    test('loadProfileData can be called again to refresh data', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      final notifier = ProfileBasicDataNotifier(
        profileRepo: mockRepo,
        userName: 'testuser',
      );

      await Future.delayed(Duration(milliseconds: 100));

      // Call loadProfileData again
      final updatedProfile = testProfile.copyWith(displayName: 'Updated Name');
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(updatedProfile));

      notifier.loadProfileData('testuser');
      await Future.delayed(Duration(milliseconds: 100));

      expect(notifier.state.profileData?.displayName, equals('Updated Name'));
      verify(mockRepo.getProfileData('testuser')).called(2);
      
      notifier.dispose();
    });

    test('loadProfileData can fetch different user profile', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async => Right(testProfile));

      final notifier = ProfileBasicDataNotifier(
        profileRepo: mockRepo,
        userName: 'testuser',
      );

      await Future.delayed(Duration(milliseconds: 100));

      // Load a different user's profile
      final anotherProfile = testProfile.copyWith(username: 'anotheruser');
      when(mockRepo.getProfileData('anotheruser'))
          .thenAnswer((_) async => Right(anotherProfile));

      notifier.loadProfileData('anotheruser');
      await Future.delayed(Duration(milliseconds: 100));

      expect(notifier.state.profileData?.username, equals('anotheruser'));
      verify(mockRepo.getProfileData('anotheruser')).called(1);
      
      notifier.dispose();
    });

    test('state transitions from loading to loaded correctly', () async {
      when(mockRepo.getProfileData('testuser'))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 50));
        return Right(testProfile);
      });

      final states = <ProfileBasicDataStates>[];
      
      final notifier = ProfileBasicDataNotifier(
        profileRepo: mockRepo,
        userName: 'testuser',
      );

      // Listen to state changes
      notifier.addListener((state) {
        states.add(state);
      });

      await Future.delayed(Duration(milliseconds: 150));

      // Should have at least loading state and loaded state
      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.first.isLoading, isTrue);
      expect(states.last.isLoading, isFalse);
      expect(states.last.profileData, isNotNull);
      
      notifier.dispose();
    });
  });

  group('ProfileBasicDataStates', () {
    test('initial factory creates correct initial state', () {
      final state = ProfileBasicDataStates.initial();
      
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.profileData, isNull);
    });

    test('copyWith updates only specified fields', () {
      final initialState = ProfileBasicDataStates.initial();
      
      final loadingState = initialState.copyWith(isLoading: true);
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.errorMessage, isNull);
      expect(loadingState.profileData, isNull);

      final errorState = loadingState.copyWith(
        isLoading: false,
        errorMessage: 'Error occurred',
      );
      expect(errorState.isLoading, isFalse);
      expect(errorState.errorMessage, equals('Error occurred'));
      expect(errorState.profileData, isNull);
    });

    test('copyWith preserves existing values when not specified', () {
      final state = ProfileBasicDataStates(
        isLoading: true,
        errorMessage: 'Initial error',
        profileData: testProfile,
      );

      final updatedState = state.copyWith(isLoading: false);
      
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.errorMessage, equals('Initial error'));
      expect(updatedState.profileData, equals(testProfile));
    });
  });
}
