import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/user_model.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('should create UserModel from valid JSON with all fields', () {
        // Arrange
        final json = {
          'name': 'Test User',
          'username': 'testuser',
          'photo': 'photo123',
          'bio': 'This is a test bio',
          'isFollowing': true,
          'isFollower': false,
          'verified': true,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.displayName, 'Test User');
        expect(result.userName, 'testuser');
        expect(result.image, 'photo123');
        expect(result.bio, 'This is a test bio');
        expect(result.isFollowing, true);
        expect(result.isFollower, false);
        expect(result.isVerified, true);
      });

      test('should handle missing optional fields with defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.displayName, '');
        expect(result.userName, '');
        expect(result.image, '');
        expect(result.bio, '');
        expect(result.isFollowing, false);
        expect(result.isFollower, false);
        expect(result.isVerified, false);
      });

      test('should handle null values', () {
        // Arrange
        final json = {
          'name': null,
          'username': null,
          'photo': null,
          'bio': null,
          'isFollowing': null,
          'isFollower': null,
          'verified': null,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.displayName, '');
        expect(result.userName, '');
        expect(result.image, '');
        expect(result.bio, '');
        expect(result.isFollowing, false);
        expect(result.isFollower, false);
        expect(result.isVerified, false);
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON', () {
        // Arrange
        final user = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'photo123',
          bio: 'Test bio',
          isFollowing: true,
          isFollower: false,
          isVerified: true,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['displayName'], 'Test User');
        expect(json['userName'], 'testuser');
        expect(json['image'], 'photo123');
        expect(json['bio'], 'Test bio');
        expect(json['isFollowing'], true);
        expect(json['isFollower'], false);
        expect(json['isVerified'], true);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = UserModel(
          displayName: 'Original Name',
          userName: 'original',
          image: 'image1',
          bio: 'Original bio',
          isFollowing: false,
          isFollower: false,
          isVerified: false,
        );

        // Act
        final copy = original.copyWith(
          displayName: 'Updated Name',
          isFollowing: true,
          isVerified: true,
        );

        // Assert
        expect(copy.displayName, 'Updated Name');
        expect(copy.userName, 'original');
        expect(copy.image, 'image1');
        expect(copy.bio, 'Original bio');
        expect(copy.isFollowing, true);
        expect(copy.isVerified, true);
      });

      test('should return same values when no parameters provided', () {
        // Arrange
        final original = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
          isFollowing: true,
          isFollower: true,
          isVerified: true,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.displayName, original.displayName);
        expect(copy.userName, original.userName);
        expect(copy.image, original.image);
        expect(copy.bio, original.bio);
        expect(copy.isFollowing, original.isFollowing);
        expect(copy.isFollower, original.isFollower);
        expect(copy.isVerified, original.isVerified);
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final user = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
          isFollowing: true,
          isFollower: false,
          isVerified: true,
        );

        // Act
        final result = user.toString();

        // Assert
        expect(result, contains('Test User'));
        expect(result, contains('testuser'));
        expect(result, contains('image1'));
        expect(result, contains('Bio'));
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final user1 = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
          isFollowing: true,
          isFollower: false,
          isVerified: true,
        );

        final user2 = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
          isFollowing: true,
          isFollower: false,
          isVerified: true,
        );

        // Assert
        expect(user1 == user2, true);
        expect(user1.hashCode == user2.hashCode, true);
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final user1 = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
          isFollowing: true,
          isFollower: false,
          isVerified: true,
        );

        final user2 = UserModel(
          displayName: 'Different User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
          isFollowing: true,
          isFollower: false,
          isVerified: true,
        );

        // Assert
        expect(user1 == user2, false);
      });

      test('should be equal to itself', () {
        // Arrange
        final user = UserModel(
          displayName: 'Test User',
          userName: 'testuser',
          image: 'image1',
          bio: 'Bio',
        );

        // Assert
        expect(user == user, true);
      });
    });
  });
}
