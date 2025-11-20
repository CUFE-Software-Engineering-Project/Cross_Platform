class TrendModel {
  final String id;
  final String title;
  final String? category;
  final String? location;
  final int postCount;
  final String? description;
  final String? imageUrl;
  final bool isHashtag;
  // New fields for enhanced card type
  final String? headline;
  final List<String>? avatarUrls; // List of avatar URLs for overlapping avatars
  final String? timestamp; // e.g., "7 hours ago"

  const TrendModel({
    required this.id,
    required this.title,
    this.category,
    this.location,
    required this.postCount,
    this.description,
    this.imageUrl,
    this.isHashtag = false,
    this.headline,
    this.avatarUrls,
    this.timestamp,
  });

  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'],
      location: json['location'],
      postCount: json['postCount'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      isHashtag: json['isHashtag'] ?? false,
      headline: json['headline'],
      avatarUrls: json['avatarUrls'] != null 
          ? List<String>.from(json['avatarUrls'])
          : null,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
      'postCount': postCount,
      'description': description,
      'imageUrl': imageUrl,
      'isHashtag': isHashtag,
      'headline': headline,
      'avatarUrls': avatarUrls,
      'timestamp': timestamp,
    };
  }

  TrendModel copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    int? postCount,
    String? description,
    String? imageUrl,
    bool? isHashtag,
    String? headline,
    List<String>? avatarUrls,
    String? timestamp,
  }) {
    return TrendModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      postCount: postCount ?? this.postCount,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isHashtag: isHashtag ?? this.isHashtag,
      headline: headline ?? this.headline,
      avatarUrls: avatarUrls ?? this.avatarUrls,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

