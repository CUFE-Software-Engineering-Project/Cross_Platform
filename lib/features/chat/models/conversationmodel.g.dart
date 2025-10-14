// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversationmodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationModelAdapter extends TypeAdapter<ConversationModel> {
  @override
  final typeId = 1;

  @override
  ConversationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationModel(
      id: fields[0] as String,
      isGroup: fields[1] as bool,
      name: fields[2] as String?,
      photo: fields[3] as String?,
      participants: (fields[4] as List).cast<UserModel>(),
      lastMessageId: fields[5] as String?,
      unseenCount: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isGroup)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.photo)
      ..writeByte(4)
      ..write(obj.participants)
      ..writeByte(5)
      ..write(obj.lastMessageId)
      ..writeByte(6)
      ..write(obj.unseenCount)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
