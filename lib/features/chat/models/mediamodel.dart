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
  String type; // "IMAGE", "VIDEO", "GIF", "FILE"

  @HiveField(3)
  int? size;

  @HiveField(4)
  String? name;

  MediaModel({
    required this.id,
    required this.url,
    required this.type,
    this.size,
    this.name,
  });

  factory MediaModel.fromApiResponse(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      size: json['size'] as int?,
      name: json['name'] as String?,
    );
  }

  MediaModel copyWith({
    String? id,
    String? url,
    String? type,
    int? size,
    String? name,
  }) {
    return MediaModel(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      size: size ?? this.size,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'url': url, 'type': type, 'size': size, 'name': name};
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      size: map['size'] as int?,
      name: map['name'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaModel.fromJson(String source) =>
      MediaModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // Helpers
  bool get isImage => type == 'IMAGE';
  bool get isVideo => type == 'VIDEO';
  bool get isGif => type == 'GIF';
  bool get isFile => type == 'FILE';

  String get sizeInMB {
    if (size == null) return 'Unknown';
    return '${(size! / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get sizeInKB {
    if (size == null) return 'Unknown';
    return '${(size! / 1024).toStringAsFixed(2)} KB';
  }

  String get displaySize {
    if (size == null) return 'Unknown';
    if (size! < 1024) {
      return '$size B';
    } else if (size! < 1024 * 1024) {
      return sizeInKB;
    } else {
      return sizeInMB;
    }
  }

  @override
  String toString() {
    return 'MediaModel(id: $id, type: $type, size: $displaySize)';
  }

  @override
  bool operator ==(covariant MediaModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.url == url;
  }

  @override
  int get hashCode {
    return id.hashCode ^ url.hashCode;
  }
}
