import 'dart:developer';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Cache entry with metadata
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String key;
  final int size;
  
  CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    this.size = 1,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());
  bool get isValid => !isExpired && data != null;
}

/// Enhanced Cache Service with Memory Management and Persistence Support
class CacheService {
  // In-memory cache storage
  final Map<String, CacheEntry> _cache = {};
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  
  // Cache configuration
  static const Duration defaultCacheDuration = Duration(minutes: 30);
  static const int maxCacheSize = 100; // Maximum number of cached items
  static const Duration cleanupInterval = Duration(minutes: 5); // Cleanup interval
  
  // Cache statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;
  
  late Timer _cleanupTimer;
  
  CacheService() {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _performCleanup());
  }
  
  /// Get cached data for a key
  Future<T?> get<T>(String key) async {
    try {
      final entry = _cache[key];
      
      if (entry == null) {
        _missCount++;
        log('Cache miss for key: $key', name: 'CacheService');
        return null;
      }
      
      if (entry.isExpired) {
        _cache.remove(key);
        _missCount++;
        log('Cache expired for key: $key', name: 'CacheService');
        return null;
      }
      
      _hitCount++;
      log('Cache hit for key: $key', name: 'CacheService');
      
      return entry.data as T;
    } catch (e) {
      log('Cache get error for key $key: ${e.toString()}', name: 'CacheService');
      return null;
    }
  }
  
  /// Put data in cache with optional expiration
  Future<void> put<T>(
    String key,
    T data, {
    Duration? duration,
    bool forceUpdate = false,
  }) async {
    try {
      if (key.isEmpty || data == null) {
        log('Invalid cache parameters for key: $key', name: 'CacheService');
        return;
      }
      
      // Check if already exists and not forcing update
      if (_cache.containsKey(key) && !forceUpdate) {
        final existingEntry = _cache[key]!;
        if (!existingEntry.isExpired) {
          log('Cache entry already exists for key: $key', name: 'CacheService');
          return;
        }
      }
      
      // Calculate expiration time
      final now = DateTime.now();
      final expiration = duration ?? defaultCacheDuration;
      final expiresAt = now.add(expiration);
      
      // Calculate size (simplified)
      final size = _calculateSize(data);
      
      // Create cache entry
      final entry = CacheEntry(
        key: key,
        data: data,
        createdAt: now,
        expiresAt: expiresAt,
        size: size,
      );
      
      // Check cache size limit
      if (_cache.length >= maxCacheSize) {
        await _evictOldestEntries();
      }
      
      // Store in cache
      _cache[key] = entry;
      
      log('Cache stored for key: $key (expires in ${expiration.inMinutes} minutes)', 
          name: 'CacheService');
      
    } catch (e) {
      log('Cache put error for key $key: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Remove specific cache entry
  Future<void> remove(String key) async {
    try {
      final removed = _cache.remove(key);
      if (removed != null) {
        log('Cache removed for key: $key', name: 'CacheService');
      }
    } catch (e) {
      log('Cache remove error for key $key: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Clear all cache entries
  Future<void> clear() async {
    try {
      final count = _cache.length;
      _cache.clear();
      log('Cache cleared: $count entries removed', name: 'CacheService');
    } catch (e) {
      log('Cache clear error: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Check if key exists and is valid
  Future<bool> contains(String key) async {
    try {
      final entry = _cache[key];
      return entry != null && entry.isValid;
    } catch (e) {
      log('Cache contains error for key $key: ${e.toString()}', name: 'CacheService');
      return false;
    }
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? (_hitCount / totalRequests * 100).toStringAsFixed(2) : '0.00';
    
    return {
      'hitCount': _hitCount,
      'missCount': _missCount,
      'evictionCount': _evictionCount,
      'totalRequests': totalRequests,
      'hitRate': '$hitRate%',
      'cacheSize': _cache.length,
      'maxCacheSize': maxCacheSize,
    };
  }
  
  /// Preload data into cache
  Future<void> preload<T>({
    required String key,
    required Future<T> dataProvider,
    Duration? duration,
  }) async {
    try {
      // Check if already cached
      if (await contains(key)) {
        log('Data already cached for key: $key', name: 'CacheService');
        return;
      }
      
      // Check for pending request
      if (_pendingRequests.containsKey(key)) {
        log('Data request already pending for key: $key', name: 'CacheService');
        await _pendingRequests[key]!.future;
        return;
      }
      
      // Create completer for pending request
      final completer = Completer<T>();
      _pendingRequests[key] = completer;
      
      try {
        log('Starting preload for key: $key', name: 'CacheService');
        
        // Fetch data
        final data = await dataProvider;
        
        // Store in cache
        await put(key, data, duration: duration);
        
        // Complete pending request
        completer.complete(data);
        
        log('Preload completed for key: $key', name: 'CacheService');
        
      } catch (e) {
        log('Preload failed for key $key: ${e.toString()}', name: 'CacheService');
        completer.completeError(e);
        throw e;
      } finally {
        _pendingRequests.remove(key);
      }
      
    } catch (e) {
      log('Preload error for key $key: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Get or fetch data with caching
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> dataProvider,
    Duration? duration,
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get from cache first
      if (!forceRefresh) {
        final cachedData = await get<T>(key);
        if (cachedData != null) {
          return cachedData;
        }
      }
      
      // Check for pending request
      if (_pendingRequests.containsKey(key)) {
        log('Waiting for pending request for key: $key', name: 'CacheService');
        return await _pendingRequests[key]!.future;
      }
      
      // Create completer for pending request
      final completer = Completer<T>();
      _pendingRequests[key] = completer;
      
      try {
        log('Fetching data for key: $key', name: 'CacheService');
        
        // Fetch data
        final data = await dataProvider;
        
        // Store in cache
        await put(key, data, duration: duration);
        
        // Complete pending request
        completer.complete(data);
        
        log('Data fetched and cached for key: $key', name: 'CacheService');
        
        return data;
        
      } catch (e) {
        log('Fetch failed for key $key: ${e.toString()}', name: 'CacheService');
        completer.completeError(e);
        throw e;
      } finally {
        _pendingRequests.remove(key);
      }
      
    } catch (e) {
      log('Get or fetch error for key $key: ${e.toString()}', name: 'CacheService');
      rethrow;
    }
  }
  
  /// Batch operations
  Future<Map<String, dynamic>> batchGet(List<String> keys) async {
    final results = <String, dynamic>{};
    final missingKeys = <String>[];
    
    // Check cache for each key
    for (final key in keys) {
      final data = await get(key);
      if (data != null) {
        results[key] = data;
      } else {
        missingKeys.add(key);
      }
    }
    
    return {
      'cached': results,
      'missing': missingKeys,
    };
  }
  
  /// Update cache entry without changing expiration
  Future<void> update(String key, dynamic newData) async {
    try {
      final existingEntry = _cache[key];
      if (existingEntry != null) {
        final updatedEntry = CacheEntry(
          key: key,
          data: newData,
          createdAt: existingEntry.createdAt,
          expiresAt: existingEntry.expiresAt,
          size: _calculateSize(newData),
        );
        
        _cache[key] = updatedEntry;
        log('Cache updated for key: $key', name: 'CacheService');
      }
    } catch (e) {
      log('Cache update error for key $key: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Perform cache cleanup
  Future<void> _performCleanup() async {
    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];
      
      // Find expired entries
      for (final entry in _cache.entries) {
        if (entry.value.isExpired) {
          keysToRemove.add(entry.key);
        }
      }
      
      // Remove expired entries
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
      
      if (keysToRemove.isNotEmpty) {
        log('Cache cleanup removed ${keysToRemove.length} expired entries', 
            name: 'CacheService');
      }
      
      // Evict oldest entries if cache is too large
      if (_cache.length > maxCacheSize) {
        await _evictOldestEntries();
      }
      
    } catch (e) {
      log('Cache cleanup error: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Evict oldest cache entries
  Future<void> _evictOldestEntries() async {
    try {
      // Sort entries by creation time
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      // Calculate how many entries to remove
      final entriesToRemove = (_cache.length - maxCacheSize / 2).ceil();
      
      // Remove oldest entries
      for (int i = 0; i < entriesToRemove && i < sortedEntries.length; i++) {
        _cache.remove(sortedEntries[i].key);
        _evictionCount++;
      }
      
      log('Cache evicted $entriesToRemove old entries', name: 'CacheService');
      
    } catch (e) {
      log('Cache eviction error: ${e.toString()}', name: 'CacheService');
    }
  }
  
  /// Calculate approximate size of data
  int _calculateSize(dynamic data) {
    if (data == null) return 0;
    
    if (data is String) {
      return data.length;
    } else if (data is Map) {
      return data.length;
    } else if (data is List) {
      return data.length;
    } else {
      return 1;
    }
  }
  
  /// Dispose cache service
  void dispose() {
    _cleanupTimer.cancel();
    _cache.clear();
    _pendingRequests.clear();
    log('Cache service disposed', name: 'CacheService');
  }
}