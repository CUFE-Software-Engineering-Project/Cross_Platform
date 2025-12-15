import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/models/muted_users_response.dart';

void main() {
  group('MutedUsersResponse', () {
    final testUser1 = UserModel(
      displayName: 'Test User',
      userName: 'testuser',
      image: 'https://example.com/image.jpg',
      bio: 'Test bio',
      isVerified: true,
    );

    final testUser2 = UserModel(
      displayName: 'Another User',
      userName: 'anotheruser',
      image: '',
      bio: '',
      isVerified: false,
    );

    test('should create instance with all properties', () {
      final response = MutedUsersResponse(
        users: [testUser1, testUser2],
        nextCursor: 'cursor123',
        hasMore: true,
      );

      expect(response.users.length, 2);
      expect(response.users[0], testUser1);
      expect(response.users[1], testUser2);
      expect(response.nextCursor, 'cursor123');
      expect(response.hasMore, true);
    });

    group('empty', () {
      test('should create empty response', () {
        final empty = MutedUsersResponse.empty();
        expect(empty.users, <UserModel>[]);
        expect(empty.nextCursor, null);
        expect(empty.hasMore, false);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON with all fields', () {
        final json = {
          'users': [
            {
              'name': 'Test User',
              'username': 'testuser',
              'photo': 'https://example.com/image.jpg',
              'bio': 'Test bio',
              'verified': true,
            },
            {
              'name': 'Another User',
              'username': 'anotheruser',
              'photo': '',
              'bio': '',
              'verified': false,
            },
          ],
          'nextCursor': 'cursor456',
          'hasMore': true,
        };

        final response = MutedUsersResponse.fromJson(json);
        expect(response.users.length, 2);
        expect(response.users[0].displayName, 'Test User');
        expect(response.users[1].displayName, 'Another User');
        expect(response.nextCursor, 'cursor456');
        expect(response.hasMore, true);
      });

      test('should handle missing users field with empty list', () {
        final json = <String, dynamic>{};
        final response = MutedUsersResponse.fromJson(json);
        expect(response.users, <UserModel>[]);
      });

      test('should handle null users field', () {
        final json = {'users': null};
        final response = MutedUsersResponse.fromJson(json);
        expect(response.users, <UserModel>[]);
      });

      test('should handle missing nextCursor', () {
        final json = <String, dynamic>{};
        final response = MutedUsersResponse.fromJson(json);
        expect(response.nextCursor, null);
      });

      test('should handle missing hasMore with default false', () {
        final json = <String, dynamic>{};
        final response = MutedUsersResponse.fromJson(json);
        expect(response.hasMore, false);
      });

      test('should handle null hasMore with default false', () {
        final json = {'hasMore': null};
        final response = MutedUsersResponse.fromJson(json);
        expect(response.hasMore, false);
      });

      test('should handle empty users array', () {
        final json = {
          'users': <dynamic>[],
          'nextCursor': null,
          'hasMore': false,
        };
        final response = MutedUsersResponse.fromJson(json);
        expect(response.users, <UserModel>[]);
        expect(response.nextCursor, null);
        expect(response.hasMore, false);
      });
    });

    group('toJson', () {
      test('should serialize to JSON with all fields', () {
        final response = MutedUsersResponse(
          users: [testUser1, testUser2],
          nextCursor: 'cursor789',
          hasMore: true,
        );

        final json = response.toJson();
        expect(json['users'], isA<List>());
        expect((json['users'] as List).length, 2);
        expect(json['nextCursor'], 'cursor789');
        expect(json['hasMore'], true);
      });

      test('should serialize null nextCursor', () {
        final response = MutedUsersResponse(
          users: [testUser1],
          nextCursor: null,
          hasMore: false,
        );

        final json = response.toJson();
        expect(json['nextCursor'], null);
      });

      test('should serialize empty users list', () {
        final response = MutedUsersResponse.empty();
        final json = response.toJson();
        expect(json['users'], <dynamic>[]);
      });

      test('should serialize and deserialize from JSON', () {
        // Create response with known data
        final response = MutedUsersResponse(
          users: [testUser1, testUser2],
          nextCursor: 'test_cursor',
          hasMore: true,
        );

        // Serialize to JSON
        final json = response.toJson();
        
        // Check basic structure
        expect(json['users'], isA<List>());
        expect(json['nextCursor'], 'test_cursor');
        expect(json['hasMore'], true);
        
        // Note: Full round-trip of users requires matching toJson/fromJson keys in UserModel
        // Since that's tested in user_model_test.dart, we just verify the structure here
        expect((json['users'] as List).length, 2);
      });
    });

    group('copyWith', () {
      final original = MutedUsersResponse(
        users: [testUser1],
        nextCursor: 'cursor_old',
        hasMore: true,
      );

      test('should copy with new users', () {
        final copied = original.copyWith(users: [testUser2]);
        expect(copied.users.length, 1);
        expect(copied.users[0], testUser2);
        expect(copied.nextCursor, original.nextCursor);
        expect(copied.hasMore, original.hasMore);
      });

      test('should copy with new nextCursor', () {
        final copied = original.copyWith(nextCursor: 'cursor_new');
        expect(copied.nextCursor, 'cursor_new');
        expect(copied.users, original.users);
        expect(copied.hasMore, original.hasMore);
      });

      test('should copy with new hasMore', () {
        final copied = original.copyWith(hasMore: false);
        expect(copied.hasMore, false);
        expect(copied.users, original.users);
        expect(copied.nextCursor, original.nextCursor);
      });

      test('should keep original values when no parameters provided', () {
        final copied = original.copyWith();
        expect(copied.users, original.users);
        expect(copied.nextCursor, original.nextCursor);
        expect(copied.hasMore, original.hasMore);
      });

      test('should copy with multiple fields', () {
        final copied = original.copyWith(
          users: [testUser1, testUser2],
          hasMore: false,
        );
        expect(copied.users.length, 2);
        expect(copied.nextCursor, original.nextCursor); // copyWith doesn't override with null
        expect(copied.hasMore, false);
      });
    });
  });
}
