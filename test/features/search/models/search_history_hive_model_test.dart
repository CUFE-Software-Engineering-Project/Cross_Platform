import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lite_x/features/search/models/search_history_hive_model.dart';

/// Mock BinaryReader
class MockBinaryReader extends BinaryReader {
  final List<dynamic> _data;
  int _index = 0;

  MockBinaryReader(this._data);

  @override
  int readByte() => _data[_index++] as int;

  @override
  dynamic read([int? typeId]) => _data[_index++];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError();
}

/// Mock BinaryWriter
class MockBinaryWriter extends BinaryWriter {
  final List<dynamic> written = [];

  @override
  void writeByte(int byte) => written.add(byte);

  @override
  void write<T>(T value, {bool withTypeId = true}) =>
      written.add(value);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError();
}

void main() {
  group('SearchHistoryHiveModel', () {
    test('creates instance with correct properties', () {
      final now = DateTime.now();

      final model = SearchHistoryHiveModel(
        query: 'flutter',
        searchedAt: now,
      );

      expect(model.query, 'flutter');
      expect(model.searchedAt, now);
    });
  });

  group('SearchHistoryHiveModelAdapter', () {
    late SearchHistoryHiveModelAdapter adapter;
    late Directory testDir;
    late Box<SearchHistoryHiveModel> testBox;

    setUp(() async {
      adapter = SearchHistoryHiveModelAdapter();

      testDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(testDir.path);

      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }

      testBox = await Hive.openBox<SearchHistoryHiveModel>(
        'search_history_test',
      );
    });

    tearDown(() async {
      await testBox.clear();
      await testBox.close();
      await Hive.deleteBoxFromDisk('search_history_test');
      await testDir.delete(recursive: true);
      Hive.close();
    });

    test('has correct typeId', () {
      expect(adapter.typeId, 3);
    });

    test('write serializes model correctly', () {
      final now = DateTime(2024, 12, 14, 10, 30, 45);
      final model = SearchHistoryHiveModel(
        query: 'flutter test',
        searchedAt: now,
      );

      final writer = MockBinaryWriter();
      adapter.write(writer, model);

      expect(writer.written, [
        2,               // number of fields
        0,               // field 0 index
        'flutter test',  // query
        1,               // field 1 index
        now,             // searchedAt
      ]);
    });

    test('read deserializes model correctly', () {
      final now = DateTime(2024, 12, 14, 10, 30, 45);

      final reader = MockBinaryReader([
        2,
        0, 'flutter test',
        1, now,
      ]);

      final model = adapter.read(reader);

      expect(model.query, 'flutter test');
      expect(model.searchedAt, now);
    });

    test('writes and reads model through Hive correctly', () async {
      final now = DateTime(2024, 12, 14, 10, 30, 45);

      final model = SearchHistoryHiveModel(
        query: 'flutter development',
        searchedAt: now,
      );

      await testBox.put('key1', model);

      final retrieved = testBox.get('key1');

      expect(retrieved, isNotNull);
      expect(retrieved!.query, 'flutter development');
      expect(retrieved.searchedAt, now);
    });

    test('retrieves multiple models from Hive box', () async {
      await testBox.put(
        'key1',
        SearchHistoryHiveModel(
          query: 'flutter',
          searchedAt: DateTime(2024, 1, 1),
        ),
      );
      await testBox.put(
        'key2',
        SearchHistoryHiveModel(
          query: 'dart',
          searchedAt: DateTime(2024, 1, 2),
        ),
      );

      final values = testBox.values.toList();

      expect(values.length, 2);
      expect(values.any((m) => m.query == 'flutter'), isTrue);
      expect(values.any((m) => m.query == 'dart'), isTrue);
    });
    test('adapter equality and hashCode', () {
        final a1 = SearchHistoryHiveModelAdapter();
        final a2 = SearchHistoryHiveModelAdapter();

        expect(a1, equals(a2));
        expect(a1.hashCode, equals(a2.hashCode));
      });
    test('adapter read/write handles empty query', () {
      final now = DateTime.now();
      final model = SearchHistoryHiveModel(
        query: '',
        searchedAt: now,
      );

      final writer = MockBinaryWriter();
      adapter.write(writer, model);

      final reader = MockBinaryReader(writer.written);
      final result = adapter.read(reader);

      expect(result.query, '');
      expect(result.searchedAt, now);
    });
    test('adapter preserves special characters and datetime precision', () {
      final now = DateTime(2024, 12, 14, 10, 30, 45, 123, 456);
      const query = 'search @user #tag 中文 🎉';

      final model = SearchHistoryHiveModel(
        query: query,
        searchedAt: now,
      );

      final writer = MockBinaryWriter();
      adapter.write(writer, model);

      final reader = MockBinaryReader(writer.written);
      final result = adapter.read(reader);

      expect(result.query, query);
      expect(result.searchedAt, now);
      expect(result.searchedAt.microsecond, 456);
    });

  });
}
