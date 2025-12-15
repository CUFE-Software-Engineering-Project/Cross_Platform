import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lite_x/core/models/usermodel.dart';

import 'usermodel_adapter_test.mocks.dart';

@GenerateMocks([BinaryReader, BinaryWriter])
void main() {
  late UserModelAdapter adapter;
  late MockBinaryReader mockReader;
  late MockBinaryWriter mockWriter;

  final testUser = UserModel(
    name: 'Test User',
    email: 'test@example.com',
    dob: '2000-01-01',
    username: 'testuser',
    photo: 'https://example.com/photo.jpg',
    bio: 'Software Engineer',
    id: 'user_123',
    isEmailVerified: true,
    isVerified: true,
    tfaVerified: false,
    interests: {'coding', 'flutter'},
    localProfilePhotoPath: '/local/path/image.png',
  );

  setUp(() {
    adapter = UserModelAdapter();
    mockReader = MockBinaryReader();
    mockWriter = MockBinaryWriter();
  });

  group('UserModelAdapter', () {
    test('typeId should be 0', () {
      expect(adapter.typeId, 0);
    });

    test('hashCode should match typeId hashCode', () {
      expect(adapter.hashCode, adapter.typeId.hashCode);
    });

    test('operator == should return true for same type and typeId', () {
      final adapter2 = UserModelAdapter();
      expect(adapter == adapter2, true);
      expect(adapter == Object(), false);
    });

    group('write', () {
      test('should write all fields correctly for a full user', () {
        adapter.write(mockWriter, testUser);
        verify(mockWriter.writeByte(12)).called(1);
        verify(mockWriter.writeByte(0));
        verify(mockWriter.writeByte(1));
        verify(mockWriter.write('Test User'));
        verify(mockWriter.write('test@example.com'));
        verify(mockWriter.write('2000-01-01'));
        verify(mockWriter.write('testuser'));
        verify(mockWriter.write('https://example.com/photo.jpg'));
        verify(mockWriter.write('Software Engineer'));
        verify(mockWriter.write('user_123'));
        verify(mockWriter.write(true)).called(2);
        verify(mockWriter.write(false));
        verify(mockWriter.write({'coding', 'flutter'}));
        verify(mockWriter.write('/local/path/image.png'));
      });
    });

    group('read', () {
      test('should read all fields correctly for a full user', () {
        when(mockReader.readByte()).thenAnswer((invocation) {
          return 12;
        });

        var readByteCallCount = 0;
        when(mockReader.readByte()).thenAnswer((_) {
          final result = readByteCallCount == 0 ? 12 : (readByteCallCount - 1);
          readByteCallCount++;
          return result;
        });
        final values = [
          'Test User',
          'test@example.com',
          '2000-01-01',
          'testuser',
          'https://example.com/photo.jpg',
          'Software Engineer',
          'user_123',
          true,
          true,
          false,
          {'coding', 'flutter'},
          '/local/path/image.png',
        ];

        var readCallCount = 0;
        when(mockReader.read()).thenAnswer((_) => values[readCallCount++]);

        final result = adapter.read(mockReader);

        expect(result.name, testUser.name);
        expect(result.email, testUser.email);
        expect(result.id, testUser.id);
        expect(result.photo, testUser.photo);
        expect(result.interests, testUser.interests);
        expect(result.localProfilePhotoPath, testUser.localProfilePhotoPath);
      });

      test('should handle missing/null optional fields during read', () {
        var readByteCallCount = 0;
        when(mockReader.readByte()).thenAnswer((_) {
          final result = readByteCallCount == 0 ? 12 : (readByteCallCount - 1);
          readByteCallCount++;
          return result;
        });
        final values = [
          'Test User',
          'test@example.com',
          '2000-01-01',
          'testuser',
          null,
          null,
          'user_123',
          true,
          true,
          null,
          null,
          null,
        ];

        var readCallCount = 0;
        when(mockReader.read()).thenAnswer((_) => values[readCallCount++]);

        final result = adapter.read(mockReader);

        expect(result.photo, null);
        expect(result.bio, null);
        expect(result.tfaVerified, null);
        expect(result.interests, isEmpty);
        expect(result.localProfilePhotoPath, null);
      });
    });
  });
}
