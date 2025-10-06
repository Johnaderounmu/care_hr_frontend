import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static final Logger _logger = Logger();
  static const String _baseUrl = 'http://localhost:3001/api'; // Update with your backend URL
  static final StreamController<UserModel?> _authController = StreamController<UserModel?>.broadcast();
  
  // Auth state stream
  static Stream<UserModel?> get authStateChanges => _authController.stream;

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await StorageService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking authentication status: $e');
      return false;
    }
  }

  // Get stored user
  static Future<UserModel?> getStoredUser() async {
    try {
      final userJson = await StorageService.getUser();
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      _logger.e('Error getting stored user: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        // Store token and user
        await StorageService.setToken(token);
        await StorageService.setUser(jsonEncode(user.toJson()));

        // Notify listeners
        _authController.add(user);

        return user;
      } else {
        _logger.e('Sign in failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Sign in error: $e');
      return null;
    }
  }

  // Sign up with email and password
  static Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        // Store token and user
        await StorageService.setToken(token);
        await StorageService.setUser(jsonEncode(user.toJson()));

        // Notify listeners
        _authController.add(user);

        return user;
      } else {
        _logger.e('Sign up failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Sign up error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      // Clear stored data
      await StorageService.clearToken();
      await StorageService.clearUser();

      // Notify listeners
      _authController.add(null);
    } catch (e) {
      _logger.e('Sign out error: $e');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
    } catch (e) {
      _logger.e('Reset password error: $e');
      throw e;
    }
  }

  // Get auth headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
