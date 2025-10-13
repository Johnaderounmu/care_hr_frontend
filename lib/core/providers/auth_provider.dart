import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final Logger _logger = Logger();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Helper methods for role checking
  bool get isHRAdmin => _user?.role == 'hr_admin';
  bool get isApplicant => _user?.role == 'applicant';

  // Initialize auth state
  Future<void> init() async {
    try {
      _logger.i('🚀 AuthProvider.init() started');
      _setLoading(true);
      
      // Check if user is already authenticated
      final isAuth = await AuthService.isAuthenticated();
      _logger.i('📋 Existing authentication check: $isAuth');
      
      if (isAuth) {
        final storedUser = await AuthService.getStoredUser();
        if (storedUser != null) {
          _logger.i('👤 Found stored user: ${storedUser.email} (${storedUser.role})');
          _setUser(storedUser);
          _setAuthenticated(true);
          _setLoading(false);
          return;
        }
      }

      // For demo purposes, auto-login with demo HR admin user
      _logger.i('🎭 Creating demo login...');
      await _createDemoLogin();
      
      _setLoading(false);
      _logger.i('✅ AuthProvider initialization completed');
    } catch (e) {
      _logger.e('❌ Error initializing auth: $e');
      _setError('Failed to initialize authentication');
      _setLoading(false);
    }
  }

  // Create demo login for development/testing
  Future<void> _createDemoLogin() async {
    try {
      _logger.i('Creating demo login...');
      
      // Create HR Admin demo user
      final demoUser = UserModel.fromMap({
        'id': 'demo_hr_admin',
        'email': 'hr@example.com',
        'fullName': 'HR Administrator',
        'role': 'hr_admin',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Store demo user
      await StorageService.setUser(jsonEncode(demoUser.toMap()));
      _setUser(demoUser);
      _setAuthenticated(true);  // CRITICAL: Set authenticated state to true
      _setLoading(false);
      
      _logger.i('Demo user created and stored: ${demoUser.email} (${demoUser.role}) - Authenticated: true');
    } catch (e) {
      _logger.e('Error creating demo login: $e');
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _setUser(user);
        _setAuthenticated(true);
        _setLoading(false);
        return true;
      } else {
        _setError('Invalid email or password');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('Sign in error: $e');
      _setError('Sign in failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (user != null) {
        _setUser(user);
        _setAuthenticated(true);
        _setLoading(false);
        return true;
      } else {
        _setError('Sign up failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('Sign up error: $e');
      _setError('Sign up failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _setUser(null);
      _setAuthenticated(false);
      _setLoading(false);
    } catch (e) {
      _logger.e('Sign out error: $e');
      _setError('Sign out failed');
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await AuthService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _logger.e('Reset password error: $e');
      _setError('Failed to send reset email');
      _setLoading(false);
      return false;
    }
  }

  // Private setters
  void _setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  // Development sign-in method for testing
  Future<bool> devSignInAs({
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Create a mock user for development
      final user = UserModel.fromMap({
        'id': 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'fullName': fullName,
        'role': role,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      _setUser(user);
      _setAuthenticated(true);
      _setLoading(false);
      return true;
    } catch (e) {
      _logger.e('Dev sign in error: $e');
      _setError('Development sign in failed');
      _setLoading(false);
      return false;
    }
  }

  // Backend login method (alias for signIn)
  Future<bool> loginWithBackend({
    required String email,
    required String password,
  }) async {
    return await signIn(email: email, password: password);
  }

  // Backend registration method (alias for signUp)
  Future<bool> registerWithBackend({
    required String email,
    required String password,
    required String fullName,
    String role = 'applicant', // Default role
  }) async {
    return await signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  // Update profile method
  Future<bool> updateProfile({
    String? displayName,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_user != null) {
        final updatedUser = _user!.copyWith(
          fullName: displayName ?? fullName ?? _user!.fullName,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
        );
        
        // Store updated user
        await StorageService.setUser(jsonEncode(updatedUser.toJson()));
        _setUser(updatedUser);
        
        _setLoading(false);
        return true;
      } else {
        _setError('No user to update');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('Update profile error: $e');
      _setError('Failed to update profile');
      _setLoading(false);
      return false;
    }
  }
}
