class Category {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final String createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt,
      };

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}