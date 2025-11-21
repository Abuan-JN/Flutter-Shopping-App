import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAdminLoggedIn = false;
  String? _adminToken;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdminLoggedIn => _isAdminLoggedIn;
  String? get adminToken => _adminToken;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(username, password);
      
      if (result['success'] == true) {
        _isAdminLoggedIn = true;
        _adminToken = result['data']?['token'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isAdminLoggedIn = false;
        _adminToken = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _isAdminLoggedIn = false;
      _adminToken = null;
      notifyListeners();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  void logout() {
    _isAdminLoggedIn = false;
    _adminToken = null;
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