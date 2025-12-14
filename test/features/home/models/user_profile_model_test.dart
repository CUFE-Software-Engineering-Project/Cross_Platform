import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/user_profile_model.dart';

void main() {
  group('MediaModel Tests', () {
    test('fromJson creates MediaModel correctly', () {
      final json = {
        'id': '123',
        'name': 'profile.jpg',
        'keyName': 'abc123.jpg',
        'type': 'image/jpeg',
      };

      final result = MediaModel.fromJson(json);

      expect(result.id, '123');
      expect(result.name, 'profile.jpg');
      expect(result.keyName, 'abc123.jpg');
      expect(result.type, 'image/jpeg');
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final result = MediaModel.fromJson(json);

      expect(result.id, '');
      expect(result.name, '');
      expect(result.keyName, '');
      expect(result.type, '');
    });

    test('toJson returns correct map', () {
      final model = MediaModel(
        id: '123',
        name: 'profile.jpg',
        keyName: 'abc123.jpg',
        type: 'image/jpeg',
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'profile.jpg');
      expect(json['keyName'], 'abc123.jpg');
      expect(json['type'], 'image/jpeg');
    });
  });

  group('UserProfileModel Tests', () {
    final testProfileMedia = MediaModel(
      id: 'media123',
      name: 'profile.jpg',
      keyName: 'abc123.jpg',
      type: 'image/jpeg',
    );

    final testCoverMedia = MediaModel(
      id: 'cover123',
      name: 'cover.jpg',
      keyName: 'xyz789.jpg',
      type: 'image/jpeg',
    );

    test('fromJson creates UserProfileModel with all fields', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'username': 'testuser',
        'email': 'test@example.com',
        'bio': 'Test bio',
        'website': 'https://example.com',
        'verified': true,
        'address': '123 Test St',
        'protectedAccount': false,
        'joinDate': '2023-01-01',
        'profileMediaId': 'media123',
        'profileMedia': {
          'id': 'media123',
          'name': 'profile.jpg',
          'keyName': 'abc123.jpg',
          'type': 'image/jpeg',
        },
        'coverMediaId': 'cover123',
        'coverMedia': {
          'id': 'cover123',
          'name': 'cover.jpg',
          'keyName': 'xyz789.jpg',
          'type': 'image/jpeg',
        },
        '_count': {'followers': 100, 'followings': 50},
      };

      final result = UserProfileModel.fromJson(json);

      expect(result.id, '123');
      expect(result.name, 'Test User');
      expect(result.username, 'testuser');
      expect(result.email, 'test@example.com');
      expect(result.bio, 'Test bio');
      expect(result.website, 'https://example.com');
      expect(result.verified, true);
      expect(result.address, '123 Test St');
      expect(result.protectedAccount, false);
      expect(result.joinDate, '2023-01-01');
      expect(result.profileMediaId, 'media123');
      expect(result.profileMedia, isNotNull);
      expect(result.profileMedia!.id, 'media123');
      expect(result.coverMediaId, 'cover123');
      expect(result.coverMedia, isNotNull);
      expect(result.coverMedia!.id, 'cover123');
      expect(result.followersCount, 100);
      expect(result.followingCount, 50);
    });

    test('fromJson handles direct count fields', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'username': 'testuser',
        'email': 'test@example.com',
        'verified': false,
        'protectedAccount': false,
        'joinDate': '2023-01-01',
        'followersCount': 200,
        'followingCount': 100,
      };

      final result = UserProfileModel.fromJson(json);

      expect(result.followersCount, 200);
      expect(result.followingCount, 100);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'username': 'testuser',
        'email': 'test@example.com',
        'verified': false,
        'protectedAccount': false,
        'joinDate': '2023-01-01',
      };

      final result = UserProfileModel.fromJson(json);

      expect(result.bio, isNull);
      expect(result.website, isNull);
      expect(result.address, isNull);
      expect(result.profileMediaId, isNull);
      expect(result.profileMedia, isNull);
      expect(result.coverMediaId, isNull);
      expect(result.coverMedia, isNull);
      expect(result.followersCount, 0);
      expect(result.followingCount, 0);
    });

    test('toJson returns correct map', () {
      final model = UserProfileModel(
        id: '123',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        bio: 'Test bio',
        website: 'https://example.com',
        verified: true,
        address: '123 Test St',
        protectedAccount: false,
        joinDate: '2023-01-01',
        profileMediaId: 'media123',
        profileMedia: testProfileMedia,
        coverMediaId: 'cover123',
        coverMedia: testCoverMedia,
        followersCount: 100,
        followingCount: 50,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test User');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['bio'], 'Test bio');
      expect(json['website'], 'https://example.com');
      expect(json['verified'], true);
      expect(json['followersCount'], 100);
      expect(json['followingCount'], 50);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = UserProfileModel(
        id: '123',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2023-01-01',
        followersCount: 100,
        followingCount: 50,
      );

      final updated = original.copyWith(
        name: 'Updated User',
        followersCount: 200,
      );

      expect(updated.name, 'Updated User');
      expect(updated.followersCount, 200);
      expect(updated.username, 'testuser'); // unchanged
      expect(updated.followingCount, 50); // unchanged
    });

    test('profilePhotoUrl returns resolved URL when available', () {
      final model = UserProfileModel(
        id: '123',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2023-01-01',
        resolvedProfilePhotoUrl: 'https://example.com/photo.jpg',
      );

      expect(model.profilePhotoUrl, 'https://example.com/photo.jpg');
    });

    test(
      'profilePhotoUrl returns constructed URL when profileMedia exists',
      () {
        final model = UserProfileModel(
          id: '123',
          name: 'Test User',
          username: 'testuser',
          email: 'test@example.com',
          verified: false,
          protectedAccount: false,
          joinDate: '2023-01-01',
          profileMedia: testProfileMedia,
        );

        expect(
          model.profilePhotoUrl,
          'https://litex.siematworld.online/media/abc123.jpg',
        );
      },
    );

    test('profilePhotoUrl returns null when no photo available', () {
      final model = UserProfileModel(
        id: '123',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2023-01-01',
      );

      expect(model.profilePhotoUrl, isNull);
    });

    test('coverPhotoUrl returns correct URL when coverMedia exists', () {
      final model = UserProfileModel(
        id: '123',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2023-01-01',
        coverMedia: testCoverMedia,
      );

      expect(
        model.coverPhotoUrl,
        'https://litex.siematworld.online/media/xyz789.jpg',
      );
    });

    test('coverPhotoUrl returns null when coverMedia is null', () {
      final model = UserProfileModel(
        id: '123',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        verified: false,
        protectedAccount: false,
        joinDate: '2023-01-01',
      );

      expect(model.coverPhotoUrl, isNull);
    });

    test(
      'profilePhotoUrl prefers resolvedProfilePhotoUrl over profileMedia',
      () {
        final model = UserProfileModel(
          id: '123',
          name: 'Test User',
          username: 'testuser',
          email: 'test@example.com',
          verified: false,
          protectedAccount: false,
          joinDate: '2023-01-01',
          resolvedProfilePhotoUrl: 'https://resolved.com/photo.jpg',
          profileMedia: testProfileMedia,
        );

        expect(model.profilePhotoUrl, 'https://resolved.com/photo.jpg');
      },
    );
  });
}
