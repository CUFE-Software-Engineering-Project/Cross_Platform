// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usersearchmodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSearchModelAdapter extends TypeAdapter<UserSearchModel> {
  @override
  final typeId = 4;

  @override
  UserSearchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSearchModel(
      id: fields[0] as String,
      username: fields[1] as String,
      name: fields[2] as String,
      bio: fields[3] as String?,
      profileMedia: fields[4] as String?,
      followers: (fields[5] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UserSearchModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.profileMedia)
      ..writeByte(5)
      ..write(obj.followers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSearchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
