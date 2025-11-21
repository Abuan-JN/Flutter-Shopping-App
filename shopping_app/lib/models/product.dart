class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String categoryName;
  final String image;
  final int stock;
  final bool isActive;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.image,
    required this.stock,
    required this.isActive,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: double.parse(json['price'].toString()),
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      image: json['image'] as String,
      stock: json['stock'] as int,
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'category_name': categoryName,
        'image': image,
        'stock': stock,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt,
      };

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stock)';
  }
}