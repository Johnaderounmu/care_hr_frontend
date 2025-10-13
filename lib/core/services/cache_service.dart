import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced caching service for the Care HR application
/// Provides memory and persistent caching with TTL, LRU eviction, and cache warming
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Memory caches
  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, CacheEntry> _persistentCache = {};
  
  // Cache configuration
  static const int _maxMemoryCacheSize = 100;
  static const int _maxPersistentCacheSize = 500;
  static const Duration _defaultTtl = Duration(hours: 1);
  static const Duration _cleanupInterval = Duration(minutes: 10);
  
  // Cache statistics
  int _memoryHits = 0;
  int _memoryMisses = 0;
  int _persistentHits = 0;
  int _persistentMisses = 0;
  
  Timer? _cleanupTimer;
  SharedPreferences? _prefs;

  /// Initialize caching service
  static Future<void> init() async {
    final instance = CacheService._instance;
    await instance._initialize();
    
    if (kDebugMode) {
      print('🗄️ CacheService initialized');
    }
  }

  /// Initialize cache service
  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadPersistentCache();
      _startCleanupTimer();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache initialization error: $e');
      }
    }
  }

  /// Start cleanup timer for expired entries
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _cleanupExpiredEntries();
    });
  }

  /// Store data in memory cache
  static void setMemory(
    String key,
    dynamic value, {
    Duration? ttl,
    int? priority,
  }) {
    final instance = CacheService._instance;
    instance._setMemoryCache(key, value, ttl ?? _defaultTtl, priority ?? 1);
  }

  /// Store data in persistent cache
  static Future<void> setPersistent(
    String key,
    dynamic value, {
    Duration? ttl,
    int? priority,
  }) async {
    final instance = CacheService._instance;
    await instance._setPersistentCache(key, value, ttl ?? _defaultTtl, priority ?? 1);
  }

  /// Get data from memory cache
  static T? getMemory<T>(String key) {
    final instance = CacheService._instance;
    return instance._getMemoryCache<T>(key);
  }

  /// Get data from persistent cache
  static Future<T?> getPersistent<T>(String key) async {
    final instance = CacheService._instance;
    return instance._getPersistentCache<T>(key);
  }

  /// Get data from any cache (memory first, then persistent)
  static Future<T?> get<T>(String key) async {
    // Try memory cache first
    final memoryResult = getMemory<T>(key);
    if (memoryResult != null) {
      return memoryResult;
    }
    
    // Try persistent cache
    return getPersistent<T>(key);
  }

  /// Set data in both memory and persistent cache
  static Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    int? priority,
    bool memoryOnly = false,
  }) async {
    // Always set in memory cache
    setMemory(key, value, ttl: ttl, priority: priority);
    
    // Set in persistent cache unless memoryOnly
    if (!memoryOnly) {
      await setPersistent(key, value, ttl: ttl, priority: priority);
    }
  }

  /// Internal method to set memory cache
  void _setMemoryCache(String key, dynamic value, Duration ttl, int priority) {
    try {
      // Remove existing entry
      _memoryCache.remove(key);
      
      // Create new entry
      final entry = CacheEntry(
        key: key,
        value: value,
        timestamp: DateTime.now(),
        ttl: ttl,
        priority: priority,
        accessCount: 1,
        lastAccessed: DateTime.now(),
      );
      
      _memoryCache[key] = entry;
      
      // Enforce cache size limit with LRU eviction
      _evictMemoryIfNeeded();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Memory cache set error: $e');
      }
    }
  }

  /// Internal method to set persistent cache
  Future<void> _setPersistentCache(String key, dynamic value, Duration ttl, int priority) async {
    try {
      if (_prefs == null) return;
      
      // Remove existing entry
      _persistentCache.remove(key);
      
      // Create new entry
      final entry = CacheEntry(
        key: key,
        value: value,
        timestamp: DateTime.now(),
        ttl: ttl,
        priority: priority,
        accessCount: 1,
        lastAccessed: DateTime.now(),
      );
      
      _persistentCache[key] = entry;
      
      // Save to SharedPreferences
      await _saveCacheEntry(key, entry);
      
      // Enforce cache size limit
      await _evictPersistentIfNeeded();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Persistent cache set error: $e');
      }
    }
  }

  /// Internal method to get from memory cache
  T? _getMemoryCache<T>(String key) {
    try {
      final entry = _memoryCache[key];
      
      if (entry == null) {
        _memoryMisses++;
        return null;
      }
      
      // Check if expired
      if (entry.isExpired) {
        _memoryCache.remove(key);
        _memoryMisses++;
        return null;
      }
      
      // Update access statistics
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
      
      _memoryHits++;
      return entry.value as T?;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Memory cache get error: $e');
      }
      _memoryMisses++;
      return null;
    }
  }

  /// Internal method to get from persistent cache
  Future<T?> _getPersistentCache<T>(String key) async {
    try {
      final entry = _persistentCache[key];
      
      if (entry == null) {
        _persistentMisses++;
        return null;
      }
      
      // Check if expired
      if (entry.isExpired) {
        _persistentCache.remove(key);
        await _removeCacheEntry(key);
        _persistentMisses++;
        return null;
      }
      
      // Update access statistics
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
      
      _persistentHits++;
      return entry.value as T?;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Persistent cache get error: $e');
      }
      _persistentMisses++;
      return null;
    }
  }

  /// Evict memory cache entries if needed (LRU)
  void _evictMemoryIfNeeded() {
    while (_memoryCache.length > _maxMemoryCacheSize) {
      // Find least recently used entry
      CacheEntry? lruEntry;
      String? lruKey;
      
      for (final entry in _memoryCache.entries) {
        if (lruEntry == null || entry.value.lastAccessed.isBefore(lruEntry.lastAccessed)) {
          lruEntry = entry.value;
          lruKey = entry.key;
        }
      }
      
      if (lruKey != null) {
        _memoryCache.remove(lruKey);
      } else {
        break; // Safety break
      }
    }
  }

  /// Evict persistent cache entries if needed (LRU)
  Future<void> _evictPersistentIfNeeded() async {
    while (_persistentCache.length > _maxPersistentCacheSize) {
      // Find least recently used entry
      CacheEntry? lruEntry;
      String? lruKey;
      
      for (final entry in _persistentCache.entries) {
        if (lruEntry == null || entry.value.lastAccessed.isBefore(lruEntry.lastAccessed)) {
          lruEntry = entry.value;
          lruKey = entry.key;
        }
      }
      
      if (lruKey != null) {
        _persistentCache.remove(lruKey);
        await _removeCacheEntry(lruKey);
      } else {
        break; // Safety break
      }
    }
  }

  /// Clean up expired cache entries
  void _cleanupExpiredEntries() {
    try {
      // Clean memory cache
      final expiredMemoryKeys = <String>[];
      for (final entry in _memoryCache.entries) {
        if (entry.value.isExpired) {
          expiredMemoryKeys.add(entry.key);
        }
      }
      for (final key in expiredMemoryKeys) {
        _memoryCache.remove(key);
      }
      
      // Clean persistent cache
      final expiredPersistentKeys = <String>[];
      for (final entry in _persistentCache.entries) {
        if (entry.value.isExpired) {
          expiredPersistentKeys.add(entry.key);
        }
      }
      for (final key in expiredPersistentKeys) {
        _persistentCache.remove(key);
        _removeCacheEntry(key);
      }
      
      if (kDebugMode && (expiredMemoryKeys.isNotEmpty || expiredPersistentKeys.isNotEmpty)) {
        print('🧹 Cache cleanup: ${expiredMemoryKeys.length} memory, ${expiredPersistentKeys.length} persistent');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache cleanup error: $e');
      }
    }
  }

  /// Load persistent cache from storage
  Future<void> _loadPersistentCache() async {
    try {
      if (_prefs == null) return;
      
      final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      
      for (final key in keys) {
        final data = _prefs!.getString(key);
        if (data != null) {
          try {
            final json = jsonDecode(data);
            final entry = CacheEntry.fromJson(json);
            
            if (!entry.isExpired) {
              _persistentCache[entry.key] = entry;
            } else {
              // Remove expired entry
              await _prefs!.remove(key);
            }
          } catch (e) {
            // Invalid cache entry, remove it
            await _prefs!.remove(key);
          }
        }
      }
      
      if (kDebugMode) {
        print('📂 Loaded ${_persistentCache.length} persistent cache entries');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load persistent cache: $e');
      }
    }
  }

  /// Save cache entry to storage
  Future<void> _saveCacheEntry(String key, CacheEntry entry) async {
    try {
      if (_prefs == null) return;
      
      final json = entry.toJson();
      await _prefs!.setString('cache_$key', jsonEncode(json));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to save cache entry: $e');
      }
    }
  }

  /// Remove cache entry from storage
  Future<void> _removeCacheEntry(String key) async {
    try {
      if (_prefs == null) return;
      await _prefs!.remove('cache_$key');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to remove cache entry: $e');
      }
    }
  }

  /// Clear specific cache
  static Future<void> clearMemory() async {
    final instance = CacheService._instance;
    instance._memoryCache.clear();
    
    if (kDebugMode) {
      print('🗑️ Memory cache cleared');
    }
  }

  /// Clear persistent cache
  static Future<void> clearPersistent() async {
    final instance = CacheService._instance;
    instance._persistentCache.clear();
    
    if (instance._prefs != null) {
      final keys = instance._prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      for (final key in keys) {
        await instance._prefs!.remove(key);
      }
    }
    
    if (kDebugMode) {
      print('🗑️ Persistent cache cleared');
    }
  }

  /// Clear all caches
  static Future<void> clearAll() async {
    await clearMemory();
    await clearPersistent();
  }

  /// Get cache statistics
  static CacheStatistics getStatistics() {
    final instance = CacheService._instance;
    return CacheStatistics(
      memoryHits: instance._memoryHits,
      memoryMisses: instance._memoryMisses,
      persistentHits: instance._persistentHits,
      persistentMisses: instance._persistentMisses,
      memoryCacheSize: instance._memoryCache.length,
      persistentCacheSize: instance._persistentCache.length,
    );
  }

  /// Remove specific key from all caches
  static Future<void> remove(String key) async {
    final instance = CacheService._instance;
    instance._memoryCache.remove(key);
    instance._persistentCache.remove(key);
    await instance._removeCacheEntry(key);
  }

  /// Check if key exists in cache
  static bool containsKey(String key) {
    final instance = CacheService._instance;
    return instance._memoryCache.containsKey(key) || instance._persistentCache.containsKey(key);
  }

  /// Warm up cache with frequently used data
  static Future<void> warmUp(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await set(entry.key, entry.value, priority: 10); // High priority for warm-up data
    }
    
    if (kDebugMode) {
      print('🔥 Cache warmed up with ${data.length} entries');
    }
  }

  /// Dispose cache service
  static void dispose() {
    final instance = CacheService._instance;
    instance._cleanupTimer?.cancel();
    
    if (kDebugMode) {
      print('🛑 CacheService disposed');
    }
  }
}

