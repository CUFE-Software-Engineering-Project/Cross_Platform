import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/core/models/usermodel.dart';

void main() {
  group('UserModel Tests', () {
    final tUser = UserModel(
      name: 'Test User',
      email: 'test@example.com',
      dob: '2000-01-01',
      username: 'testuser',
      id: '123',
      isEmailVerified: true,
      isVerified: true,
      tfaVerified: true,
      interests: {'Coding', 'Flutter'},
      photo: 'photo_id',
      bio: 'Hello world',
    );

    test('equality fails when specific fields differ', () {
      expect(tUser == tUser.copyWith(name: 'Diff'), isFalse);
      expect(tUser == tUser.copyWith(email: 'diff@mail.com'), isFalse);
      expect(tUser == tUser.copyWith(dob: '1900-01-01'), isFalse);
      expect(tUser == tUser.copyWith(username: 'diff_user'), isFalse);
      expect(tUser == tUser.copyWith(photo: 'diff_photo'), isFalse);
      expect(tUser == tUser.copyWith(bio: 'Diff bio'), isFalse);
      expect(tUser == tUser.copyWith(id: '999'), isFalse);
      expect(
        tUser == tUser.copyWith(isEmailVerified: !tUser.isEmailVerified),
        isFalse,
      );
      expect(tUser == tUser.copyWith(isVerified: !tUser.isVerified), isFalse);
      expect(
        tUser == tUser.copyWith(tfaVerified: !(tUser.tfaVerified ?? false)),
        isFalse,
      );
      expect(tUser == tUser.copyWith(interests: {'Other'}), isFalse);
    });

    test('hashCode changes when fields change', () {
      final tUserDiff = tUser.copyWith(name: 'Different Name');
      expect(tUser.hashCode, isNot(equals(tUserDiff.hashCode)));
    });

    test('copyWith creates a new instance with updated values', () {
      final result = tUser.copyWith(
        name: 'New Name',
        interests: {'Dart'},
        localProfilePhotoPath: '/path/to/image',
      );

      expect(result.name, 'New Name');
      expect(result.interests, {'Dart'});
      expect(result.localProfilePhotoPath, '/path/to/image');
      expect(result.email, tUser.email);
    });

    test('fromMap returns correct UserModel with valid map', () {
      final map = {
        'name': 'Test User',
        'email': 'test@example.com',
        'dateOfBirth': '2000-01-01',
        'username': 'testuser',
        'id': 123,
        'isEmailVerified': true,
        'isVerified': true,
        'tfaVerifed': true,
        'interests': ['Coding', 'Flutter'],
        'photo': 'photo_id',
        'bio': 'Hello world',
      };

      final result = UserModel.fromMap(map);
      expect(result, tUser);
    });

    test('fromMap handles fallback to "dob" key', () {
      final map = {
        'name': 'Test User',
        'email': 'test@example.com',
        'dob': '1999-12-31',
        'username': 'testuser',
        'id': '123',
        'isEmailVerified': false,
        'isVerified': false,
      };

      final result = UserModel.fromMap(map);
      expect(result.dob, '1999-12-31');
    });

    test('fromMap parses interests from Set input', () {
      final map = {
        'name': 'Test User',
        'email': 'test@example.com',
        'dob': '2000-01-01',
        'username': 'testuser',
        'id': '123',
        'interests': {'Tech', 'Design'},
      };

      final result = UserModel.fromMap(map);
      expect(result.interests, {'Tech', 'Design'});
    });

    test('fromMap handles null interests', () {
      final map = {
        'name': 'Test User',
        'email': 'test@example.com',
        'dob': '2000-01-01',
        'username': 'testuser',
        'id': '123',
        'interests': null,
      };

      final result = UserModel.fromMap(map);
      expect(result.interests, isEmpty);
    });

    test('toMap returns correct map', () {
      final result = tUser.toMap();
      expect(result['name'], 'Test User');
      expect(result['email'], 'test@example.com');
      expect(result['dateOfBirth'], '2000-01-01');
      expect(result['tfaVerifed'], true);
      expect(result['interests'], ['Coding', 'Flutter']);
    });

    test('toJson returns correct json string', () {
      final result = tUser.toJson();
      final decoded = json.decode(result);
      expect(decoded['username'], 'testuser');
      expect(decoded['id'], '123');
    });

    test('fromJson returns correct UserModel', () {
      final jsonStr = json.encode({
        'name': 'Test User',
        'email': 'test@example.com',
        'dateOfBirth': '2000-01-01',
        'username': 'testuser',
        'id': '123',
        'isEmailVerified': true,
        'isVerified': true,
        'tfaVerifed': true,
        'interests': ['Coding', 'Flutter'],
        'photo': 'photo_id',
        'bio': 'Hello world',
      });

      final result = UserModel.fromJson(jsonStr);
      expect(result, tUser);
    });

    test('toString contains correct class name', () {
      expect(tUser.toString(), contains('UserModel'));
      expect(tUser.toString(), contains('test@example.com'));
    });
  });
}
