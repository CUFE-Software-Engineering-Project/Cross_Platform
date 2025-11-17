// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_ce/hive.dart';

part 'mediamodel.g.dart';

@HiveType(typeId: 3)
class MediaModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String keyName;

  @HiveField(2)
  String type; // "IMAGE", "VIDEO", "GIF", "FILE"

  @HiveField(3)
  int? size;

  @HiveField(4)
  String? name;

  MediaModel({
    required this.id,
    required this.keyName,
    required this.type,
    this.size,
    this.name,
  });

  factory MediaModel.fromApiResponse(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      keyName: json['keyName'] as String,
      type: json['type'] as String,
      size: json['size'] as int?,
      name: json['name'] as String?,
    );
  }
  Map<String, dynamic> toApiRequest() {
    return {'keyName': keyName, 'type': type, 'size': size, 'name': name};
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'keyName': keyName,
      'type': type,
      'size': size,
      'name': name,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'] as String,
      keyName: map['keyName'] as String,
      type: map['type'] as String,
      size: map['size'] != null ? map['size'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
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
    return 'MediaModel(id: $id, keyName: $keyName, type: $type, size: $size, name: $name)';
  }

  @override
  bool operator ==(covariant MediaModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.keyName == keyName &&
        other.type == type &&
        other.size == size &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        keyName.hashCode ^
        type.hashCode ^
        size.hashCode ^
        name.hashCode;
  }

  MediaModel copyWith({
    String? id,
    String? keyName,
    String? type,
    int? size,
    String? name,
  }) {
    return MediaModel(
      id: id ?? this.id,
      keyName: keyName ?? this.keyName,
      type: type ?? this.type,
      size: size ?? this.size,
      name: name ?? this.name,
    );
  }
}
