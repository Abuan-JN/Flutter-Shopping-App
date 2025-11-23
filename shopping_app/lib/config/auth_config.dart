import 'dart:convert';

/// Authentication Configuration for Flutter Shopping App
/// 
/// This file contains centralized authentication constants and settings
/// used throughout the application for secure user authentication.

class AuthConfig {
  /// Token expiration time in seconds (24 hours)
  static const int tokenExpirationSeconds = 86400;
  
  /// Minimum password length for user registration
  static const int minPasswordLength = 6;
  
  /// Maximum login attempts before temporary lockout
  static const int maxLoginAttempts = 5;
  
  /// Lockout duration in minutes after max attempts
  static const int lockoutDurationMinutes = 15;
  
  /// Refresh token threshold (refresh when 80% of token life remains)
  static const double refreshTokenThreshold = 0.8;
  
  /// JWT Token storage key
  static const String tokenStorageKey = 'user_auth_token';
  
  /// User data storage key
  static const String userDataStorageKey = 'user_data';
  
  /// Remember me storage key
  static const String rememberMeStorageKey = 'remember_me';
  
  /// Last login timestamp storage key
  static const String lastLoginStorageKey = 'last_login_time';
  
  /// Failed login attempts storage key
  static const String failedAttemptsStorageKey = 'failed_login_attempts';
  
  /// Lockout expiration storage key
  static const String lockoutExpirationStorageKey = 'lockout_expiration';
  
  /// Token validation patterns
  static const Map<String, String> tokenValidationPatterns = {
    'jwt': r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$',
    'simple': r'^[a-f0-9]{64}$', // 32 bytes hex
  };
  
  /// Required token claims for validation
  static const List<String> requiredTokenClaims = [
    'exp', // Expiration time
    'iat', // Issued at
    'sub', // Subject (user ID)
    'email', // User email
  ];
  
  /// Authentication error messages
  static const String invalidTokenError = 'Invalid authentication token';
  static const String expiredTokenError = 'Authentication token has expired';
  static const String missingClaimsError = 'Token missing required claims';
  static const String invalidCredentialsError = 'Invalid email or password';
  static const String accountLockedError = 'Account temporarily locked due to multiple failed attempts';
  static const String sessionExpiredError = 'Session expired. Please login again';
  static const String networkAuthError = 'Authentication failed. Please check your internet connection';
  
  /// Security headers for authentication requests
  static const Map<String, String> authHeaders = {
    'X-Auth-Version': '1.0',
    'X-Client-Version': '1.0.0',
    'X-Request-Origin': 'flutter_app',
  };
  
  /// Password policy requirements
  static const Map<String, dynamic> passwordPolicy = {
    'minLength': 6,
    'requireUppercase': true,
    'requireLowercase': true,
    'requireNumbers': true,
    'requireSpecialChars': false,
    'maxLength': 128,
  };
  
  /// Email validation pattern
  static const String emailValidationPattern = 
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  /// Validate if a password meets policy requirements
  static bool validatePasswordPolicy(String password) {
    if (password.length < passwordPolicy['minLength']) {
      return false;
    }
    
    if (password.length > passwordPolicy['maxLength']) {
      return false;
    }
    
    if (passwordPolicy['requireUppercase'] && !password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }
    
    if (passwordPolicy['requireLowercase'] && !password.contains(RegExp(r'[a-z]'))) {
      return false;
    }
    
    if (passwordPolicy['requireNumbers'] && !password.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    
    return true;
  }
  
  /// Validate email format
  static bool validateEmailFormat(String email) {
    return RegExp(emailValidationPattern).hasMatch(email);
  }
  
  /// Check if token is expired based on expiration timestamp
  static bool isTokenExpired(int expirationTimestamp) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expirationTimestamp < currentTimestamp;
  }
  
  /// Calculate time remaining before token expires
  static Duration getTokenTimeRemaining(int expirationTimestamp) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final secondsRemaining = expirationTimestamp - currentTimestamp;
    
    if (secondsRemaining <= 0) {
      return Duration.zero;
    }
    
    return Duration(seconds: secondsRemaining);
  }
  
  /// Check if token needs refresh based on threshold
  static bool needsTokenRefresh(int issuedAtTimestamp, int expirationTimestamp) {
    final tokenLifespan = expirationTimestamp - issuedAtTimestamp;
    final timeSinceIssued = DateTime.now().millisecondsSinceEpoch ~/ 1000 - issuedAtTimestamp;
    
    return timeSinceIssued > (tokenLifespan * refreshTokenThreshold);
  }
  
  /// Extract user information from JWT token payload
  /// For simple hex tokens, returns basic token info
  static Map<String, dynamic>? extractTokenPayload(String token) {
    try {
      // Handle simple hex tokens (return basic info)
      if (token.length >= 32 && token.length <= 64 && RegExp(r'^[a-f0-9]+$').hasMatch(token)) {
        return {
          'token_type': 'simple_hex',
          'token_length': token.length,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600, // 1 hour from now
        };
      }
      
      // Handle JWT tokens (original logic)
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      // Decode base64Url payload
      final payload = parts[1];
      final normalizedPayload = payload.length % 4 == 0
          ? payload
          : payload.padRight(payload.length + (4 - payload.length % 4), '=');
      
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedPayload = String.fromCharCodes(decodedBytes);
      
      return jsonDecode(decodedPayload);
    } on FormatException {
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Validate token structure and required claims
  static bool validateTokenStructure(String token) {
    if (token.isEmpty) {
      return false;
    }
    
    // Accept simple hex tokens (32-64 characters) generated by the server
    if (token.length >= 32 && token.length <= 64 && RegExp(r'^[a-f0-9]+$').hasMatch(token)) {
      return true; // Simple hex token is valid
    }
    
    // Check if token matches JWT pattern (for backward compatibility)
    if (RegExp(tokenValidationPatterns['jwt']!).hasMatch(token)) {
      // Extract and validate payload for JWT tokens
      final payload = extractTokenPayload(token);
      if (payload == null) {
        return false;
      }
      
      // Check required claims
      for (final claim in requiredTokenClaims) {
        if (!payload.containsKey(claim)) {
          return false;
        }
      }
      
      // Check expiration
      final exp = payload['exp'] as int?;
      if (exp == null || isTokenExpired(exp)) {
        return false;
      }
      
      return true;
    }
    
    return false; // Token doesn't match any valid pattern
  }
  
  /// Generate secure token for development/testing purposes
  static String generateTestToken(Map<String, dynamic> userData) {
    final now = DateTime.now();
    final expiration = now.add(Duration(seconds: tokenExpirationSeconds));
    
    final header = jsonEncode({
      'alg': 'HS256',
      'typ': 'JWT',
    });
    
    final payload = jsonEncode({
      'sub': userData['id'] ?? 1,
      'email': userData['email'] ?? '',
      'name': userData['name'] ?? '',
      'role': userData['role'] ?? 'customer',
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiration.millisecondsSinceEpoch ~/ 1000,
    });
    
    // Simple base64 encoding for development (not cryptographically secure)
    final headerBase64 = base64Url.encode(utf8.encode(header));
    final payloadBase64 = base64Url.encode(utf8.encode(payload));
    
    return '$headerBase64.$payloadBase64.test_signature';
  }
}