class ApiConfig {
  /// Base URL for all API endpoints
  static const String baseUrl = "http://abuanpimunflutter.sportsontheweb.net/api/";
  
  /// API endpoints
  static const String getProducts = "${baseUrl}get_products.php";
  static const String addProduct = "${baseUrl}add_product.php";
  static const String updateProduct = "${baseUrl}update_product.php";
  static const String deleteProduct = "${baseUrl}delete_product.php";
  
  static const String getCategories = "${baseUrl}get_categories.php";
  static const String addCategory = "${baseUrl}add_category.php";
  
  static const String login = "${baseUrl}login.php";
  
  static const String addToCart = "${baseUrl}add_to_cart.php";
  static const String getCart = "${baseUrl}get_cart.php";
  static const String removeCartItem = "${baseUrl}remove_cart_item.php";
  
  static const String createOrder = "${baseUrl}create_order.php";
  static const String getOrders = "${baseUrl}get_orders.php";
}