class ApiConfig {
  /// Base URL for all API endpoints
  static const String baseUrl = "http://abuanplmunflutter.sportsontheweb.net/api/";
  
  /// Customer API endpoints
  static const String getProducts = "${baseUrl}get_products.php";
  static const String getCategories = "${baseUrl}get_categories.php";
  static const String login = "${baseUrl}login.php";
  static const String register = "${baseUrl}register.php";
  static const String refreshToken = "${baseUrl}refresh_token.php";
  static const String addToCart = "${baseUrl}add_to_cart.php";
  static const String getCart = "${baseUrl}get_cart.php";
  static const String removeCartItem = "${baseUrl}remove_cart_item.php";
  static const String createOrder = "${baseUrl}create_order.php";
  static const String getOrders = "${baseUrl}get_orders.php";
  
  /// Admin API endpoints (for web interface)
  static const String adminLogin = "${baseUrl}admin_login.php";
  static const String addProduct = "${baseUrl}add_product.php";
  static const String updateProduct = "${baseUrl}update_product.php";
  static const String deleteProduct = "${baseUrl}delete_product.php";
  static const String addCategory = "${baseUrl}add_category.php";
  static const String updateCategory = "${baseUrl}update_category.php";
  static const String deleteCategory = "${baseUrl}delete_category.php";
  static const String getUsers = "${baseUrl}get_users.php";
  static const String updateUser = "${baseUrl}update_user.php";
  static const String deleteUser = "${baseUrl}delete_user.php";
  static const String updateOrder = "${baseUrl}update_order.php";
}