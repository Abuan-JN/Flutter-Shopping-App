import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUserLoggedIn = false;
  String? _userToken;
  Map<String, dynamic>? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUserLoggedIn => _isUserLoggedIn;
  String? get userToken => _userToken;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      
      if (result['success'] == true) {
        _isUserLoggedIn = true;
        _userToken = result['data']?['token'];
        _currentUser = result['data']?['user'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isUserLoggedIn = false;
        _userToken = null;
        _currentUser = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _isUserLoggedIn = false;
      _userToken = null;
      _currentUser = null;
      notifyListeners();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String address, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
      );
      
      if (result['success'] == true) {
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  void logout() {
    _isUserLoggedIn = false;
    _userToken = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}