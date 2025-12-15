// user_search_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';

void main() {
  group('UserSearchModel', () {
    test('Constructor should initialize properties correctly', () {
      final model = UserSearchModel(
        id: '123',
        username: 'testuser',
        name: 'Test Name',
        bio: 'This is a bio',
        profileMedia: 'media_key',
        followers: 100,
      );

      expect(model.id, '123');
      expect(model.username, 'testuser');
      expect(model.name, 'Test Name');
      expect(model.bio, 'This is a bio');
      expect(model.profileMedia, 'media_key');
      expect(model.followers, 100);
    });
    group('fromMap', () {
      test(
        'should parse correctly when profileMedia is a Map (nested keyName)',
        () {
          final map = {
            "id": "1",
            "username": "user1",
            "name": "User One",
            "bio": "Bio",
            "profileMedia": {"keyName": "image_123.jpg"},
            "_count": {"followers": 50},
          };

          final model = UserSearchModel.fromMap(map);

          expect(model.id, "1");
          expect(model.profileMedia, "image_123.jpg");
          expect(model.followers, 50);
        },
      );

      test('should parse correctly when profileMedia is a String', () {
        final map = {
          "id": "2",
          "username": "user2",
          "name": "User Two",
          "bio": "Bio",
          "profileMedia": "direct_image_link.jpg",
          "_count": {"followers": 10},
        };

        final model = UserSearchModel.fromMap(map);

        expect(model.profileMedia, "direct_image_link.jpg");
      });

      test('should handle null profileMedia', () {
        final map = {
          "id": "3",
          "username": "user3",
          "name": "User Three",
          "bio": null,
          "profileMedia": null,
          "_count": {"followers": 5},
        };

        final model = UserSearchModel.fromMap(map);

        expect(model.profileMedia, null);
        expect(model.bio, null);
      });

      test(
        'should handle missing or null basic fields (id, username, name)',
        () {
          final map = <String, dynamic>{};

          final model = UserSearchModel.fromMap(map);
          expect(model.id, "");
          expect(model.username, "");
          expect(model.name, "");
        },
      );

      test('should return 0 followers if _count is null', () {
        final map = {
          "id": "4",
          "username": "user4",
          "name": "User Four",
          "profileMedia": null,
          "_count": null,
        };

        final model = UserSearchModel.fromMap(map);

        expect(model.followers, 0);
      });

      test(
        'should return 0 followers if _count exists but followers key is missing/null',
        () {
          final map = {
            "id": "5",
            "username": "user5",
            "name": "User Five",
            "profileMedia": null,
            "_count": {"following": 10},
          };

          final model = UserSearchModel.fromMap(map);

          expect(model.followers, 0);
        },
      );

      test('should correctly parse followers count', () {
        final map = {
          "id": "6",
          "username": "user6",
          "name": "User Six",
          "profileMedia": null,
          "_count": {"followers": 999},
        };

        final model = UserSearchModel.fromMap(map);

        expect(model.followers, 999);
      });
    });
  });
}
