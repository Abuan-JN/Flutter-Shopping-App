import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormValidator {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates phone number (Philippine format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^(09|\+639)\d{9}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates name (minimum length and no special characters except spaces)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r"^[a-zA-Z\s'-\.]+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, and basic punctuation';
    }
    return null;
  }

  /// Validates address (minimum length)
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address (minimum 10 characters)';
    }
    return null;
  }

  /// Validates product name
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters long';
    }
    return null;
  }

  /// Validates product description
  static String? validateProductDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters long';
    }
    return null;
  }

  /// Validates price (positive number)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final double? price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  /// Validates stock quantity (non-negative integer)
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock quantity is required';
    }
    final int? stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Please enter a valid stock quantity';
    }
    return null;
  }

  /// Validates category name
  static String? validateCategoryName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category name is required';
    }
    if (value.trim().length < 2) {
      return 'Category name must be at least 2 characters long';
    }
    return null;
  }

  /// Validates category description
  static String? validateCategoryDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category description is required';
    }
    if (value.trim().length < 5) {
      return 'Description must be at least 5 characters long';
    }
    return null;
  }

  /// Validates image URL
  static String? validateImageUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Image URL is required';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'Please enter a valid image URL (starting with http:// or https://)';
    }
    return null;
  }
}

class InputFormatter {
  /// Phone number formatter for Philippine numbers
  static String formatPhoneNumber(String input) {
    // Remove all non-digit characters except +
    String digits = input.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Format based on length
    if (digits.length >= 11 && digits.startsWith('0')) {
      // Local format: 09XXXXXXXXX -> 09XX XXX XXXX
      String local = digits.substring(0, 11);
      return '${local.substring(0, 4)} ${local.substring(4, 7)} ${local.substring(7, 11)}';
    } else if (digits.length >= 12 && digits.startsWith('+63')) {
      // International format: +639XXXXXXXXX -> +639 XX XXX XXXX
      String intl = digits.substring(0, 13);
      return '+63 ${intl.substring(3, 5)} ${intl.substring(5, 8)} ${intl.substring(8, 12)}';
    }
    
    return input;
  }

  /// Currency formatter (Philippine Peso)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Quantity formatter (removes decimals)
  static String formatQuantity(int quantity) {
    return quantity.toString();
  }
}

class ErrorHandler {
  /// Shows a snackbar with error message
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows an info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Handles network errors
  static String handleNetworkError(dynamic error) {
    if (error.toString().contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (error.toString().contains('connection') || error.toString().contains('socket')) {
      return 'No internet connection. Please check your connection and try again.';
    } else if (error.toString().contains('http')) {
      return 'Server error. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handles form validation errors
  static Map<String, String> validateForm(Map<String, String> fields) {
    final Map<String, String> errors = {};
    
    fields.forEach((key, value) {
      String? error;
      switch (key) {
        case 'email':
          error = FormValidator.validateEmail(value);
          break;
        case 'phone':
          error = FormValidator.validatePhone(value);
          break;
        case 'name':
          error = FormValidator.validateName(value);
          break;
        case 'address':
          error = FormValidator.validateAddress(value);
          break;
        case 'productName':
          error = FormValidator.validateProductName(value);
          break;
        case 'productDescription':
          error = FormValidator.validateProductDescription(value);
          break;
        case 'price':
          error = FormValidator.validatePrice(value);
          break;
        case 'stock':
          error = FormValidator.validateStock(value);
          break;
        case 'categoryName':
          error = FormValidator.validateCategoryName(value);
          break;
        case 'categoryDescription':
          error = FormValidator.validateCategoryDescription(value);
          break;
        case 'imageUrl':
          error = FormValidator.validateImageUrl(value);
          break;
      }
      
      if (error != null) {
        errors[key] = error;
      }
    });
    
    return errors;
  }
}

class LoadingState {
  /// Shows a loading dialog
  static Future<void> showLoadingDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Dismisses the loading dialog
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}