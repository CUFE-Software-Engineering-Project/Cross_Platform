import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/repositories/profile_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProfileStorageService service;

  setUpAll(() async {
    // Setup Hive for testing
    Hive.init('test_hive');
    Hive.registerAdapter(ProfileModelAdapter());
  });

  setUp(() {
    service = ProfileStorageService();
  });

  tearDown(() async {
    try {
      await service.close();
    } catch (_) {}
    try {
      await Hive.deleteBoxFromDisk('profileDataBox');
    } catch (_) {}
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('ProfileStorageService - initialization', () {
    test('should initialize Hive box successfully', () async {
      await service.init();
      expect(service, isNotNull);
    });
  });

  group('ProfileStorageService - store and retrieve', () {
    test('should store and retrieve profile data', () async {
      await service.init();
      
      final testProfile = ProfileModel(
        id: '123',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Test bio',
        followersCount: 100,
        followingCount: 50,
        tweetsCount: 10,
        isVerified: false,
        joinedDate: 'January 2024',
        website: '',
        location: '',
        postCount: 10,
        birthDate: 'January 1, 2000',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: 'test@test.com',
        avatarId: 'avatar123',
        bannerId: 'banner123',
      );

      await service.storeProfileData(testProfile);
      final retrieved = service.getProfileData('testuser');

      expect(retrieved, isNotNull);
      expect(retrieved?.username, 'testuser');
      expect(retrieved?.displayName, 'Test User');
      expect(retrieved?.bio, 'Test bio');
    });

    test('should return null for non-existent profile', () async {
      await service.init();
      
      final retrieved = service.getProfileData('nonexistent');
      expect(retrieved, isNull);
    });
  });

  group('ProfileStorageService - check existence', () {
    test('should return true when profile exists', () async {
      await service.init();
      
      final testProfile = ProfileModel(
        id: '123',
        username: 'testuser',
        displayName: 'Test User',
        bio: '',
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
        bannerId: '',
      );

      await service.storeProfileData(testProfile);
      expect(service.hasProfileData('testuser'), true);
    });

    test('should return false when profile does not exist', () async {
      await service.init();
      expect(service.hasProfileData('nonexistent'), false);
    });
  });

  group('ProfileStorageService - update', () {
    test('should update existing profile data', () async {
      await service.init();
      
      final testProfile = ProfileModel(
        id: '123',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'Original bio',
        followersCount: 100,
        followingCount: 50,
        tweetsCount: 10,
        isVerified: false,
        joinedDate: 'January 2024',
        website: '',
        location: '',
        postCount: 10,
        birthDate: '',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: '',
        avatarId: '',
        bannerId: '',
      );

      await service.storeProfileData(testProfile);

      final updatedProfile = ProfileModel(
        id: '123',
        username: 'testuser',
        displayName: 'Updated User',
        bio: 'Updated bio',
        followersCount: 200,
        followingCount: 75,
        tweetsCount: 20,
        isVerified: true,
        joinedDate: 'January 2024',
        website: 'https://example.com',
        location: 'Test City',
        postCount: 20,
        birthDate: '',
        isFollowing: false,
        isFollower: false,
        protectedAccount: false,
        isBlockedByMe: false,
        isMutedByMe: false,
        email: '',
        avatarId: '',
        bannerId: '',
      );

      await service.updateProfileData('testuser', updatedProfile);
      final retrieved = service.getProfileData('testuser');

      expect(retrieved?.displayName, 'Updated User');
      expect(retrieved?.bio, 'Updated bio');
      expect(retrieved?.followersCount, 200);
      expect(retrieved?.isVerified, true);
    });
  });

  group('ProfileStorageService - clear', () {
    test('should clear all profile data', () async {
      await service.init();
      
      final profile1 = ProfileModel(
        id: '1',
        username: 'user1',
        displayName: 'User 1',
        bio: '',
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
        bannerId: '',
      );

      final profile2 = ProfileModel(
        id: '2',
        username: 'user2',
        displayName: 'User 2',
        bio: '',
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
        bannerId: '',
      );

      await service.storeProfileData(profile1);
      await service.storeProfileData(profile2);

      expect(service.hasProfileData('user1'), true);
      expect(service.hasProfileData('user2'), true);

      await service.clearAllProfiles();

      expect(service.hasProfileData('user1'), false);
      expect(service.hasProfileData('user2'), false);
    });
  });

  group('ProfileStorageService - serialization/deserialization', () {
    test('should properly serialize and deserialize all profile fields', () async {
      await service.init();
      
      final testProfile = ProfileModel(
        id: 'ser-123',
        username: 'serialtest',
        displayName: 'Serialization Test',
        bio: 'Testing serialization and deserialization',
        followersCount: 999,
        followingCount: 888,
        tweetsCount: 777,
        isVerified: true,
        joinedDate: 'December 2025',
        website: 'https://test.com',
        location: 'Test Location',
        postCount: 666,
        birthDate: 'December 15, 1990',
        isFollowing: true,
        isFollower: true,
        protectedAccount: true,
        isBlockedByMe: true,
        isMutedByMe: true,
        email: 'serialize@test.com',
        avatarId: 'avatar-ser-123',
        bannerId: 'banner-ser-123',
      );

      // Store the profile
      await service.storeProfileData(testProfile);
      
      // Close and reopen to force deserialization from disk
      await service.close();
      await service.init();
      
      // Retrieve and verify all fields
      final retrieved = service.getProfileData('serialtest');
      
      expect(retrieved, isNotNull);
      expect(retrieved?.id, 'ser-123');
      expect(retrieved?.username, 'serialtest');
      expect(retrieved?.displayName, 'Serialization Test');
      expect(retrieved?.bio, 'Testing serialization and deserialization');
      expect(retrieved?.followersCount, 999);
      expect(retrieved?.followingCount, 888);
      expect(retrieved?.tweetsCount, 777);
      expect(retrieved?.isVerified, true);
      expect(retrieved?.joinedDate, 'December 2025');
      expect(retrieved?.website, 'https://test.com');
      expect(retrieved?.location, 'Test Location');
      expect(retrieved?.postCount, 666);
      expect(retrieved?.birthDate, 'December 15, 1990');
      expect(retrieved?.isFollowing, true);
      expect(retrieved?.isFollower, true);
      expect(retrieved?.protectedAccount, true);
      expect(retrieved?.isBlockedByMe, true);
      expect(retrieved?.isMutedByMe, true);
      expect(retrieved?.email, 'serialize@test.com');
      expect(retrieved?.avatarId, 'avatar-ser-123');
      expect(retrieved?.bannerId, 'banner-ser-123');
    });

    test('should handle multiple profiles with different values', () async {
      await service.init();
      
      final profiles = [
        ProfileModel(
          id: '1',
          username: 'user1',
          displayName: 'User One',
          bio: 'First user',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 25,
          isVerified: true,
          joinedDate: 'Jan 2024',
          website: 'site1.com',
          location: 'Location 1',
          postCount: 30,
          birthDate: 'Jan 1, 2000',
          isFollowing: true,
          isFollower: false,
          protectedAccount: false,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'user1@test.com',
          avatarId: 'av1',
          bannerId: 'bn1',
        ),
        ProfileModel(
          id: '2',
          username: 'user2',
          displayName: 'User Two',
          bio: 'Second user',
          followersCount: 200,
          followingCount: 100,
          tweetsCount: 50,
          isVerified: false,
          joinedDate: 'Feb 2024',
          website: 'site2.com',
          location: 'Location 2',
          postCount: 60,
          birthDate: 'Feb 2, 2000',
          isFollowing: false,
          isFollower: true,
          protectedAccount: true,
          isBlockedByMe: true,
          isMutedByMe: true,
          email: 'user2@test.com',
          avatarId: 'av2',
          bannerId: 'bn2',
        ),
      ];

      // Store all profiles
      for (final profile in profiles) {
        await service.storeProfileData(profile);
      }
      
      // Close and reopen to force deserialization
      await service.close();
      await service.init();
      
      // Verify all profiles were correctly deserialized
      final retrieved1 = service.getProfileData('user1');
      final retrieved2 = service.getProfileData('user2');
      
      expect(retrieved1?.username, 'user1');
      expect(retrieved1?.followersCount, 100);
      expect(retrieved1?.isVerified, true);
      
      expect(retrieved2?.username, 'user2');
      expect(retrieved2?.followersCount, 200);
      expect(retrieved2?.isVerified, false);
      expect(retrieved2?.protectedAccount, true);
    });

    test('should handle edge case values in deserialization', () async {
      await service.init();
      
      final edgeProfile = ProfileModel(
        id: '',
        username: 'edge',
        displayName: '',
        bio: '',
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
        bannerId: '',
      );

      await service.storeProfileData(edgeProfile);
      await service.close();
      await service.init();
      
      final retrieved = service.getProfileData('edge');
      expect(retrieved, isNotNull);
      expect(retrieved?.id, '');
      expect(retrieved?.displayName, '');
      expect(retrieved?.followersCount, 0);
    });
  });

  group('ProfileModelAdapter - equality and hashCode', () {
    test('should have consistent hashCode and equality', () {
      final adapter1 = ProfileModelAdapter();
      final adapter2 = ProfileModelAdapter();
      
      // Test hashCode
      expect(adapter1.hashCode, isNotNull);
      expect(adapter1.hashCode, equals(adapter2.hashCode));
      
      // Test equality
      expect(adapter1, equals(adapter2));
      expect(adapter1 == adapter2, true);
      
      // Test identity
      expect(adapter1 == adapter1, true);
    });
  });
}
