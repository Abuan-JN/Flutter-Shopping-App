/// CORS Configuration for Flutter Shopping App
/// 
/// This file contains centralized CORS configuration constants and settings
/// used throughout the application to ensure proper cross-origin requests.

class CorsConfig {
  /// Base URL for the API
  static const String baseUrl = "http://abuanplmunflutter.sportsontheweb.net";
  
  /// Allowed origins for CORS requests
  static const List<String> allowedOrigins = [
    baseUrl,
    "https://$baseUrl",
    "http://localhost",
    "https://localhost",
    "capacitor://localhost",
    "ionic://localhost",
    "http://127.0.0.1",
    "https://127.0.0.1",
    "file://",
    "app://",
  ];
  
  /// Required headers for CORS requests
  static const Map<String, String> requiredHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-App/1.0',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
  };
  
  /// Additional headers for authentication requests
  static const Map<String, String> authHeaders = {
    'X-Requested-With': 'XMLHttpRequest',
    'Origin': baseUrl,
  };
  
  /// Timeout for CORS requests in milliseconds
  static const int requestTimeout = 30000; // 30 seconds
  
  /// Maximum retry attempts for failed CORS requests
  static const int maxRetries = 3;
  
  /// Delay between retry attempts in milliseconds
  static const int retryDelay = 1000; // 1 second
  
  /// CORS error messages
  static const String corsErrorMessage = 
    'CORS error: The server at ${baseUrl} is not allowing cross-origin requests. '
    'Please contact the administrator to resolve this issue.';
  
  static const String networkErrorMessage = 
    'Network error: Please check your internet connection and ensure the API server is accessible.';
  
  static const String timeoutErrorMessage = 
    'Request timeout: The server is taking too long to respond. Please try again later.';
  
  /// Validate if an origin is allowed
  static bool isOriginAllowed(String? origin) {
    if (origin == null || origin.isEmpty) return false;
    return allowedOrigins.contains(origin);
  }
  
  /// Get full headers for API requests
  static Map<String, String> getFullHeaders({bool includeAuthHeaders = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter-App/1.0',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      'Origin': baseUrl,
      // Web-specific CORS headers
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With, Origin, Accept, Cache-Control, Pragma, DNT, Sec-Fetch-Mode',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Expose-Headers': 'Content-Length, Content-Type, Access-Control-Allow-Origin',
      'DNT': '1',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Dest': 'empty',
    };
    
    if (includeAuthHeaders) {
      headers.addAll(authHeaders);
    }
    
    // Debug logging for CORS issues
    print('=== CORS CONFIG DEBUG ===');
    print('Base URL: $baseUrl');
    print('Required headers: $requiredHeaders');
    print('Auth headers: $authHeaders');
    print('Include auth headers: $includeAuthHeaders');
    print('Final headers: $headers');
    
    return headers;
  }
}