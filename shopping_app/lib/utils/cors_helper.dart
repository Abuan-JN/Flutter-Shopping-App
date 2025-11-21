import 'dart:developer';

/// Utility class for handling CORS-related operations and debugging
class CorsHelper {
  
  /// Enhanced headers for CORS requests
  static Map<String, String> get corsHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'http://abuanplmunflutter.sportsontheweb.net',
        'User-Agent': 'Flutter-App/1.0',
        'X-Requested-With': 'XMLHttpRequest',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      };

  /// Debug CORS-related issues
  static void debugCorsIssue(String endpoint, Map<String, String> headers) {
    log('CORS Debug Information:', name: 'CorsHelper');
    log('Endpoint: $endpoint', name: 'CorsHelper');
    log('Headers: $headers', name: 'CorsHelper');
    log('Origin Header: ${headers['Origin']}', name: 'CorsHelper');
    log('Content-Type: ${headers['Content-Type']}', name: 'CorsHelper');
    log('X-Requested-With: ${headers['X-Requested-With']}', name: 'CorsHelper');
  }

  /// Validate CORS configuration
  static bool validateCorsConfiguration(Map<String, String> headers) {
    final requiredHeaders = [
      'Content-Type',
      'Origin',
      'X-Requested-With'
    ];
    
    for (final header in requiredHeaders) {
      if (!headers.containsKey(header)) {
        log('Missing required header: $header', name: 'CorsHelper');
        return false;
      }
    }
    
    return true;
  }

  /// Handle CORS error response
  static String handleCorsError(Object error) {
    if (error.toString().contains('CORS')) {
      return 'CORS error: Please ensure the server allows cross-origin requests from your Flutter app domain.';
    }
    if (error.toString().contains('Network')) {
      return 'Network error: Please check your internet connection and ensure the API server is accessible.';
    }
    return 'Request failed: $error';
  }
}