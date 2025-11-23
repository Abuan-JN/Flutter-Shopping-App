import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/auth_config.dart';
import '../config/cors_config.dart';

/// Enhanced Authentication Service with JWT Support and Session Management
class AuthService {
  final http.Client _client;
  final String _baseUrl;
  
  AuthService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;
  
  /// Create a web-compatible HTTP client for browser environments
  http.Client _createWebClient() {
    if (kIsWeb) {
      // For web, we need to use a different approach
      // The default http.Client uses fetch API which has CORS limitations
      // We'll use the same client but with enhanced headers
      log('Using web-compatible HTTP client', name: 'AuthService');
      return _client;
    }
    return _client;
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
  
  /// Enhanced login with JWT token management
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      log('=== LOGIN DEBUG: Starting login process ===', name: 'AuthService');
      log('Email: $email', name: 'AuthService');
      log('Password length: ${password.length}', name: 'AuthService');
      log('Base URL: $_baseUrl', name: 'AuthService');
      log('Login endpoint: ${ApiConfig.login}', name: 'AuthService');
      log('Full URL: $_baseUrl${ApiConfig.login}', name: 'AuthService');
      
      // Debug API configuration
      ApiConfig.debugApiConfig();

      // Validate input
      if (!AuthConfig.validateEmailFormat(email)) {
        log('Email validation failed', name: 'AuthService');
        return {
          'success': false,
          'message': 'Please enter a valid email address',
        };
      }
      
      if (password.length < AuthConfig.minPasswordLength) {
        log('Password validation failed - too short', name: 'AuthService');
        return {
          'success': false,
          'message': 'Password must be at least ${AuthConfig.minPasswordLength} characters long',
        };
      }
      
      log('Input validation passed', name: 'AuthService');
      
      // Check for account lockout
      log('Checking account lockout status', name: 'AuthService');
      final lockoutStatus = await _checkAccountLockout(email);
      if (lockoutStatus['isLocked']) {
        log('Account is locked', name: 'AuthService');
        return {
          'success': false,
          'message': AuthConfig.accountLockedError,
          'data': {
            'timeRemaining': lockoutStatus['timeRemaining'],
          },
        };
      }
      log('Account lockout check passed', name: 'AuthService');
      
      // Prepare request data
      final requestHeaders = {
        ...CorsConfig.getFullHeaders(),
        ...AuthConfig.authHeaders,
        'Content-Type': 'application/json',
      };
      
      final requestBody = {
        'email': email,
        'password': password,
      };
      
      log('=== REQUEST DEBUG ===', name: 'AuthService');
      log('Request URL: $_baseUrl${ApiConfig.login}', name: 'AuthService');
      log('Request method: POST', name: 'AuthService');
      log('Request headers: $requestHeaders', name: 'AuthService');
      log('Request body: $requestBody', name: 'AuthService');
      
      // Make login request
      log('Sending HTTP request...', name: 'AuthService');
      log('Creating HTTP client...', name: 'AuthService');
      
      // Use web-compatible client for browser environments
      final webClient = _createWebClient();
      
      try {
        log('Attempting HTTP request with enhanced client...', name: 'AuthService');
        final response = await webClient.post(
          Uri.parse('$_baseUrl${ApiConfig.login}'),
          headers: requestHeaders,
          body: jsonEncode(requestBody),
        ).timeout(Duration(seconds: 30));
        
        log('HTTP request completed successfully', name: 'AuthService');
        log('Response status: ${response.statusCode}', name: 'AuthService');
        log('Response body length: ${response.body.length}', name: 'AuthService');
        
        // Handle response
        final jsonResponse = _handleAuthResponse(response);
        
        // Close the client if it's a temporary one
        if (webClient != _client) {
          webClient.close();
        }
        
        return jsonResponse;
        
      } catch (e) {
        log('Primary HTTP request failed: $e', name: 'AuthService');
        
        // Fallback: Try with different approach for web
        if (kIsWeb) {
          log('Attempting fallback web request method...', name: 'AuthService');
          
          try {
            // Create a new client with different configuration
            final fallbackClient = http.Client();
            
            // Add additional web-specific headers
            final fallbackHeaders = {
              ...requestHeaders,
              'X-Requested-With': 'XMLHttpRequest',
              'Referer': 'http://abuanplmunflutter.sportsontheweb.net/',
            };
            
            final fallbackResponse = await fallbackClient.post(
              Uri.parse('$_baseUrl${ApiConfig.login}'),
              headers: fallbackHeaders,
              body: jsonEncode(requestBody),
            ).timeout(Duration(seconds: 30));
            
            log('Fallback HTTP request succeeded', name: 'AuthService');
            
            final jsonResponse = _handleAuthResponse(fallbackResponse);
            fallbackClient.close();
            return jsonResponse;
            
          } catch (fallbackError) {
            log('Fallback HTTP request also failed: $fallbackError', name: 'AuthService');
            // Continue to final error handling
          }
        }
        
        // If we reach here, all attempts failed
        rethrow;
      }

    } on TimeoutException catch (e) {
      log('HTTP request timeout error: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Request timeout. Please check your internet connection and try again.',
      };
    } on Exception catch (e) {
      log('HTTP request exception: ${e.toString()}', name: 'AuthService');
      log('Exception type: ${e.runtimeType}', name: 'AuthService');
      log('Exception stack trace: ${StackTrace.current}', name: 'AuthService');
      
      // Check if this is a network-related exception
      if (e.toString().toLowerCase().contains('http') ||
          e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('fetch')) {
        return {
          'success': false,
          'message': 'Network error: ${e.toString()}',
        };
      }
      
      return {
        'success': false,
        'message': 'Unexpected error: ${e.toString()}',
      };
    }
  }
  
  /// Enhanced registration with validation
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    String? confirmPassword,
  }) async {
    try {
      // Validate inputs
      final validationErrors = _validateRegistrationData(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      if (validationErrors.isNotEmpty) {
        return {
          'success': false,
          'message': 'Validation failed',
          'errors': validationErrors,
        };
      }
      
      // Check if email already exists
      final emailCheck = await _checkEmailExists(email);
      if (emailCheck) {
        return {
          'success': false,
          'message': 'An account with this email address already exists',
        };
      }
      
      // Make registration request
      final response = await _client.post(
        Uri.parse('$_baseUrl${ApiConfig.register}'),
        headers: {
          ...CorsConfig.getFullHeaders(),
          ...AuthConfig.authHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'password': password,
        }),
      );
      
      final jsonResponse = _handleAuthResponse(response);
      
      if (jsonResponse['success'] == true) {
        log('User $email registered successfully', name: 'AuthService');
        
        return {
          'success': true,
          'message': 'Registration successful. You can now login with your credentials.',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Registration failed',
        };
      }
      
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Request timeout. Please check your internet connection and try again.',
      };
    } on Exception catch (e) {
      log('Registration error: ${e.toString()}', name: 'AuthService');
      return {
        'success': false,
        'message': 'Registration failed. Please try again later.',
      };
    }
  }
  
  /// Token refresh functionality
  Future<Map<String, dynamic>> refreshToken(String currentToken) async {
    try {
      if (!AuthConfig.validateTokenStructure(currentToken)) {
        return {
          'success': false,
          'message': AuthConfig.invalidTokenError,
        };
      }
      
      final response = await _client.post(
        Uri.parse('$_baseUrl${ApiConfig.refreshToken}'),
        headers: {
          ...CorsConfig.getFullHeaders(),
          ...AuthConfig.authHeaders,
          'Authorization': 'Bearer $currentToken',
        },
      );
      
      final jsonResponse = _handleAuthResponse(response);
      
      if (jsonResponse['success'] == true) {
        final newToken = jsonResponse['data']?['token'];
        if (newToken != null) {
          await _updateToken(newToken);
          
          return {
            'success': true,
            'message': 'Token refreshed successfully',
            'data': {
              'token': newToken,
              'token_expires_in': AuthConfig.tokenExpirationSeconds,
            },
          };
        }
      }
      
      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Token refresh failed',
      };
      
    } on Exception catch (e) {
      log('Token refresh error: ${e.toString()}', name: 'AuthService');
      return {
        'success': false,
        'message': 'Token refresh failed. Please login again.',
      };
    }
  }
  
  /// Logout and clear authentication data
  Future<void> logout() async {
    try {
      // Clear stored authentication data
      await _clearAuthData();
      
      log('User logged out successfully', name: 'AuthService');
    } catch (e) {
      log('Logout error: ${e.toString()}', name: 'AuthService');
    }
  }
  
  /// Check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      final token = await _getStoredToken();
      if (token == null) {
        return false;
      }
      
      return AuthConfig.validateTokenStructure(token);
    } catch (e) {
      log('Auth check error: ${e.toString()}', name: 'AuthService');
      return false;
    }
  }
  
  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userData = await _getStoredUserData();
      return userData;
    } catch (e) {
      log('Get user data error: ${e.toString()}', name: 'AuthService');
      return null;
    }
  }
  
  /// Get current authentication token
  Future<String?> getCurrentToken() async {
    try {
      final token = await _getStoredToken();
      if (token != null && AuthConfig.validateTokenStructure(token)) {
        return token;
      }
      
      // Try to refresh token if expired
      final refreshTokenResult = await refreshToken(token ?? '');
      if (refreshTokenResult['success'] == true) {
        return refreshTokenResult['data']?['token'];
      }
      
      return null;
    } catch (e) {
      log('Get token error: ${e.toString()}', name: 'AuthService');
      return null;
    }
  }
  
  /// Validate current session
  Future<Map<String, dynamic>> validateSession() async {
    try {
      final token = await _getStoredToken();
      final userData = await _getStoredUserData();
      
      if (token == null || userData == null) {
        return {
          'isValid': false,
          'message': 'No active session found',
        };
      }
      
      if (!AuthConfig.validateTokenStructure(token)) {
        return {
          'isValid': false,
          'message': 'Invalid session token',
        };
      }
      
      // Check if token needs refresh
      final tokenPayload = AuthConfig.extractTokenPayload(token);
      if (tokenPayload != null) {
        final needsRefresh = AuthConfig.needsTokenRefresh(
          tokenPayload['iat'] as int,
          tokenPayload['exp'] as int,
        );
        
        return {
          'isValid': true,
          'needsRefresh': needsRefresh,
          'user': userData,
          'tokenTimeRemaining': AuthConfig.getTokenTimeRemaining(
            tokenPayload['exp'] as int,
          ).inSeconds,
        };
      }
      
      return {
        'isValid': true,
        'user': userData,
      };
      
    } catch (e) {
      log('Session validation error: ${e.toString()}', name: 'AuthService');
      return {
        'isValid': false,
        'message': 'Session validation failed',
      };
    }
  }
  
  /// Handle authentication response
  Map<String, dynamic> _handleAuthResponse(http.Response response) {
    try {
      log('=== HANDLE AUTH RESPONSE DEBUG ===', name: 'AuthService');
      log('Response status code: ${response.statusCode}', name: 'AuthService');
      log('Response body: ${response.body}', name: 'AuthService');
      log('Response body length: ${response.body.length}', name: 'AuthService');
      
      final responseBody = response.body;
      
      // Check for empty response
      if (responseBody.isEmpty) {
        log('ERROR: Empty response body received', name: 'AuthService');
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }
      
      // Check for HTML response (common CORS issue)
      if (responseBody.trim().startsWith('<')) {
        log('ERROR: HTML response received instead of JSON', name: 'AuthService');
        log('HTML content preview: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}', name: 'AuthService');
        return {
          'success': false,
          'message': 'Server returned HTML instead of JSON response',
        };
      }
      
      log('Attempting to parse JSON...', name: 'AuthService');
      final jsonResponse = jsonDecode(responseBody);
      log('JSON parsing successful', name: 'AuthService');
      log('Parsed JSON: $jsonResponse', name: 'AuthService');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        log('Status code is successful (${response.statusCode})', name: 'AuthService');
        return jsonResponse;
      } else {
        log('Status code indicates error (${response.statusCode})', name: 'AuthService');
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Authentication failed',
        };
      }
    } on FormatException catch (e) {
      log('ERROR: JSON parsing failed - FormatException: $e', name: 'AuthService');
      log('This usually indicates malformed JSON or server error', name: 'AuthService');
      return {
        'success': false,
        'message': 'Invalid response from server - Failed to parse JSON response',
      };
    } catch (e) {
      log('ERROR: Unexpected exception in _handleAuthResponse: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Unexpected error parsing server response: $e',
      };
    }
  }
  
  /// Validate registration data
  Map<String, String> _validateRegistrationData({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    String? confirmPassword,
  }) {
    final errors = <String, String>{};
    
    // Name validation
    if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters long';
    }
    
    // Email validation
    if (!AuthConfig.validateEmailFormat(email)) {
      errors['email'] = 'Please enter a valid email address';
    }
    
    // Phone validation (Philippine format)
    if (!RegExp(r'^(09|\+639)\d{9}$').hasMatch(phone.replaceAll(' ', ''))) {
      errors['phone'] = 'Please enter a valid Philippine phone number';
    }
    
    // Address validation
    if (address.trim().length < 10) {
      errors['address'] = 'Please enter a complete address (minimum 10 characters)';
    }
    
    // Password validation
    if (!AuthConfig.validatePasswordPolicy(password)) {
      errors['password'] = 'Password must be at least 6 characters with uppercase, lowercase, and number';
    }
    
    // Confirm password validation
    if (confirmPassword != null && confirmPassword != password) {
      errors['confirmPassword'] = 'Passwords do not match';
    }
    
    return errors;
  }
  
  /// Check if email already exists
  Future<bool> _checkEmailExists(String email) async {
    try {
      // This would typically be done via a dedicated API endpoint
      // For now, we'll assume the registration API handles this
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Check account lockout status
  Future<Map<String, dynamic>> _checkAccountLockout(String email) async {
    // Implementation would check stored failed attempts
    // For now, return no lockout
    return {
      'isLocked': false,
      'timeRemaining': 0,
    };
  }
  
  /// Increment failed login attempts
  Future<void> _incrementFailedAttempts(String email) async {
    // Implementation would store failed attempts
  }
  
  /// Reset failed login attempts
  Future<void> _resetFailedAttempts(String email) async {
    // Implementation would clear failed attempts
  }
  
  /// Store authentication data
  Future<void> _storeAuthData(String token, Map<String, dynamic> userData) async {
    // Implementation would use secure storage
    // For now, using simple storage
  }
  
  /// Get stored authentication token
  Future<String?> _getStoredToken() async {
    // Implementation would retrieve from secure storage
    return null;
  }
  
  /// Get stored user data
  Future<Map<String, dynamic>?> _getStoredUserData() async {
    // Implementation would retrieve from secure storage
    return null;
  }
  
  /// Update stored token
  Future<void> _updateToken(String newToken) async {
    // Implementation would update stored token
  }
  
  /// Clear all authentication data
  Future<void> _clearAuthData() async {
    // Implementation would clear all stored auth data
  }
}