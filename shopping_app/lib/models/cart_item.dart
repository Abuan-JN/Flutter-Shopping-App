class CartItem {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final String createdAt;
  
  // Additional fields for display purposes
  final String productName;
  final String productImage;
  final double productPrice;
  final int productStock;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productStock,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      createdAt: json['created_at'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      productPrice: double.parse(json['product_price'].toString()),
      productStock: json['product_stock'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
        'created_at': createdAt,
        'product_name': productName,
        'product_image': productImage,
        'product_price': productPrice,
        'product_stock': productStock,
      };

  double get totalPrice => productPrice * quantity;

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, quantity: $quantity, totalPrice: $totalPrice)';
  }
}