import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/models/user_suggestion.dart';

void main() {
  group('UserSuggestion Tests', () {
    test('fromJson creates UserSuggestion correctly with all fields', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'verified': true,
        'bio': 'Test bio',
        'profileMedia': {'id': 'media123', 'keyName': 'profile.jpg'},
        '_count': {'followers': 100},
        'isFollower': true,
        'isFollowing': false,
      };

      final result = UserSuggestion.fromJson(json);

      expect(result.id, '123');
      expect(result.username, 'testuser');
      expect(result.name, 'Test User');
      expect(result.verified, true);
      expect(result.bio, 'Test bio');
      expect(result.profileMedia, isNotNull);
      expect(result.profileMedia!.id, 'media123');
      expect(result.profileMedia!.keyName, 'profile.jpg');
      expect(result.count.followers, 100);
      expect(result.isFollower, true);
      expect(result.isFollowing, false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {'id': '123', 'username': 'testuser', 'name': 'Test User'};

      final result = UserSuggestion.fromJson(json);

      expect(result.id, '123');
      expect(result.username, 'testuser');
      expect(result.name, 'Test User');
      expect(result.verified, false);
      expect(result.bio, isNull);
      expect(result.profileMedia, isNull);
      expect(result.count.followers, 0);
      expect(result.isFollower, false);
      expect(result.isFollowing, false);
    });

    test('fromJson handles null values gracefully', () {
      final json = {
        'id': null,
        'username': null,
        'name': null,
        'verified': null,
      };

      final result = UserSuggestion.fromJson(json);

      expect(result.id, '');
      expect(result.username, '');
      expect(result.name, '');
      expect(result.verified, false);
    });

    test('profileImageUrl returns correct URL when profileMedia exists', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMedia': {'id': 'media123', 'keyName': 'profile.jpg'},
      };

      final result = UserSuggestion.fromJson(json);

      expect(
        result.profileImageUrl,
        'https://litex.siematworld.online/media/profile.jpg',
      );
    });

    test('profileImageUrl returns empty string when profileMedia is null', () {
      final json = {'id': '123', 'username': 'testuser', 'name': 'Test User'};

      final result = UserSuggestion.fromJson(json);

      expect(result.profileImageUrl, '');
    });

    test('profileImageUrl returns constructed URL when keyName is null', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'name': 'Test User',
        'profileMedia': {'id': 'media123', 'keyName': null},
      };

      final result = UserSuggestion.fromJson(json);

      // When keyName is null, fromJson converts it to '', so URL is constructed
      expect(result.profileImageUrl, 'https://litex.siematworld.online/media/');
    });
  });

  group('ProfileMedia Tests', () {
    test('fromJson creates ProfileMedia correctly', () {
      final json = {'id': 'media123', 'keyName': 'profile.jpg'};

      final result = ProfileMedia.fromJson(json);

      expect(result.id, 'media123');
      expect(result.keyName, 'profile.jpg');
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final result = ProfileMedia.fromJson(json);

      expect(result.id, '');
      expect(result.keyName, '');
    });
  });

  group('UserCount Tests', () {
    test('fromJson creates UserCount with int value', () {
      final json = {'followers': 100};

      final result = UserCount.fromJson(json);

      expect(result.followers, 100);
    });

    test('fromJson creates UserCount with double value', () {
      final json = {'followers': 100.5};

      final result = UserCount.fromJson(json);

      expect(result.followers, 101);
    });

    test('fromJson creates UserCount with string value', () {
      final json = {'followers': '100'};

      final result = UserCount.fromJson(json);

      expect(result.followers, 100);
    });

    test('fromJson handles invalid string', () {
      final json = {'followers': 'invalid'};

      final result = UserCount.fromJson(json);

      expect(result.followers, 0);
    });

    test('fromJson handles missing field', () {
      final json = <String, dynamic>{};

      final result = UserCount.fromJson(json);

      expect(result.followers, 0);
    });
  });
}
