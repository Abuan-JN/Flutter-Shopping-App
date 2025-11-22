class Order {
  final int id;
  final int userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final double totalAmount;
  final String status;
  final String createdAt;
  
  // List of order items
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle items field that might come as a Map instead of List
    List<OrderItem> items = [];
    if (json['items'] != null) {
      if (json['items'] is List) {
        // Normal case - items is a List
        var itemsList = json['items'] as List;
        items = itemsList.map((i) => OrderItem.fromJson(i)).toList();
      } else if (json['items'] is Map) {
        // Handle case where items is a single Map object
        var itemMap = json['items'] as Map<String, dynamic>;
        items = [OrderItem.fromJson(itemMap)];
      }
    }

    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String,
      customerAddress: json['customer_address'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'total_amount': totalAmount,
        'status': status,
        'created_at': createdAt,
        'items': items.map((item) => item.toJson()).toList(),
      };

  @override
  String toString() {
    return 'Order(id: $id, customer: $customerName, total: $totalAmount, status: $status)';
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  
  // Additional fields for display purposes
  final String productName;
  final String productImage;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: double.parse(json['price'].toString()),
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
        'product_name': productName,
        'product_image': productImage,
      };

  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'OrderItem(id: $id, productName: $productName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}