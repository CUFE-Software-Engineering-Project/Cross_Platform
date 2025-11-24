import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/user_profile_model.dart';

void main() {
  group('MediaModel', () {
    test('should create MediaModel with all fields', () {
      final media = MediaModel(
        id: 'media1',
        name: 'profile.jpg',
        keyName: 'profile_key',
        type: 'image/jpeg',
      );

      expect(media.id, 'media1');
      expect(media.name, 'profile.jpg');
      expect(media.keyName, 'profile_key');
      expect(media.type, 'image/jpeg');
    });

    test('should create MediaModel from JSON', () {
      final json = {
        'id': 'media1',
        'name': 'avatar.png',
        'keyName': 'avatar_key',
        'type': 'image/png',
      };

      final media = MediaModel.fromJson(json);

      expect(media.id, 'media1');
      expect(media.name, 'avatar.png');
      expect(media.keyName, 'avatar_key');
      expect(media.type, 'image/png');
    });

    test('should convert MediaModel to JSON', () {
      final media = MediaModel(
        id: 'media1',
        name: 'banner.jpg',
        keyName: 'banner_key',
        type: 'image/jpeg',
      );

      final json = media.toJson();

      expect(json['id'], 'media1');
      expect(json['name'], 'banner.jpg');
      expect(json['keyName'], 'banner_key');
      expect(json['type'], 'image/jpeg');
    });

    test('should handle empty strings in fromJson', () {
      final json = {'id': null, 'name': null, 'keyName': null, 'type': null};

      final media = MediaModel.fromJson(json);

      expect(media.id, '');
      expect(media.name, '');
      expect(media.keyName, '');
      expect(media.type, '');
    });
  });

  group('UserProfileModel', () {
    late UserProfileModel testProfile;
    late MediaModel profileMedia;
    late MediaModel coverMedia;

    setUp(() {
      profileMedia = MediaModel(
        id: 'profile1',
        name: 'profile.jpg',
        keyName: 'profile_key',
        type: 'image/jpeg',
      );

      coverMedia = MediaModel(
        id: 'cover1',
        name: 'cover.jpg',
        keyName: 'cover_key',
        type: 'image/jpeg',
      );

      testProfile = UserProfileModel(
        id: 'user1',
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
        bio: 'Software developer',
        website: 'https://johndoe.com',
        verified: true,
        address: 'New York, USA',
        protectedAccount: false,
        joinDate: '2024-01-01',
        profileMediaId: 'profile1',
        profileMedia: profileMedia,
        resolvedProfilePhotoUrl: 'https://example.com/profile.jpg',
        coverMediaId: 'cover1',
        coverMedia: coverMedia,
        followersCount: 100,
        followingCount: 50,
      );
    });

    test('should create UserProfileModel with all fields', () {
      expect(testProfile.id, 'user1');
      expect(testProfile.name, 'John Doe');
      expect(testProfile.username, 'johndoe');
      expect(testProfile.email, 'john@example.com');
      expect(testProfile.bio, 'Software developer');
      expect(testProfile.website, 'https://johndoe.com');
      expect(testProfile.verified, true);
      expect(testProfile.address, 'New York, USA');
      expect(testProfile.protectedAccount, false);
      expect(testProfile.joinDate, '2024-01-01');
    });

    test('should handle profile media', () {
      expect(testProfile.profileMediaId, 'profile1');
      expect(testProfile.profileMedia, profileMedia);
      expect(testProfile.profileMedia?.name, 'profile.jpg');
      expect(
        testProfile.resolvedProfilePhotoUrl,
        'https://example.com/profile.jpg',
      );
    });

    test('should handle cover media', () {
      expect(testProfile.coverMediaId, 'cover1');
      expect(testProfile.coverMedia, coverMedia);
      expect(testProfile.coverMedia?.name, 'cover.jpg');
    });

    test('should track followers and following counts', () {
      expect(testProfile.followersCount, 100);
      expect(testProfile.followingCount, 50);
    });

    test('should handle verified status', () {
      expect(testProfile.verified, true);

      final unverifiedProfile = UserProfileModel(
        id: 'user2',
        name: 'Jane Doe',
        username: 'janedoe',
        email: 'jane@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2024-01-01',
        followersCount: 10,
        followingCount: 20,
      );

      expect(unverifiedProfile.verified, false);
    });

    test('should handle protected account', () {
      expect(testProfile.protectedAccount, false);

      final protectedProfile = UserProfileModel(
        id: 'user3',
        name: 'Private User',
        username: 'private',
        email: 'private@example.com',
        verified: false,
        protectedAccount: true,
        joinDate: '2024-01-01',
        followersCount: 5,
        followingCount: 3,
      );

      expect(protectedProfile.protectedAccount, true);
    });

    test('should handle optional fields as null', () {
      final minimalProfile = UserProfileModel(
        id: 'user4',
        name: 'Minimal User',
        username: 'minimal',
        email: 'minimal@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2024-01-01',
        followersCount: 0,
        followingCount: 0,
      );

      expect(minimalProfile.bio, isNull);
      expect(minimalProfile.website, isNull);
      expect(minimalProfile.address, isNull);
      expect(minimalProfile.profileMediaId, isNull);
      expect(minimalProfile.profileMedia, isNull);
      expect(minimalProfile.resolvedProfilePhotoUrl, isNull);
      expect(minimalProfile.coverMediaId, isNull);
      expect(minimalProfile.coverMedia, isNull);
    });

    test('should handle zero followers and following', () {
      final newProfile = UserProfileModel(
        id: 'user5',
        name: 'New User',
        username: 'newuser',
        email: 'new@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2024-06-01',
        followersCount: 0,
        followingCount: 0,
      );

      expect(newProfile.followersCount, 0);
      expect(newProfile.followingCount, 0);
    });

    test('should handle different join dates', () {
      expect(testProfile.joinDate, '2024-01-01');

      final recentProfile = UserProfileModel(
        id: 'user6',
        name: 'Recent User',
        username: 'recent',
        email: 'recent@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2024-12-01',
        followersCount: 1,
        followingCount: 1,
      );

      expect(recentProfile.joinDate, '2024-12-01');
    });
  });
}
