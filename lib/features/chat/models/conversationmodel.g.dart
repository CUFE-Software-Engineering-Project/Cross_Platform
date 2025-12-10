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
      participantIds: (fields[4] as List).cast<String>(),
      lastMessageContent: fields[5] as String?,
      lastMessageTime: fields[6] as DateTime?,
      lastMessageSenderId: fields[7] as String?,
      unseenCount: fields[8] == null ? 1 : (fields[8] as num).toInt(),
      dmPartnerUserId: fields[9] as String?,
      dmPartnerName: fields[10] as String?,
      dmPartnerUsername: fields[11] as String?,
      dmPartnerProfileKey: fields[12] as String?,
      lastMessageType: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isDMChat)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.participantIds)
      ..writeByte(5)
      ..write(obj.lastMessageContent)
      ..writeByte(6)
      ..write(obj.lastMessageTime)
      ..writeByte(7)
      ..write(obj.lastMessageSenderId)
      ..writeByte(8)
      ..write(obj.unseenCount)
      ..writeByte(9)
      ..write(obj.dmPartnerUserId)
      ..writeByte(10)
      ..write(obj.dmPartnerName)
      ..writeByte(11)
      ..write(obj.dmPartnerUsername)
      ..writeByte(12)
      ..write(obj.dmPartnerProfileKey)
      ..writeByte(13)
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
