import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/cors_config.dart';
import '../utils/cors_helper.dart';

/// Enhanced HTTP client with built-in CORS support and retry logic
class CorsService {
  final http.Client _client;
  final Duration _timeout;
  final int _maxRetries;
  final Duration _retryDelay;

  CorsService({
    http.Client? client,
    Duration? timeout,
    int? maxRetries,
    Duration? retryDelay,
  })  : _client = client ?? http.Client(),
        _timeout = timeout ?? Duration(milliseconds: CorsConfig.requestTimeout),
        _maxRetries = maxRetries ?? CorsConfig.maxRetries,
        _retryDelay = retryDelay ?? Duration(milliseconds: CorsConfig.retryDelay);

  /// Make a GET request with CORS support and retry logic
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool includeAuthHeaders = false,
  }) async {
    return _makeRequest(
      () => _client.get(url, headers: _getHeaders(headers, includeAuthHeaders)),
      'GET',
      url.toString(),
    );
  }

  /// Make a POST request with CORS support and retry logic
  Future<http.Response> post(
    Uri url,
    {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool includeAuthHeaders = false,
  }) async {
    return _makeRequest(
      () => _client.post(url,
          headers: _getHeaders(headers, includeAuthHeaders),
          body: body,
          encoding: encoding),
      'POST',
      url.toString(),
    );
  }

  /// Make a PUT request with CORS support and retry logic
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool includeAuthHeaders = false,
  }) async {
    return _makeRequest(
      () => _client.put(url,
          headers: _getHeaders(headers, includeAuthHeaders),
          body: body,
          encoding: encoding),
      'PUT',
      url.toString(),
    );
  }

  /// Make a DELETE request with CORS support and retry logic
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    bool includeAuthHeaders = false,
  }) async {
    return _makeRequest(
      () => _client.delete(url, headers: _getHeaders(headers, includeAuthHeaders)),
      'DELETE',
      url.toString(),
    );
  }

  /// Internal method to make requests with retry logic
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunction,
    String method,
    String url,
  ) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt <= _maxRetries) {
      try {
        attempt++;
        
        log('Making $method request to $url (attempt $attempt)', name: 'CorsService');
        
        final response = await _timeoutRequest(requestFunction);
        
        // Check for CORS-related issues
        if (response.statusCode == 0 || 
            (response.statusCode >= 400 && response.statusCode < 600)) {
          log('Request failed with status: ${response.statusCode}', name: 'CorsService');
          
          if (attempt <= _maxRetries) {
            log('Retrying in ${_retryDelay.inSeconds} seconds...', name: 'CorsService');
            await Future.delayed(_retryDelay);
            continue;
          }
        }
        
        return response;
        
      } on TimeoutException {
        lastException = TimeoutException('Request timeout after ${_timeout.inSeconds} seconds');
        log('Timeout on attempt $attempt: ${lastException.toString()}', name: 'CorsService');
        
      } on Exception catch (e) {
        lastException = e;
        log('Error on attempt $attempt: ${e.toString()}', name: 'CorsService');
      }
      
      if (attempt <= _maxRetries) {
        log('Retrying in ${_retryDelay.inSeconds} seconds...', name: 'CorsService');
        await Future.delayed(_retryDelay);
      }
    }
    
    // All retries exhausted
    throw Exception(CorsHelper.handleCorsError(lastException ?? 'Max retries exceeded'));
  }

  /// Wrap request with timeout
  Future<http.Response> _timeoutRequest(Future<http.Response> Function() requestFunction) {
    return requestFunction().timeout(_timeout, 
        onTimeout: () => throw TimeoutException('Request timeout'));
  }

  /// Get headers with CORS configuration
  Map<String, String> _getHeaders(Map<String, String>? customHeaders, bool includeAuthHeaders) {
    final headers = includeAuthHeaders 
        ? CorsConfig.getFullHeaders(includeAuthHeaders: true)
        : CorsConfig.getFullHeaders();
    
    // Override with custom headers if provided
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }

  /// Check if origin is allowed
  bool isOriginAllowed(String? origin) {
    return CorsConfig.isOriginAllowed(origin);
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}