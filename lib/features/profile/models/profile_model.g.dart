// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final typeId = 15;

  @override
  ProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileModel(
      id: fields[0] as String,
      username: fields[1] as String,
      displayName: fields[2] as String,
      bio: fields[3] as String,
      followersCount: (fields[4] as num).toInt(),
      followingCount: (fields[5] as num).toInt(),
      tweetsCount: (fields[6] as num).toInt(),
      isVerified: fields[7] as bool,
      joinedDate: fields[8] as String,
      website: fields[9] as String,
      location: fields[10] as String,
      postCount: (fields[11] as num).toInt(),
      birthDate: fields[12] as String,
      isFollowing: fields[13] as bool,
      isFollower: fields[14] as bool,
      protectedAccount: fields[15] as bool,
      isBlockedByMe: fields[16] as bool,
      isMutedByMe: fields[17] as bool,
      email: fields[18] as String,
      avatarId: fields[19] as String,
      bannerId: fields[20] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.followersCount)
      ..writeByte(5)
      ..write(obj.followingCount)
      ..writeByte(6)
      ..write(obj.tweetsCount)
      ..writeByte(7)
      ..write(obj.isVerified)
      ..writeByte(8)
      ..write(obj.joinedDate)
      ..writeByte(9)
      ..write(obj.website)
      ..writeByte(10)
      ..write(obj.location)
      ..writeByte(11)
      ..write(obj.postCount)
      ..writeByte(12)
      ..write(obj.birthDate)
      ..writeByte(13)
      ..write(obj.isFollowing)
      ..writeByte(14)
      ..write(obj.isFollower)
      ..writeByte(15)
      ..write(obj.protectedAccount)
      ..writeByte(16)
      ..write(obj.isBlockedByMe)
      ..writeByte(17)
      ..write(obj.isMutedByMe)
      ..writeByte(18)
      ..write(obj.email)
      ..writeByte(19)
      ..write(obj.avatarId)
      ..writeByte(20)
      ..write(obj.bannerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
