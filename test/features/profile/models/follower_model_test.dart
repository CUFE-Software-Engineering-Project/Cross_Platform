import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/usermodel.dart';
import 'package:lite_x/features/profile/models/follower_model.dart';

void main() {
  group('FollowerModel', () {
    final testUser = UserModel(
      name: 'Test User',
      email: 'test@example.com',
      dob: '1990-01-01',
      username: 'testuser',
      id: '123',
      isEmailVerified: true,
      isVerified: false,
    );

    group('fromJson', () {
      test('should create FollowerModel from valid JSON with all fields', () {
        // Arrange
        final json = {
          'user': testUser.toMap(),
          'isFollowing': true,
          'isFollower': false,
          'followedAt': '2023-01-15T10:30:00.000Z',
        };

        // Act
        final result = FollowerModel.fromJson(json);

        // Assert
        expect(result.user.username, 'testuser');
        expect(result.user.name, 'Test User');
        expect(result.isFollowing, true);
        expect(result.isFollower, false);
        expect(result.followedAt, isNotNull);
        expect(result.followedAt!.year, 2023);
        expect(result.followedAt!.month, 1);
        expect(result.followedAt!.day, 15);
      });

      test('should handle missing optional fields with defaults', () {
        // Arrange
        final json = {'user': testUser.toMap()};

        // Act
        final result = FollowerModel.fromJson(json);

        // Assert
        expect(result.user.username, 'testuser');
        expect(result.isFollowing, false);
        expect(result.isFollower, false);
        expect(result.followedAt, isNull);
      });

      test('should handle null user field with empty UserModel', () {
        // Arrange
        final json = {'user': null, 'isFollowing': true, 'isFollower': false};

        // Act
        final result = FollowerModel.fromJson(json);

        // Assert
        expect(result.user.username, '');
        expect(result.user.name, '');
        expect(result.isFollowing, true);
        expect(result.isFollower, false);
      });
    });

    group('toJson', () {
      test('should convert FollowerModel to JSON', () {
        // Arrange
        final follower = FollowerModel(
          user: testUser,
          isFollowing: true,
          isFollower: false,
          followedAt: DateTime.parse('2023-01-15T10:30:00.000Z'),
        );

        // Act
        final result = follower.toJson();

        // Assert
        expect(result['user'], isA<String>());
        expect(result['isFollowing'], true);
        expect(result['isFollower'], false);
        expect(result['followedAt'], '2023-01-15T10:30:00.000Z');
      });

      test('should handle null followedAt', () {
        // Arrange
        final follower = FollowerModel(
          user: testUser,
          isFollowing: false,
          isFollower: true,
          followedAt: null,
        );

        // Act
        final result = follower.toJson();

        // Assert
        expect(result['followedAt'], isNull);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        // Arrange
        final original = FollowerModel(
          user: testUser,
          isFollowing: false,
          isFollower: false,
          followedAt: DateTime.parse('2023-01-15T10:30:00.000Z'),
        );

        final newUser = UserModel(
          name: 'New User',
          email: 'new@example.com',
          dob: '1995-06-20',
          username: 'newuser',
          id: '456',
          isEmailVerified: true,
          isVerified: true,
        );

        // Act
        final updated = original.copyWith(user: newUser, isFollowing: true);

        // Assert
        expect(updated.user.username, 'newuser');
        expect(updated.isFollowing, true);
        expect(updated.isFollower, false); // Unchanged
        expect(updated.followedAt, original.followedAt); // Unchanged
      });

      test('should create exact copy when no parameters provided', () {
        // Arrange
        final original = FollowerModel(
          user: testUser,
          isFollowing: true,
          isFollower: false,
          followedAt: DateTime.parse('2023-01-15T10:30:00.000Z'),
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.user, original.user);
        expect(copy.isFollowing, original.isFollowing);
        expect(copy.isFollower, original.isFollower);
        expect(copy.followedAt, original.followedAt);
      });
    });

    group('empty', () {
      test('should create an empty FollowerModel', () {
        // Act
        final empty = FollowerModel.empty();

        // Assert
        expect(empty.user.username, '');
        expect(empty.user.name, '');
        expect(empty.user.email, '');
        expect(empty.user.id, '');
        expect(empty.isFollowing, false);
        expect(empty.isFollower, false);
        expect(empty.followedAt, isNull);
      });
    });

    group('edge cases', () {
      test('should handle invalid date format gracefully', () {
        // Arrange
        final json = {'user': testUser.toMap(), 'followedAt': 'invalid-date'};

        // Act & Assert
        expect(() => FollowerModel.fromJson(json), throwsFormatException);
      });

      test('should handle empty JSON map', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final result = FollowerModel.fromJson(json);

        // Assert
        expect(result.user.username, '');
        expect(result.isFollowing, false);
        expect(result.isFollower, false);
        expect(result.followedAt, isNull);
      });

      test('should handle copyWith with all parameters', () {
        // Arrange
        final original = FollowerModel(
          user: testUser,
          isFollowing: false,
          isFollower: false,
          followedAt: null,
        );

        final newUser = UserModel(
          name: 'Updated User',
          email: 'updated@example.com',
          dob: '2000-12-31',
          username: 'updateduser',
          id: '999',
          isEmailVerified: false,
          isVerified: true,
        );

        final newDate = DateTime.parse('2024-06-15T14:30:00.000Z');

        // Act
        final updated = original.copyWith(
          user: newUser,
          isFollowing: true,
          isFollower: true,
          followedAt: newDate,
        );

        // Assert
        expect(updated.user.username, 'updateduser');
        expect(updated.user.name, 'Updated User');
        expect(updated.isFollowing, true);
        expect(updated.isFollower, true);
        expect(updated.followedAt, newDate);
      });

      test('should correctly serialize and deserialize', () {
        // Arrange
        final original = FollowerModel(
          user: testUser,
          isFollowing: true,
          isFollower: true,
          followedAt: DateTime.parse('2023-01-15T10:30:00.000Z'),
        );

        // Act
        final json = original.toJson();
        // Since user.toJson() returns a String, we need to parse it back to Map
        final jsonWithParsedUser = {
          ...json,
          'user': testUser
              .toMap(), // Use toMap instead of toJson for deserialization
        };
        final deserialized = FollowerModel.fromJson(jsonWithParsedUser);

        // Assert
        expect(deserialized.user.username, original.user.username);
        expect(deserialized.user.name, original.user.name);
        expect(deserialized.isFollowing, original.isFollowing);
        expect(deserialized.isFollower, original.isFollower);
        expect(
          deserialized.followedAt?.toIso8601String(),
          original.followedAt?.toIso8601String(),
        );
      });

      test('toJson should handle user toJson method correctly', () {
        // Arrange
        final follower = FollowerModel(
          user: testUser,
          isFollowing: true,
          isFollower: false,
        );

        // Act
        final result = follower.toJson();

        // Assert
        expect(result['user'], isA<String>());
        expect(result.containsKey('user'), true);
        expect(result.containsKey('isFollowing'), true);
        expect(result.containsKey('isFollower'), true);
        expect(result.containsKey('followedAt'), true);
      });

      test('should handle both following and follower true', () {
        // Arrange
        final json = {
          'user': testUser.toMap(),
          'isFollowing': true,
          'isFollower': true,
          'followedAt': '2023-05-20T08:15:30.000Z',
        };

        // Act
        final result = FollowerModel.fromJson(json);

        // Assert
        expect(result.isFollowing, true);
        expect(result.isFollower, true);
        expect(result.followedAt, isNotNull);
        expect(result.followedAt!.year, 2023);
        expect(result.followedAt!.month, 5);
        expect(result.followedAt!.day, 20);
      });
    });
  });
}
