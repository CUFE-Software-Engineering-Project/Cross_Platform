import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';

void main() {
  group('SearchUserModel', () {
    group('fromJson', () {
      test('should create SearchUserModel from valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'user123',
          'username': 'testuser',
          'name': 'Test User',
          'verified': true,
          'bio': 'Test bio',
          'profileMedia': 'media123',
          '_count': {'followers': 100},
          'score': 95.5,
          'isFollowing': true,
          'isFollower': false,
          'profileMediaId': 'mediaId123',
        };

        // Act
        final result = SearchUserModel.fromJson(json);

        // Assert
        expect(result.id, 'user123');
        expect(result.username, 'testuser');
        expect(result.name, 'Test User');
        expect(result.verified, true);
        expect(result.bio, 'Test bio');
        expect(result.profileMedia, 'media123');
        expect(result.followers, 100);
        expect(result.score, 95.5);
        expect(result.isFollowing, true);
        expect(result.isFollower, false);
        expect(result.profileMediaId, 'mediaId123');
      });

      test('should handle missing optional fields with defaults', () {
        // Arrange
        final json = {
          'id': 'user123',
          'username': 'testuser',
        };

        // Act
        final result = SearchUserModel.fromJson(json);

        // Assert
        expect(result.id, 'user123');
        expect(result.username, 'testuser');
        expect(result.name, '');
        expect(result.verified, false);
        expect(result.bio, '');
        expect(result.profileMedia, '');
        expect(result.followers, 0);
        expect(result.score, 0);
        expect(result.isFollowing, false);
        expect(result.isFollower, false);
      });

      test('should handle null _count field', () {
        // Arrange
        final json = {
          'id': 'user123',
          'username': 'testuser',
          'name': 'Test',
        };

        // Act
        final result = SearchUserModel.fromJson(json);

        // Assert
        expect(result.followers, 0);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = SearchUserModel(
          id: 'user123',
          username: 'testuser',
          name: 'Test User',
          verified: false,
          bio: 'Original bio',
          profileMedia: 'media123',
          followers: 100,
          score: 50,
          isFollowing: false,
          isFollower: false,
          profileMediaId: 'mediaId123',
        );

        // Act
        final copy = original.copyWith(
          name: 'Updated Name',
          verified: true,
          followers: 200,
        );

        // Assert
        expect(copy.id, 'user123');
        expect(copy.username, 'testuser');
        expect(copy.name, 'Updated Name');
        expect(copy.verified, true);
        expect(copy.bio, 'Original bio');
        expect(copy.followers, 200);
      });

      test('should return same values when no parameters provided', () {
        // Arrange
        final original = SearchUserModel(
          id: 'user123',
          username: 'testuser',
          name: 'Test User',
          verified: true,
          bio: 'Bio',
          profileMedia: 'media123',
          followers: 100,
          score: 50,
          isFollowing: true,
          isFollower: false,
          profileMediaId: 'mediaId123',
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.id, original.id);
        expect(copy.username, original.username);
        expect(copy.name, original.name);
        expect(copy.verified, original.verified);
      });
    });
  });
}
