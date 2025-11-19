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
      isDMChat: fields[1] as bool,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      groupName: fields[4] as String?,
      groupPhotoKey: fields[5] as String?,
      groupDescription: fields[6] as String?,
      participantIds: (fields[7] as List).cast<String>(),
      lastMessageContent: fields[8] as String?,
      lastMessageTime: fields[9] as DateTime?,
      lastMessageSenderId: fields[10] as String?,
      unseenCount: fields[11] == null ? 0 : (fields[11] as num).toInt(),
      dmPartnerUserId: fields[12] as String?,
      dmPartnerName: fields[13] as String?,
      dmPartnerUsername: fields[14] as String?,
      dmPartnerProfileKey: fields[15] as String?,
      lastMessageType: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isDMChat)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.groupName)
      ..writeByte(5)
      ..write(obj.groupPhotoKey)
      ..writeByte(6)
      ..write(obj.groupDescription)
      ..writeByte(7)
      ..write(obj.participantIds)
      ..writeByte(8)
      ..write(obj.lastMessageContent)
      ..writeByte(9)
      ..write(obj.lastMessageTime)
      ..writeByte(10)
      ..write(obj.lastMessageSenderId)
      ..writeByte(11)
      ..write(obj.unseenCount)
      ..writeByte(12)
      ..write(obj.dmPartnerUserId)
      ..writeByte(13)
      ..write(obj.dmPartnerName)
      ..writeByte(14)
      ..write(obj.dmPartnerUsername)
      ..writeByte(15)
      ..write(obj.dmPartnerProfileKey)
      ..writeByte(16)
      ..write(obj.lastMessageType);
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
