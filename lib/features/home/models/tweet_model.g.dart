// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TweetModelAdapter extends TypeAdapter<TweetModel> {
  @override
  final typeId = 0;

  @override
  TweetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TweetModel(
      id: fields[0] as String,
      content: fields[1] as String,
      authorName: fields[2] as String,
      authorUsername: fields[3] as String,
      authorAvatar: fields[4] as String,
      createdAt: fields[5] as DateTime,
      likes: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      retweets: fields[7] == null ? 0 : (fields[7] as num).toInt(),
      replies: fields[8] == null ? 0 : (fields[8] as num).toInt(),
      images: fields[9] == null ? const [] : (fields[9] as List).cast<String>(),
      isLiked: fields[10] == null ? false : fields[10] as bool,
      isRetweeted: fields[11] == null ? false : fields[11] as bool,
      replyToId: fields[12] as String?,
      replyIds: fields[13] == null
          ? const []
          : (fields[13] as List).cast<String>(),
      isBookmarked: fields[14] == null ? false : fields[14] as bool,
      quotedTweetId: fields[15] as String?,
      quotedTweet: fields[16] as TweetModel?,
    );
  }

  @override
  void write(BinaryWriter writer, TweetModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.authorName)
      ..writeByte(3)
      ..write(obj.authorUsername)
      ..writeByte(4)
      ..write(obj.authorAvatar)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.likes)
      ..writeByte(7)
      ..write(obj.retweets)
      ..writeByte(8)
      ..write(obj.replies)
      ..writeByte(9)
      ..write(obj.images)
      ..writeByte(10)
      ..write(obj.isLiked)
      ..writeByte(11)
      ..write(obj.isRetweeted)
      ..writeByte(12)
      ..write(obj.replyToId)
      ..writeByte(13)
      ..write(obj.replyIds)
      ..writeByte(14)
      ..write(obj.isBookmarked)
      ..writeByte(15)
      ..write(obj.quotedTweetId)
      ..writeByte(16)
      ..write(obj.quotedTweet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TweetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
