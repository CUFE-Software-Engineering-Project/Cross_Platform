// coverage:ignore-file
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
      quotes: fields[17] == null ? 0 : (fields[17] as num).toInt(),
      bookmarks: fields[18] == null ? 0 : (fields[18] as num).toInt(),
      userId: fields[19] as String?,
      tweetType: fields[20] == null ? 'TWEET' : fields[20] as String,
      isVerified: fields[21] == null ? false : fields[21] as bool,
      isProtected: fields[22] == null ? false : fields[22] as bool,
      recommendationScore: (fields[23] as num?)?.toDouble(),
      recommendationReasons: fields[24] == null
          ? const []
          : (fields[24] as List).cast<String>(),
      replyControl: fields[25] == null ? 'EVERYONE' : fields[25] as String,
      isFollowed: fields[26] == null ? false : fields[26] as bool,
      hashtags: fields[27] == null
          ? const []
          : (fields[27] as List).cast<TweetHashtag>(),
      categories: fields[28] == null
          ? const []
          : (fields[28] as List).cast<String>(),
      retweetedByUsernames: fields[29] == null
          ? const []
          : (fields[29] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TweetModel obj) {
    writer
      ..writeByte(30)
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
      ..write(obj.quotedTweet)
      ..writeByte(17)
      ..write(obj.quotes)
      ..writeByte(18)
      ..write(obj.bookmarks)
      ..writeByte(19)
      ..write(obj.userId)
      ..writeByte(20)
      ..write(obj.tweetType)
      ..writeByte(21)
      ..write(obj.isVerified)
      ..writeByte(22)
      ..write(obj.isProtected)
      ..writeByte(23)
      ..write(obj.recommendationScore)
      ..writeByte(24)
      ..write(obj.recommendationReasons)
      ..writeByte(25)
      ..write(obj.replyControl)
      ..writeByte(26)
      ..write(obj.isFollowed)
      ..writeByte(27)
      ..write(obj.hashtags)
      ..writeByte(28)
      ..write(obj.categories)
      ..writeByte(29)
      ..write(obj.retweetedByUsernames);
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

class TweetHashtagAdapter extends TypeAdapter<TweetHashtag> {
  @override
  final typeId = 7;

  @override
  TweetHashtag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TweetHashtag(id: fields[0] as String, tagText: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, TweetHashtag obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tagText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TweetHashtagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
