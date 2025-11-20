// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messagemodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final typeId = 2;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      chatId: fields[1] as String,
      userId: fields[2] as String,
      content: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      status: fields[5] == null ? 'PENDING' : fields[5] as String,
      media: (fields[6] as List?)?.cast<MediaModel>(),
      senderUsername: fields[7] as String?,
      senderName: fields[8] as String?,
      senderProfileMediaKey: fields[9] as String?,
      messageType: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.media)
      ..writeByte(7)
      ..write(obj.senderUsername)
      ..writeByte(8)
      ..write(obj.senderName)
      ..writeByte(9)
      ..write(obj.senderProfileMediaKey)
      ..writeByte(10)
      ..write(obj.messageType)
      ..writeByte(11);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
