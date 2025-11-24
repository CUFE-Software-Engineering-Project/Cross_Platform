class ConfirmUploadModel {
  final String id;
  final String name;
  final String keyName;
  final String type;
  final int size;

  ConfirmUploadModel({
    required this.id,
    required this.name,
    required this.keyName,
    required this.type,
    required this.size,
  });

  factory ConfirmUploadModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? media = json['newMedia']?? null;
    return ConfirmUploadModel(
      id: media!=null ? media['id']??"": "",
      name: media != null ? media['name'] ?? "" : "",
      keyName: media != null ? media['keyName'] ?? "" : "",
      type: media != null ? media['type'] ?? "" : "",
      size: media != null ? media['size'] ?? 0 : 0,
    );
  }
}
