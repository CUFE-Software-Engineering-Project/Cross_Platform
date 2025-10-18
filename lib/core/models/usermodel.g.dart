// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usermodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name: fields[0] as String,
      email: fields[1] as String,
      dob: fields[2] as String,
      username: fields[3] as String,
      photo: fields[4] as String?,
      bio: fields[5] as String?,
      id: fields[6] as String,
      isEmailVerified: fields[7] as bool,
      isVerified: fields[8] as bool,
      loginCodesSet: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.dob)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.photo)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.isEmailVerified)
      ..writeByte(8)
      ..write(obj.isVerified)
      ..writeByte(9)
      ..write(obj.loginCodesSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
