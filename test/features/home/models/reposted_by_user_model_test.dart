import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/reposted_by_user_model.dart';

void main() {
  group('RepostedByUserModel Tests', () {
    test('fromJson creates model with profileMediaId as string', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMediaId': 'avatar123',
        'verified': true,
        'protectedAccount': false,
        'isFollowed': true,
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.id, '123');
      expect(result.username, 'testuser');
      expect(result.name, 'Test User');
      expect(result.avatarId, 'avatar123');
      expect(result.verified, true);
      expect(result.protectedAccount, false);
      expect(result.isFollowed, true);
    });

    test('fromJson creates model with profileMedia object', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMedia': {'id': 'avatar123', 'keyName': 'avatar.jpg'},
        'verified': false,
        'protectedAccount': false,
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.avatarId, 'avatar123');
    });

    test('fromJson handles isFollowing as alternative to isFollowed', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'isFollowing': true,
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.isFollowed, true);
    });

    test('fromJson prioritizes isFollowed over isFollowing', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'isFollowed': false,
        'isFollowing': true,
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.isFollowed, false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {'id': '123', 'username': 'testuser', 'name': 'Test User'};

      final result = RepostedByUserModel.fromJson(json);

      expect(result.avatarId, '');
      expect(result.verified, false);
      expect(result.protectedAccount, false);
      expect(result.isFollowed, false);
    });

    test('fromJson handles null values', () {
      final json = {
        'id': null,
        'username': null,
        'name': null,
        'verified': null,
        'protectedAccount': null,
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.id, '');
      expect(result.username, '');
      expect(result.name, '');
      expect(result.verified, false);
      expect(result.protectedAccount, false);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = RepostedByUserModel(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        avatarId: 'avatar123',
        verified: false,
        protectedAccount: false,
        isFollowed: false,
      );

      final updated = original.copyWith(name: 'Updated User', isFollowed: true);

      expect(updated.name, 'Updated User');
      expect(updated.isFollowed, true);
      expect(updated.username, 'testuser'); // unchanged
      expect(updated.verified, false); // unchanged
    });

    test('copyWith handles all fields', () {
      const original = RepostedByUserModel(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        avatarId: 'avatar123',
        verified: false,
        protectedAccount: false,
        isFollowed: false,
      );

      final updated = original.copyWith(
        id: '456',
        username: 'newuser',
        name: 'New User',
        avatarId: 'avatar456',
        verified: true,
        protectedAccount: true,
        isFollowed: true,
      );

      expect(updated.id, '456');
      expect(updated.username, 'newuser');
      expect(updated.name, 'New User');
      expect(updated.avatarId, 'avatar456');
      expect(updated.verified, true);
      expect(updated.protectedAccount, true);
      expect(updated.isFollowed, true);
    });

    test('const constructor creates model correctly', () {
      const model = RepostedByUserModel(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        avatarId: 'avatar123',
        verified: true,
        protectedAccount: false,
        isFollowed: true,
      );

      expect(model.id, '123');
      expect(model.username, 'testuser');
      expect(model.name, 'Test User');
      expect(model.avatarId, 'avatar123');
      expect(model.verified, true);
      expect(model.protectedAccount, false);
      expect(model.isFollowed, true);
    });

    test('fromJson extracts avatarId from nested profileMedia', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMedia': {
          'id': 'nested_avatar',
          'name': 'avatar.jpg',
          'type': 'image',
        },
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.avatarId, 'nested_avatar');
    });

    test('fromJson handles empty profileMedia object', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMedia': <String, dynamic>{},
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.avatarId, '');
    });

    test('fromJson handles profileMediaId as non-string', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMediaId': 12345,
      };

      final result = RepostedByUserModel.fromJson(json);

      // profileMediaId must be String, otherwise avatarId is empty
      expect(result.avatarId, '');
    });

    test('fromJson handles profileMedia id as number', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMedia': {'id': 67890},
      };

      final result = RepostedByUserModel.fromJson(json);

      expect(result.avatarId, '67890');
    });

    test('copyWith returns same instance when no fields updated', () {
      const original = RepostedByUserModel(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        avatarId: 'avatar123',
        verified: false,
        protectedAccount: false,
        isFollowed: false,
      );

      final updated = original.copyWith();

      expect(updated.id, original.id);
      expect(updated.username, original.username);
      expect(updated.name, original.name);
      expect(updated.avatarId, original.avatarId);
      expect(updated.verified, original.verified);
    });
  });
}
