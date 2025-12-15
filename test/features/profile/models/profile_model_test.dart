import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';

void main() {
  group('ProfileModel', () {
    group('fromJson', () {
      test('should create ProfileModel from valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': '123',
          'username': 'testuser',
          'name': 'Test User',
          'bio': 'Test bio',
          '_count': {
            'followers': 100,
            'followings': 50,
          },
          'tweetsCount': 200,
          'verified': true,
          'joinDate': '2023-01-15T10:30:00.000Z',
          'website': 'https://example.com',
          'address': 'New York, USA',
          'postCount': 150,
          'dateOfBirth': '1990-05-20T00:00:00.000Z',
          'isFollowing': true,
          'isFollower': false,
          'protectedAccount': false,
          'blocked': false,
          'muted': false,
          'email': 'test@example.com',
          'profileMediaId': 'avatar123',
          'coverMediaId': 'banner456',
        };

        // Act
        final result = ProfileModel.fromJson(json);

        // Assert
        expect(result.id, '123');
        expect(result.username, 'testuser');
        expect(result.displayName, 'Test User');
        expect(result.bio, 'Test bio');
        expect(result.followersCount, 100);
        expect(result.followingCount, 50);
        expect(result.tweetsCount, 200);
        expect(result.isVerified, true);
        expect(result.website, 'https://example.com');
        expect(result.location, 'New York, USA');
        expect(result.postCount, 150);
        expect(result.isFollowing, true);
        expect(result.isFollower, false);
        expect(result.protectedAccount, false);
        expect(result.isBlockedByMe, false);
        expect(result.isMutedByMe, false);
        expect(result.email, 'test@example.com');
        expect(result.avatarId, 'avatar123');
        expect(result.bannerId, 'banner456');
      });

      test('should handle missing optional fields with defaults', () {
        // Arrange
        final json = {
          'id': '123',
          'username': 'testuser',
        };

        // Act
        final result = ProfileModel.fromJson(json);

        // Assert
        expect(result.id, '123');
        expect(result.username, 'testuser');
        expect(result.displayName, '');
        expect(result.bio, '');
        expect(result.followersCount, 0);
        expect(result.followingCount, 0);
        expect(result.tweetsCount, 0);
        expect(result.isVerified, false);
        expect(result.website, '');
        expect(result.location, '');
        expect(result.postCount, 0);
        expect(result.isFollowing, false);
        expect(result.isFollower, false);
        expect(result.protectedAccount, false);
        expect(result.isBlockedByMe, false);
        expect(result.isMutedByMe, false);
        expect(result.email, '');
        expect(result.avatarId, '');
        expect(result.bannerId, '');
      });

      test('should handle null _count field', () {
        // Arrange
        final json = {
          'id': '123',
          'username': 'testuser',
          '_count': null,
        };

        // Act
        final result = ProfileModel.fromJson(json);

        // Assert
        expect(result.followersCount, 0);
        expect(result.followingCount, 0);
      });
    });

    group('toJson', () {
      test('should convert ProfileModel to JSON', () {
        // Arrange
        final profile = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: true,
          joinedDate: '2023-01-15',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: '1990-05-20',
          isFollowing: true,
          isFollower: false,
          protectedAccount: true,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        // Act
        final result = profile.toJson();

        // Assert
        expect(result['id'], '123');
        expect(result['username'], 'testuser');
        expect(result['name'], 'Test User');
        expect(result['bio'], 'Test bio');
        expect(result['verified'], true);
        expect(result['website'], 'https://example.com');
        expect(result['address'], 'New York, USA');
        expect(result['protectedAccount'], true);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        // Arrange
        final original = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: false,
          joinedDate: '2023-01-15',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: '1990-05-20',
          isFollowing: false,
          isFollower: false,
          protectedAccount: false,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        // Act
        final updated = original.copyWith(
          bio: 'Updated bio',
          isVerified: true,
          followersCount: 150,
          isFollowing: true,
        );

        // Assert
        expect(updated.id, '123');
        expect(updated.username, 'testuser');
        expect(updated.bio, 'Updated bio');
        expect(updated.isVerified, true);
        expect(updated.followersCount, 150);
        expect(updated.isFollowing, true);
        // Unchanged fields
        expect(updated.displayName, 'Test User');
        expect(updated.followingCount, 50);
      });

      test('should create exact copy when no parameters provided', () {
        // Arrange
        final original = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: false,
          joinedDate: '2023-01-15',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: '1990-05-20',
          isFollowing: false,
          isFollower: false,
          protectedAccount: false,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.id, original.id);
        expect(copy.username, original.username);
        expect(copy.displayName, original.displayName);
        expect(copy.bio, original.bio);
        expect(copy.followersCount, original.followersCount);
        expect(copy.followingCount, original.followingCount);
      });
    });

    group('mapMonth', () {
      test('should return correct month abbreviations', () {
        expect(mapMonth(1), 'Jan');
        expect(mapMonth(2), 'Feb');
        expect(mapMonth(3), 'Mar');
        expect(mapMonth(4), 'Apr');
        expect(mapMonth(5), 'May');
        expect(mapMonth(6), 'Jun');
        expect(mapMonth(7), 'Jul');
        expect(mapMonth(8), 'Aug');
        expect(mapMonth(9), 'Sep');
        expect(mapMonth(10), 'Oct');
        expect(mapMonth(11), 'Nov');
        expect(mapMonth(12), 'Dec');
      });

      test('should return empty string for invalid month', () {
        expect(mapMonth(0), '');
        expect(mapMonth(13), '');
        expect(mapMonth(-1), '');
      });
    });

    group('toJson edge cases', () {
      test('should handle empty joinedDate and birthDate', () {
        final profile = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: true,
          joinedDate: '',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: '',
          isFollowing: true,
          isFollower: false,
          protectedAccount: true,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        final result = profile.toJson();

        expect(result['id'], '123');
        expect(result['username'], 'testuser');
      });

      test('should handle ISO date format in joinedDate and birthDate', () {
        final profile = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: true,
          joinedDate: '2023-01-15T10:30:00.000Z',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: '1990-05-20T00:00:00.000Z',
          isFollowing: true,
          isFollower: false,
          protectedAccount: true,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        final result = profile.toJson();

        expect(result['id'], '123');
        expect(result['username'], 'testuser');
      });

      test('should handle invalid date format in joinedDate and birthDate', () {
        final profile = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: true,
          joinedDate: 'not a date',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: 'also not a date',
          isFollowing: true,
          isFollower: false,
          protectedAccount: true,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        final result = profile.toJson();

        expect(result['id'], '123');
        expect(result['username'], 'testuser');
      });
    });

    group('copyWith all fields', () {
      test('should update all fields when all parameters provided', () {
        final original = ProfileModel(
          id: '123',
          username: 'testuser',
          displayName: 'Test User',
          bio: 'Test bio',
          followersCount: 100,
          followingCount: 50,
          tweetsCount: 200,
          isVerified: false,
          joinedDate: '2023-01-15',
          website: 'https://example.com',
          location: 'New York, USA',
          postCount: 150,
          birthDate: '1990-05-20',
          isFollowing: false,
          isFollower: false,
          protectedAccount: false,
          isBlockedByMe: false,
          isMutedByMe: false,
          email: 'test@example.com',
          avatarId: 'avatar123',
          bannerId: 'banner456',
        );

        final updated = original.copyWith(
          id: '456',
          username: 'newuser',
          displayName: 'New User',
          bio: 'New bio',
          followersCount: 200,
          followingCount: 100,
          tweetsCount: 300,
          isVerified: true,
          joinedDate: '2024-01-01',
          website: 'https://new.com',
          location: 'London, UK',
          postCount: 250,
          birthDate: '1995-10-10',
          isFollowing: true,
          isFollower: true,
          protectedAccount: true,
          isBlockedByMe: true,
          isMutedByMe: true,
          email: 'new@example.com',
          avatarId: 'newavatar',
          bannerId: 'newbanner',
        );

        expect(updated.id, '456');
        expect(updated.username, 'newuser');
        expect(updated.displayName, 'New User');
        expect(updated.bio, 'New bio');
        expect(updated.followersCount, 200);
        expect(updated.followingCount, 100);
        expect(updated.tweetsCount, 300);
        expect(updated.isVerified, true);
        expect(updated.joinedDate, '2024-01-01');
        expect(updated.website, 'https://new.com');
        expect(updated.location, 'London, UK');
        expect(updated.postCount, 250);
        expect(updated.birthDate, '1995-10-10');
        expect(updated.isFollowing, true);
        expect(updated.isFollower, true);
        expect(updated.protectedAccount, true);
        expect(updated.isBlockedByMe, true);
        expect(updated.isMutedByMe, true);
        expect(updated.email, 'new@example.com');
        expect(updated.avatarId, 'newavatar');
        expect(updated.bannerId, 'newbanner');
      });
    });
  });
}
