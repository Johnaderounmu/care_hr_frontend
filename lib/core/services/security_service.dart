import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

/// Comprehensive security service for the Care HR application
/// Handles encryption, secure storage, input validation, and security policies
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Security configuration
  static const int _keyLength = 32;
  static const int _saltLength = 16;
  static const String _secureStoragePrefix = 'secure_';

  /// Encrypt sensitive data before storage
  static String encryptData(String plainText, String key) {
    try {
      final keyBytes = utf8.encode(key.padRight(_keyLength).substring(0, _keyLength));
      final plainBytes = utf8.encode(plainText);
      
      // Simple XOR encryption (in production, use proper AES encryption)
      final encrypted = <int>[];
      for (int i = 0; i < plainBytes.length; i++) {
        encrypted.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64.encode(encrypted);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Encryption error: $e');
      }
      throw SecurityException('Failed to encrypt data');
    }
  }

  /// Decrypt sensitive data from storage
  static String decryptData(String encryptedText, String key) {
    try {
      final keyBytes = utf8.encode(key.padRight(_keyLength).substring(0, _keyLength));
      final encryptedBytes = base64.decode(encryptedText);
      
      // Simple XOR decryption (in production, use proper AES decryption)
      final decrypted = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Decryption error: $e');
      }
      throw SecurityException('Failed to decrypt data');
    }
  }

  /// Generate secure random salt for password hashing
  static String generateSalt() {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64.encode(salt);
  }

  /// Hash password with salt using PBKDF2
  static String hashPassword(String password, String salt) {
    final saltBytes = base64.decode(salt);
    final passwordBytes = utf8.encode(password);
    
    // Simple implementation - in production use proper PBKDF2
    final combined = [...passwordBytes, ...saltBytes];
    final digest = sha256.convert(combined);
    
    return digest.toString();
  }

  /// Validate password strength
  static SecurityValidationResult validatePassword(String password) {
    final issues = <String>[];
    
    if (password.length < 8) {
      issues.add('Password must be at least 8 characters long');
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      issues.add('Password must contain at least one uppercase letter');
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      issues.add('Password must contain at least one lowercase letter');
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      issues.add('Password must contain at least one number');
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      issues.add('Password must contain at least one special character');
    }
    
    if (password.length > 128) {
      issues.add('Password must be less than 128 characters');
    }
    
    // Check for common patterns
    final commonPatterns = ['123456', 'password', 'qwerty', 'admin'];
    for (final pattern in commonPatterns) {
      if (password.toLowerCase().contains(pattern)) {
        issues.add('Password contains common patterns');
        break;
      }
    }
    
    return SecurityValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      strength: _calculatePasswordStrength(password),
    );
  }

  /// Calculate password strength score (0-100)
  static int _calculatePasswordStrength(String password) {
    int score = 0;
    
    // Length scoring
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    
    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score += 10;
    if (password.contains(RegExp(r'[A-Z]'))) score += 10;
    if (password.contains(RegExp(r'[0-9]'))) score += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 15;
    
    // Complexity bonus
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars > password.length * 0.7) score += 15;
    
    return score.clamp(0, 100);
  }

  /// Validate email format
  static bool validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  /// Sanitize input to prevent injection attacks
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .trim();
  }

  /// Validate file upload security
  static SecurityValidationResult validateFileUpload(String fileName, List<int> fileBytes) {
    final issues = <String>[];
    
    // Check file extension
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf', '.doc', '.docx'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    
    if (!allowedExtensions.contains(extension)) {
      issues.add('File type not allowed');
    }
    
    // Check file size (10MB limit)
    if (fileBytes.length > 10 * 1024 * 1024) {
      issues.add('File size exceeds 10MB limit');
    }
    
    // Basic file signature validation
    if (!_validateFileSignature(extension, fileBytes)) {
      issues.add('File signature does not match extension');
    }
    
    return SecurityValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      strength: issues.isEmpty ? 100 : 0,
    );
  }

  /// Validate file signature against extension
  static bool _validateFileSignature(String extension, List<int> fileBytes) {
    if (fileBytes.length < 4) return false;
    
    final signature = fileBytes.take(4).toList();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return signature[0] == 0xFF && signature[1] == 0xD8;
      case '.png':
        return signature[0] == 0x89 && signature[1] == 0x50 && 
               signature[2] == 0x4E && signature[3] == 0x47;
      case '.pdf':
        return signature[0] == 0x25 && signature[1] == 0x50 && 
               signature[2] == 0x44 && signature[3] == 0x46;
      default:
        return true; // Allow other formats for now
    }
  }

  /// Secure token generation for sessions
  static String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Store sensitive data securely
  static Future<void> storeSecureData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptionKey = await _getOrCreateEncryptionKey();
      final encryptedValue = encryptData(value, encryptionKey);
      await prefs.setString('$_secureStoragePrefix$key', encryptedValue);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Secure storage error: $e');
      }
      throw SecurityException('Failed to store secure data');
    }
  }

  /// Retrieve sensitive data securely
  static Future<String?> getSecureData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedValue = prefs.getString('$_secureStoragePrefix$key');
      
      if (encryptedValue == null) return null;
      
      final encryptionKey = await _getOrCreateEncryptionKey();
      return decryptData(encryptedValue, encryptionKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Secure retrieval error: $e');
      }
      return null;
    }
  }

  /// Get or create encryption key for secure storage
  static Future<String> _getOrCreateEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? key = prefs.getString('encryption_key');
    
    if (key == null) {
      key = generateSecureToken();
      await prefs.setString('encryption_key', key);
    }
    
    return key;
  }

  /// Clear all secure storage
  static Future<void> clearSecureStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_secureStoragePrefix));
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Rate limiting for API calls
  static final Map<String, List<DateTime>> _rateLimitTracker = {};
  
  static bool checkRateLimit(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    
    _rateLimitTracker[identifier] ??= [];
    
    // Remove old requests outside the window
    _rateLimitTracker[identifier]!.removeWhere((time) => time.isBefore(windowStart));
    
    // Check if limit exceeded
    if (_rateLimitTracker[identifier]!.length >= maxRequests) {
      return false;
    }
    
    // Add current request
    _rateLimitTracker[identifier]!.add(now);
    return true;
  }

  /// Security headers for HTTP requests
  static Map<String, String> getSecurityHeaders() {
    return {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy': "default-src 'self'",
      'Referrer-Policy': 'strict-origin-when-cross-origin',
    };
  }
}

/// Security validation result class
class SecurityValidationResult {
  final bool isValid;
  final List<String> issues;
  final int strength;

  SecurityValidationResult({
    required this.isValid,
    required this.issues,
    required this.strength,
  });

  String get strengthDescription {
    if (strength >= 80) return 'Very Strong';
    if (strength >= 60) return 'Strong';
    if (strength >= 40) return 'Medium';
    if (strength >= 20) return 'Weak';
    return 'Very Weak';
  }
}

/// Security exception class
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}