/// Cache entry container
class CacheEntry {
  final String key;
  final dynamic value;
  final DateTime timestamp;
  final Duration ttl;
  final int priority;
  int accessCount;
  DateTime lastAccessed;

  CacheEntry({
    required this.key,
    required this.value,
    required this.timestamp,
    required this.ttl,
    required this.priority,
    required this.accessCount,
    required this.lastAccessed,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  Map<String, dynamic> toJson() => {
    'key': key,
    'value': value.toString(), // Simplified - in production, handle complex serialization
    'timestamp': timestamp.toIso8601String(),
    'ttl': ttl.inMilliseconds,
    'priority': priority,
    'accessCount': accessCount,
    'lastAccessed': lastAccessed.toIso8601String(),
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'] as String,
      value: json['value'], // Simplified - in production, handle complex deserialization
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: Duration(milliseconds: json['ttl'] as int),
      priority: json['priority'] as int,
      accessCount: json['accessCount'] as int,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
    );
  }
}

/// Cache statistics container
class CacheStatistics {
  final int memoryHits;
  final int memoryMisses;
  final int persistentHits;
  final int persistentMisses;
  final int memoryCacheSize;
  final int persistentCacheSize;

  CacheStatistics({
    required this.memoryHits,
    required this.memoryMisses,
    required this.persistentHits,
    required this.persistentMisses,
    required this.memoryCacheSize,
    required this.persistentCacheSize,
  });

  double get memoryHitRate => (memoryHits + memoryMisses) == 0 ? 0.0 : memoryHits / (memoryHits + memoryMisses);
  double get persistentHitRate => (persistentHits + persistentMisses) == 0 ? 0.0 : persistentHits / (persistentHits + persistentMisses);
  double get overallHitRate {
    final totalHits = memoryHits + persistentHits;
    final totalRequests = memoryHits + memoryMisses + persistentHits + persistentMisses;
    return totalRequests == 0 ? 0.0 : totalHits / totalRequests;
  }

  @override
  String toString() {
    return 'Cache Stats: Memory (${memoryCacheSize} entries, ${(memoryHitRate * 100).toStringAsFixed(1)}% hit rate), '
           'Persistent (${persistentCacheSize} entries, ${(persistentHitRate * 100).toStringAsFixed(1)}% hit rate), '
           'Overall: ${(overallHitRate * 100).toStringAsFixed(1)}% hit rate';
  }
}