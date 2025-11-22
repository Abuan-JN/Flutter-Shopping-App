import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Application Configuration and Environment Management
class AppConfig {
  // Singleton instance
  static final AppConfig _instance = AppConfig._internal();
  
  factory AppConfig() => _instance;
  
  AppConfig._internal();
  
  // Environment configuration
  late EnvironmentConfig _environment;
  
  // Feature flags
  late FeatureFlags _features;
  
  // App settings
  late AppSettings _settings;
  
  // API configuration
  late ApiConfiguration _apiConfig;
  
  // Security settings
  late SecurityConfig _security;
  
  /// Initialize configuration
  Future<void> initialize() async {
    _environment = EnvironmentConfig.development();
    _features = FeatureFlags();
    _settings = AppSettings();
    _apiConfig = ApiConfiguration();
    _security = SecurityConfig();
    
    log('App configuration initialized', name: 'AppConfig');
  }
  
  /// Get environment configuration
  EnvironmentConfig get environment => _environment;
  
  /// Get feature flags
  FeatureFlags get features => _features;
  
  /// Get app settings
  AppSettings get settings => _settings;
  
  /// Get API configuration
  ApiConfiguration get api => _apiConfig;
  
  /// Get security configuration
  SecurityConfig get security => _security;
  
  /// Check if app is in development mode
  bool get isDevelopment => kDebugMode;
  
  /// Check if app is in production mode
  bool get isProduction => kReleaseMode;
  
  /// Check if app is in testing mode
  bool get isTesting => kProfileMode;
  
  /// Get platform information
  String get platformInfo {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }
  
  /// Get app version information
  Map<String, dynamic> getVersionInfo() {
    return {
      'version': _settings.appVersion,
      'buildNumber': _settings.buildNumber,
      'platform': platformInfo,
      'environment': _environment.name,
      'debugMode': isDevelopment,
      'releaseMode': isProduction,
    };
  }
  
  /// Update configuration dynamically
  void updateSettings(Map<String, dynamic> updates) {
    updates.forEach((key, value) {
      switch (key) {
        case 'themeMode':
          if (value is ThemeMode) {
            _settings.themeMode = value;
          }
          break;
        case 'languageCode':
          if (value is String) {
            _settings.languageCode = value;
          }
          break;
        case 'enableLogging':
          if (value is bool) {
            _settings.enableLogging = value;
          }
          break;
        case 'cacheSize':
          if (value is int && value > 0) {
            _settings.maxCacheSize = value;
          }
          break;
      }
    });
    
    log('Configuration updated: $updates', name: 'AppConfig');
  }
  
  /// Reset to default configuration
  void resetToDefaults() {
    _features = FeatureFlags();
    _settings = AppSettings();
    _apiConfig = ApiConfiguration();
    _security = SecurityConfig();
    
    log('Configuration reset to defaults', name: 'AppConfig');
  }
  
  /// Export configuration for debugging
  Map<String, dynamic> exportConfiguration() {
    return {
      'environment': {
        'name': _environment.name,
        'baseUrl': _environment.baseUrl,
        'isProduction': _environment.isProduction,
        'isDevelopment': _environment.isDevelopment,
      },
      'features': {
        'enableAnalytics': _features.enableAnalytics,
        'enableCrashReporting': _features.enableCrashReporting,
        'enablePushNotifications': _features.enablePushNotifications,
        'enableBiometricAuth': _features.enableBiometricAuth,
        'enableOfflineMode': _features.enableOfflineMode,
      },
      'settings': {
        'appVersion': _settings.appVersion,
        'buildNumber': _settings.buildNumber,
        'themeMode': _settings.themeMode.toString(),
        'languageCode': _settings.languageCode,
        'enableLogging': _settings.enableLogging,
        'maxCacheSize': _settings.maxCacheSize,
        'sessionTimeout': _settings.sessionTimeout,
        'retryAttempts': _settings.retryAttempts,
      },
      'api': {
        'baseUrl': _apiConfig.baseUrl,
        'timeout': _apiConfig.timeout,
        'retryEnabled': _apiConfig.retryEnabled,
        'maxRetries': _apiConfig.maxRetries,
        'cacheEnabled': _apiConfig.cacheEnabled,
      },
      'security': {
        'encryptionEnabled': _security.encryptionEnabled,
        'certificatePinning': _security.certificatePinning,
        'tokenExpiration': _security.tokenExpiration,
        'maxLoginAttempts': _security.maxLoginAttempts,
        'passwordPolicy': _security.passwordPolicy,
      },
    };
  }
}

/// Environment configuration
class EnvironmentConfig {
  final String _environmentName;
  final String _baseUrl;
  final bool _isProduction;
  final bool _isDevelopment;
  
  EnvironmentConfig._internal({
    String? environmentName,
    String? baseUrl,
    bool? isProduction,
    bool? isDevelopment,
  })  : _environmentName = environmentName ?? (kReleaseMode ? 'production' : 'development'),
        _baseUrl = baseUrl ?? (kReleaseMode 
            ? 'https://api.myapp.com' 
            : 'https://staging.api.myapp.com'),
        _isProduction = isProduction ?? kReleaseMode,
        _isDevelopment = isDevelopment ?? kDebugMode;
  
