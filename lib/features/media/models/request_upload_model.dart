class RequestUploadModel {
  final String url;
  final String keyName;

  RequestUploadModel({required this.url, required this.keyName});

  // From JSON
  factory RequestUploadModel.fromJson(Map<String, dynamic> json) {
    return RequestUploadModel(
      url: json['url'] ?? "",
      keyName: json['keyName']?? "",
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {'url': url, 'keyName': keyName};
  }
}
