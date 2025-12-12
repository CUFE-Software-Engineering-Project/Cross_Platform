class ExploreCategory {
  final String id;
  final String name;

  ExploreCategory({required this.id, required this.name});

  factory ExploreCategory.fromMap(Map<String, dynamic> map) {
    return ExploreCategory(id: map["id"], name: map["name"]);
  }
}
