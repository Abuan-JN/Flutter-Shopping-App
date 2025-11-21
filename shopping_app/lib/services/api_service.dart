import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/cors_config.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
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
        throw FormatException(jsonResponse['message'] ?? 'Unknown error');
      }
    } on FormatException catch (e) {
      final errorMessage = CorsHelper.handleCorsError(e);
      throw FormatException(errorMessage);
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
        throw FormatException(jsonResponse['message'] ?? 'Failed to load products');
      }
    } on FormatException {
      rethrow;
    }
  }

  /// Fetch all categories
  Future<List<models.Category>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.getCategories),
        headers: _headers,
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> categoriesJson = jsonResponse['data'];
        return categoriesJson.map((json) => models.Category.fromJson(json)).toList();
      } else {
        throw FormatException(jsonResponse['message'] ?? 'Failed to load categories');
      }
    } on FormatException {
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
    } on FormatException {
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
    } on FormatException {
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
    } on FormatException {
      rethrow;
    }
  }

  /// Add product to cart
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
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
          'message': jsonResponse['message'] ?? 'Product added to cart successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to add product to cart',
        };
      }
    } on FormatException {
      rethrow;
    }
  }

  /// Get cart items for user
  Future<List<CartItem>> getCartItems(int userId) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.getCart),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> cartItemsJson = jsonResponse['data'];
        return cartItemsJson.map((json) => CartItem.fromJson(json)).toList();
      } else {
        throw FormatException(jsonResponse['message'] ?? 'Failed to load cart items');
      }
    } on FormatException {
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
          'id': cartItemId,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Item removed from cart successfully',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Failed to remove item from cart',
        };
      }
    } on FormatException {
      rethrow;
    }
  }

  /// Create order from cart
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required String customerName,
    required String customerAddress,
    required String customerPhone,
    required String paymentMethod,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.createOrder),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'customer_name': customerName,
          'customer_address': customerAddress,
          'customer_phone': customerPhone,
          'payment_method': paymentMethod,
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
    } on FormatException {
      rethrow;
    }
  }

  /// Get orders for user
  Future<List<Order>> getOrders(int userId) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.getOrders),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
        }),
      );
      
      final jsonResponse = await _handleResponse(response);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> ordersJson = jsonResponse['data'];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw FormatException(jsonResponse['message'] ?? 'Failed to load orders');
      }
    } on FormatException {
      rethrow;
    }
  }

  /// Admin login with enhanced CORS support
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      CorsHelper.debugCorsIssue(ApiConfig.login, _authHeaders);
      
      if (!CorsHelper.validateCorsConfiguration(_authHeaders)) {
        throw FormatException('Invalid CORS configuration');
      }
      
      // Create a new client with longer timeout for authentication
      final authClient = http.Client();
      
      final response = await authClient.post(
        Uri.parse(ApiConfig.login),
        headers: {
          ..._authHeaders,
          'Origin': CorsConfig.baseUrl,
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      // Log the response status for debugging
      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');
      
      // Close the client to prevent memory leaks
      authClient.close();
      
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
    } on FormatException {
      rethrow;
    }
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}