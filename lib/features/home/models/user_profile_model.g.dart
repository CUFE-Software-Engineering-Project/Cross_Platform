// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaModelAdapter extends TypeAdapter<MediaModel> {
  @override
  final typeId = 5;

  @override
  MediaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaModel(
      id: fields[0] as String,
      name: fields[1] as String,
      keyName: fields[2] as String,
      type: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MediaModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.keyName)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final typeId = 6;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      username: fields[2] as String,
      email: fields[3] as String,
      bio: fields[4] as String?,
      website: fields[5] as String?,
      verified: fields[6] as bool,
      address: fields[7] as String?,
      protectedAccount: fields[8] as bool,
      joinDate: fields[9] as String,
      profileMediaId: fields[10] as String?,
      profileMedia: fields[11] as MediaModel?,
      coverMediaId: fields[12] as String?,
      coverMedia: fields[13] as MediaModel?,
      followersCount: fields[14] == null ? 0 : (fields[14] as num).toInt(),
      followingCount: fields[15] == null ? 0 : (fields[15] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.website)
      ..writeByte(6)
      ..write(obj.verified)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.protectedAccount)
      ..writeByte(9)
      ..write(obj.joinDate)
      ..writeByte(10)
      ..write(obj.profileMediaId)
      ..writeByte(11)
      ..write(obj.profileMedia)
      ..writeByte(12)
      ..write(obj.coverMediaId)
      ..writeByte(13)
      ..write(obj.coverMedia)
      ..writeByte(14)
      ..write(obj.followersCount)
      ..writeByte(15)
      ..write(obj.followingCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
