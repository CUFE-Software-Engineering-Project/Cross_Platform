// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchHistoryHiveModelAdapter
    extends TypeAdapter<SearchHistoryHiveModel> {
  @override
  final typeId = 4;

  @override
  SearchHistoryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      username: fields[2] as String,
      isVerified: fields[3] as bool,
      avatarUrl: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.isVerified)
      ..writeByte(4)
      ..write(obj.avatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
