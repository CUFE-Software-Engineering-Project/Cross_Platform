class SearchResultModel {
  final String id;
  final String name;
  final String username;
  final bool isVerified;
  final String avatarUrl;

  const SearchResultModel({
    required this.id,
    required this.name,
    required this.username,
    required this.isVerified,
    required this.avatarUrl,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      isVerified: json['isVerified'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
    };
  }

  SearchResultModel copyWith({
    String? id,
    String? name,
    String? username,
    bool? isVerified,
    String? avatarUrl,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
