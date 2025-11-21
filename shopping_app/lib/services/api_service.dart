import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/cors_config.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../utils/cors_helper.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Headers for API requests with CORS support
  Map<String, String> get _headers => CorsConfig.getFullHeaders();
  
  /// Auth-specific headers
  Map<String, String> get _authHeaders => CorsConfig.getFullHeaders(includeAuthHeaders: true);

  /// Generic method to handle API responses
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final String responseBody = response.body;
    
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse;
      } else {
        throw Exception('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } on FormatException {
      throw Exception('Failed to parse API response');
    } on Exception catch (e) {
      final errorMessage = CorsHelper.handleCorsError(e);
      throw Exception(errorMessage);
    }
  }

  /// Fetch all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.getProducts),
        headers: _headers,
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> productsJson = jsonResponse['data'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load products');
      }
    } on Exception {
      rethrow;
    }
  }

  /// Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.getCategories),
        headers: _headers,
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> categoriesJson = jsonResponse['data'];
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load categories');
      }
    } on Exception {
      rethrow;
    }
  }

  /// Admin login with enhanced CORS support
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      CorsHelper.debugCorsIssue(ApiConfig.login, _authHeaders);
      
      if (!CorsHelper.validateCorsConfiguration(_authHeaders)) {
        throw Exception('Invalid CORS configuration');
      }
      
      final response = await _client.post(
        Uri.parse(ApiConfig.login),
        headers: _authHeaders,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Login successful',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Login failed',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Add product to cart
  Future<Map<String, dynamic>> addToCart(int userId, int productId, int quantity) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.addToCart),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Added to cart successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to add to cart',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Get cart items for user
  Future<List<CartItem>> getCartItems(int userId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.getCart}?user_id=$userId'),
        headers: _headers,
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> cartItemsJson = jsonResponse['data'];
        return cartItemsJson.map((json) => CartItem.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load cart items');
      }
    } on Exception {
      rethrow;
    }
  }

  /// Remove item from cart
  Future<Map<String, dynamic>> removeCartItem(int cartItemId) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.removeCartItem),
        headers: _headers,
        body: jsonEncode({
          'cart_item_id': cartItemId,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Item removed from cart',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to remove item from cart',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Create order
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.createOrder),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'customer_address': customerAddress,
          'total_amount': totalAmount,
          'items': items,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Order created successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to create order',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Get orders for user
  Future<List<Order>> getOrders(int userId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.getOrders}?user_id=$userId'),
        headers: _headers,
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> ordersJson = jsonResponse['data'];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load orders');
      }
    } on Exception {
      rethrow;
    }
  }

  /// Add new product (admin)
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required String image,
    required int stock,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.addProduct),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'category_id': categoryId,
          'image': image,
          'stock': stock,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Product added successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to add product',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Update existing product (admin)
  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required String image,
    required int stock,
    required bool isActive,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.updateProduct),
        headers: _headers,
        body: jsonEncode({
          'id': productId,
          'name': name,
          'description': description,
          'price': price,
          'category_id': categoryId,
          'image': image,
          'stock': stock,
          'is_active': isActive ? 1 : 0,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Product updated successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to update product',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Delete product (admin)
  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.deleteProduct),
        headers: _headers,
        body: jsonEncode({
          'id': productId,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Product deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to delete product',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Add new category (admin)
  Future<Map<String, dynamic>> addCategory({
    required String name,
    required String description,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.addCategory),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Category added successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to add category',
        };
      }
    } on Exception {
      rethrow;
    }
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}