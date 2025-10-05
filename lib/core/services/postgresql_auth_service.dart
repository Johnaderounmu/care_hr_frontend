import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class PostgreSQLAuthService {
  static final Logger _logger = Logger();
  static const String _baseUrl = 'http://localhost:4000'; // Your PostgreSQL backend

  // Login with PostgreSQL backend
  static Future<UserModel?> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
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
        _logger.i('Login successful');
        
        // Create UserModel from backend response
        return UserModel.fromPostgreSQL(data['user'], data['token']);
      } else {
        _logger.e('Login failed: ${response.body}');
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Register with PostgreSQL backend
  static Future<UserModel?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String fullName
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _logger.i('Registration successful');
        
        return UserModel.fromPostgreSQL(data['user'], data['token']);
      } else {
        _logger.e('Registration failed: ${response.body}');
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Logout (clear local storage)
  static Future<void> signOut() async {
    try {
      _logger.i('User signed out');
      // Clear any stored tokens or user data locally
    } catch (e) {
      _logger.e('Sign out error: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _logger.i('Password reset email sent');
      } else {
        _logger.e('Password reset failed: ${response.body}');
        throw Exception('Password reset failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Password reset error: $e');
      throw Exception('Password reset failed: $e');
    }
  }

  // Verify JWT token with backend
  static Future<UserModel?> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('Token verified');
        
        return UserModel.fromPostgreSQL(data['user'], token);
      } else {
        _logger.e('Token verification failed: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('Token verification error: $e');
      return null;
    }
  }

  // Update user profile
  static Future<UserModel?> updateProfile(UserModel user, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('Profile updated');
        
        return UserModel.fromPostgreSQL(data['user'], token);
      } else {
        _logger.e('Profile update failed: ${response.body}');
        throw Exception('Profile update failed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Profile update error: $e');
      throw Exception('Profile update failed: $e');
    }
  }

  // Handle authentication exceptions
  static String handleAuthException(Exception e) {
    final String message = e.toString();
    
    if (message.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (message.contains('user-disabled')) {
      return 'This user account has been disabled.';
    } else if (message.contains('user-not-found')) {
      return 'No user found with this email address.';
    } else if (message.contains('wrong-password')) {
      return 'Wrong password provided.';
    } else if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    } else if (message.contains('weak-password')) {
      return 'The password provided is too weak.';
    } else if (message.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }
}