  factory EnvironmentConfig.development() {
    return EnvironmentConfig._internal(
      environmentName: 'development',
      baseUrl: 'https://staging.api.myapp.com',
      isProduction: false,
      isDevelopment: true,
    );
  }
  
  factory EnvironmentConfig.production() {
    return EnvironmentConfig._internal(
      environmentName: 'production',
      baseUrl: 'https://api.myapp.com',
      isProduction: true,
      isDevelopment: false,
    );
  }
  
  factory EnvironmentConfig.testing() {
    return EnvironmentConfig._internal(
      environmentName: 'testing',
      baseUrl: 'https://test.api.myapp.com',
      isProduction: false,
      isDevelopment: true,
    );
  }
  
  String get name => _environmentName;
  String get baseUrl => _baseUrl;
  bool get isProduction => _isProduction;
  bool get isDevelopment => _isDevelopment;
}

/// Feature flags for A/B testing and feature management
class FeatureFlags {
  bool enableAnalytics = true;
  bool enableCrashReporting = true;
  bool enablePushNotifications = true;
  bool enableBiometricAuth = true;
  bool enableOfflineMode = true;
  bool enableAdvancedTracking = false;
  bool enableExperimentalFeatures = false;
  bool enableVerboseLogging = false;
  bool enablePerformanceMonitoring = true;
  bool enableAutoUpdate = true;
  
  FeatureFlags({
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enablePushNotifications = true,
    this.enableBiometricAuth = true,
    this.enableOfflineMode = true,
    this.enableAdvancedTracking = false,
    this.enableExperimentalFeatures = false,
    this.enableVerboseLogging = false,
    this.enablePerformanceMonitoring = true,
    this.enableAutoUpdate = true,
  });
  
  /// Enable all features (for development)
  void enableAll() {
    enableAnalytics = true;
    enableCrashReporting = true;
    enablePushNotifications = true;
    enableBiometricAuth = true;
    enableOfflineMode = true;
    enableAdvancedTracking = true;
    enableExperimentalFeatures = true;
    enableVerboseLogging = true;
    enablePerformanceMonitoring = true;
    enableAutoUpdate = true;
  }
  
  /// Disable experimental features
  void disableExperimental() {
    enableAdvancedTracking = false;
    enableExperimentalFeatures = false;
    enableVerboseLogging = false;
  }
}

/// Application settings
class AppSettings {
  String appVersion = '2.0.0';
  String buildNumber = '1';
  ThemeMode themeMode = ThemeMode.system;
  String languageCode = 'en';
  bool enableLogging = kDebugMode;
  int maxCacheSize = 50 * 1024 * 1024; // 50MB
  int sessionTimeout = 30 * 60; // 30 minutes
  int retryAttempts = 3;
  int apiTimeout = 30; // 30 seconds
  bool enableAutoSync = true;
  bool enableBackgroundRefresh = true;
  bool enableDataSaver = false;
  bool enableHighQualityImages = true;
  
  AppSettings({
    this.appVersion = '2.0.0',
    this.buildNumber = '1',
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.enableLogging = false,
    this.maxCacheSize = 50 * 1024 * 1024,
    this.sessionTimeout = 30 * 60,
    this.retryAttempts = 3,
    this.apiTimeout = 30,
    this.enableAutoSync = true,
    this.enableBackgroundRefresh = true,
    this.enableDataSaver = false,
    this.enableHighQualityImages = true,
  });
}

/// API configuration
class ApiConfiguration {
  String baseUrl = 'https://api.myapp.com';
  Duration timeout = const Duration(seconds: 30);
  bool retryEnabled = true;
  int maxRetries = 3;
  Duration retryDelay = const Duration(seconds: 1);
  bool cacheEnabled = true;
  Duration cacheDuration = Duration(minutes: 30);
  bool compressionEnabled = true;
  String apiVersion = 'v1';
  String userAgent = 'MyApp/2.0.0';
  
  ApiConfiguration({
    this.baseUrl = 'https://api.myapp.com',
    this.timeout = const Duration(seconds: 30),
    this.retryEnabled = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.cacheEnabled = true,
    Duration? cacheDuration,
    this.compressionEnabled = true,
    this.apiVersion = 'v1',
    this.userAgent = 'MyApp/2.0.0',
  }) : cacheDuration = cacheDuration ?? Duration(minutes: 30);
}

/// Security configuration
class SecurityConfig {
  bool encryptionEnabled = true;
  bool certificatePinning = false;
  int tokenExpiration = 24 * 60 * 60; // 24 hours in seconds
  int maxLoginAttempts = 5;
  int lockoutDuration = 15 * 60; // 15 minutes in seconds
  bool requireHttps = true;
  bool enableBiometricAuth = true;
  bool enableTwoFactorAuth = false;
  String passwordPolicy = 'strong';
  bool sessionTimeoutEnabled = true;
  int sessionTimeout = 30 * 60; // 30 minutes
  
  SecurityConfig({
    this.encryptionEnabled = true,
    this.certificatePinning = false,
    this.tokenExpiration = 24 * 60 * 60,
    this.maxLoginAttempts = 5,
    this.lockoutDuration = 15 * 60,
    this.requireHttps = true,
    this.enableBiometricAuth = true,
    this.enableTwoFactorAuth = false,
    this.passwordPolicy = 'strong',
    this.sessionTimeoutEnabled = true,
    this.sessionTimeout = 30 * 60,
  });
}