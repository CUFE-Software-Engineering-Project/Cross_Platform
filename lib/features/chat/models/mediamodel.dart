// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:hive_ce/hive.dart';
part 'mediamodel.g.dart';

@HiveType(typeId: 3)
class MediaModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String url;
  @HiveField(2)
  String type; // "IMAGE","VIDEO","GIF","FILE"
  @HiveField(3)
  int? size;
  MediaModel({
    required this.id,
    required this.url,
    required this.type,
    this.size,
  });

  MediaModel copyWith({String? id, String? url, String? type, int? size}) {
    return MediaModel(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'url': url, 'type': type, 'size': size};
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      size: map['size'] != null ? map['size'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaModel.fromJson(String source) =>
      MediaModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MediaModel(id: $id, url: $url, type: $type, size: $size)';
  }

  @override
  bool operator ==(covariant MediaModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.url == url &&
        other.type == type &&
        other.size == size;
  }

  @override
  int get hashCode {
    return id.hashCode ^ url.hashCode ^ type.hashCode ^ size.hashCode;
  }
}
