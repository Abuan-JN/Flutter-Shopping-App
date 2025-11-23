import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/auth_config.dart';
import '../config/api_config.dart';

/// Enhanced Authentication Provider with JWT Token Management and Session Control
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final String _baseUrl;
  
  // Authentication state
  bool _isUserLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userToken;
  Map<String, dynamic>? _currentUser;
  
  // Session management
  Timer? _sessionTimer;
  int _sessionTimeoutSeconds = 300; // 5 minutes of inactivity
  DateTime? _lastActivityTime;
  
  // Biometric authentication
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  
  AuthProvider({
    AuthService? authService,
    String? baseUrl,
  })  : _authService = authService ?? AuthService(baseUrl: baseUrl),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl {
    // Initialize authentication state
    _initializeAuthState();
  }
  
  // Getters
  bool get isUserLoggedIn => _isUserLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userToken => _userToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  
  /// Initialize authentication state from stored data
  Future<void> _initializeAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Check if user has valid session
      final sessionResult = await _authService.validateSession();
      
      if (sessionResult['isValid'] == true) {
        _isUserLoggedIn = true;
        _currentUser = sessionResult['user'];
        
        // Start session timer if needed
        if (sessionResult['needsRefresh'] == true) {
          _startSessionTimer(sessionResult['tokenTimeRemaining'] ?? 0);
        }
        
        // Get current token
        _userToken = await _authService.getCurrentToken();
      } else {
        _isUserLoggedIn = false;
        _userToken = null;
        _currentUser = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Auth initialization error: ${e.toString()}', name: 'AuthProvider');
      _isLoading = false;
      _isUserLoggedIn = false;
      _errorMessage = 'Failed to initialize authentication';
      notifyListeners();
    }
  }
  
  /// Enhanced login with comprehensive validation and error handling
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (_isLoading) {
      return {
        'success': false,
        'message': 'Please wait for the current operation to complete',
      };
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      log('=== AUTH PROVIDER LOGIN DEBUG ===', name: 'AuthProvider');
      log('Starting login process with email: $email', name: 'AuthProvider');
      log('AuthService instance: $_authService', name: 'AuthProvider');
      
      final result = await _authService.login(email, password);
      
      log('=== AUTH PROVIDER RESULT DEBUG ===', name: 'AuthProvider');
      log('Login result: $result', name: 'AuthProvider');
      log('Result success: ${result['success']}', name: 'AuthProvider');
      log('Result message: ${result['message']}', name: 'AuthProvider');
      
      if (result['success'] == true) {
        log('Processing successful login...', name: 'AuthProvider');
        _isUserLoggedIn = true;
        _errorMessage = null;
        _userToken = result['data']?['token'];
        _currentUser = result['data']?['user'];
        
        log('User token: $_userToken', name: 'AuthProvider');
        log('User data: $_currentUser', name: 'AuthProvider');
        
        // Track last activity
        _lastActivityTime = DateTime.now();
        
        // Start session timer
        _startSessionTimer(result['data']?['token_expires_in'] ?? 0);
        
        // Clear any existing session timer
        _sessionTimer?.cancel();
        
        log('User ${_currentUser?['email']} logged in successfully', name: 'AuthProvider');
        
        notifyListeners();
        
        return {
          'success': true,
          'message': result['message'] ?? 'Login successful',
          'data': result['data'],
        };
      } else {
        log('Processing failed login...', name: 'AuthProvider');
        _errorMessage = result['message'];
        _isUserLoggedIn = false;
        _userToken = null;
        _currentUser = null;
        
        log('Error message: $_errorMessage', name: 'AuthProvider');
        
        notifyListeners();
        
        return {
          'success': false,
          'message': result['message'],
        };
      }
      
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _isUserLoggedIn = false;
      _userToken = null;
      _currentUser = null;
      
      log('Login exception: ${e.toString()}', name: 'AuthProvider');
      notifyListeners();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
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
    if (_isLoading) {
      return {
        'success': false,
        'message': 'Please wait for the current operation to complete',
      };
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      if (result['success'] == true) {
        _errorMessage = null;
        notifyListeners();
        
        return {
          'success': true,
          'message': result['message'] ?? 'Registration successful',
          'data': result['data'],
        };
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        
        return {
          'success': false,
          'message': result['message'],
          'errors': result['errors'],
        };
      }
      
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      
      log('Registration exception: ${e.toString()}', name: 'AuthProvider');
      notifyListeners();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Enhanced logout with session cleanup
  Future<void> logout() async {
    if (!_isUserLoggedIn) {
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Clear session timer
      _sessionTimer?.cancel();
      
      // Perform server-side logout if needed
      await _authService.logout();
      
      // Clear local state
      _isUserLoggedIn = false;
      _userToken = null;
      _currentUser = null;
      _errorMessage = null;
      _lastActivityTime = null;
      
      log('User logged out successfully', name: 'AuthProvider');
      
      notifyListeners();
    } catch (e) {
      log('Logout error: ${e.toString()}', name: 'AuthProvider');
      _errorMessage = 'Logout failed';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Refresh authentication token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      if (_userToken == null) {
        return {
          'success': false,
          'message': 'No valid token found',
        };
      }
      
      final result = await _authService.refreshToken(_userToken!);
      
      if (result['success'] == true) {
        _userToken = result['data']?['token'];
        
        // Restart session timer
        _sessionTimer?.cancel();
        _startSessionTimer(result['data']?['token_expires_in'] ?? 0);
        
        notifyListeners();
        
        return {
          'success': true,
          'message': 'Token refreshed successfully',
        };
      } else {
        // Token refresh failed, logout user
        await logout();
        
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }
      
    } catch (e) {
      log('Token refresh error: ${e.toString()}', name: 'AuthProvider');
      return {
        'success': false,
        'message': 'Token refresh failed',
      };
    }
  }
  
  /// Update user information
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      if (!_isUserLoggedIn || _userToken == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }
      
      // Update local user data
      _currentUser?.addAll(userData);
      notifyListeners();
      
      return {
        'success': true,
        'message': 'User information updated',
        'data': _currentUser,
      };
      
    } catch (e) {
      log('Update user error: ${e.toString()}', name: 'AuthProvider');
      return {
        'success': false,
        'message': 'Failed to update user information',
      };
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Track user activity for session management
  void trackUserActivity() {
    _lastActivityTime = DateTime.now();
    
    // Reset session timer if user is active
    if (_isUserLoggedIn && _sessionTimer != null) {
      _sessionTimer?.cancel();
      _startSessionTimer(_sessionTimeoutSeconds);
    }
  }
  
  /// Start session timer for automatic logout
  void _startSessionTimer(int seconds) {
    _sessionTimer?.cancel();
    
    _sessionTimer = Timer(Duration(seconds: seconds), () async {
      log('Session timeout - logging out user', name: 'AuthProvider');
      await logout();
    });
  }
  
  /// Enable biometric authentication
  Future<void> enableBiometricAuth() async {
    try {
      _biometricEnabled = true;
      notifyListeners();
    } catch (e) {
      log('Biometric enable error: ${e.toString()}', name: 'AuthProvider');
    }
  }
  
  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    try {
      _biometricEnabled = false;
      notifyListeners();
    } catch (e) {
      log('Biometric disable error: ${e.toString()}', name: 'AuthProvider');
    }
  }
  
  /// Check if session is about to expire
  bool isSessionExpiring(int warningThresholdSeconds) {
    if (_lastActivityTime == null) {
      return false;
    }
    
    final timeSinceActivity = DateTime.now().difference(_lastActivityTime!);
    final totalSessionTime = Duration(seconds: _sessionTimeoutSeconds);
    
    return timeSinceActivity.inSeconds > (totalSessionTime.inSeconds - warningThresholdSeconds);
  }
  
  /// Get session time remaining
  Duration getSessionTimeRemaining() {
    if (_lastActivityTime == null) {
      return Duration.zero;
    }
    
    final timeSinceActivity = DateTime.now().difference(_lastActivityTime!);
    final totalSessionTime = Duration(seconds: _sessionTimeoutSeconds);
    
    if (timeSinceActivity >= totalSessionTime) {
      return Duration.zero;
    }
    
    return totalSessionTime - timeSinceActivity;
  }
  
  @override
  void dispose() {
    _sessionTimer?.cancel();
    _authService.dispose();
    super.dispose();
  }
}