import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_client.dart';
import '../services/api_service.dart';
import '../../features/auth/data/services/api_auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  bool get isHRAdmin => _user?.isHRAdmin ?? false;
  bool get isApplicant => _user?.isApplicant ?? false;
  bool get isHRManager => _user?.isHRManager ?? false;

  // Initialize auth provider
  void init() {
    _loadStoredUser();
    _listenToAuthChanges();
  }

  // Development-only sign in helper. Only callable in debug builds.
  Future<bool> devSignInAs({
    required String email,
    String? fullName,
    String role = 'admin',
  }) async {
    if (!kDebugMode) {
      _setError('Dev sign-in is disabled in production');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final devUser = UserModel(
        id: 'dev_${email.replaceAll('@', '_')}',
        email: email,
        fullName: fullName ?? 'Developer',
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );

      _user = devUser;
      _isAuthenticated = true;

      // Persist minimal storage so other services that read StorageService work
      await StorageService.setUserId(devUser.id);
      await StorageService.setUserRole(devUser.role);
      await StorageService.setUserToken('dev-token');

      _logger.i('Dev sign in as: ${devUser.email}');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.e('Dev sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load stored user data
  void _loadStoredUser() {
    try {
      final storedUser = AuthService.getStoredUser();
      if (storedUser != null) {
        _user = storedUser;
        _isAuthenticated = true;
        _logger.i('Stored user loaded: ${_user?.email}');
      }
    } catch (e) {
      _logger.e('Error loading stored user: $e');
    }
  }

  // Listen to Firebase auth state changes
  void _listenToAuthChanges() {
    AuthService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _user = UserModel.fromFirebaseUser(firebaseUser);
        _isAuthenticated = true;
        _logger.i('User authenticated: ${_user?.email}');
      } else {
        _user = null;
        _isAuthenticated = false;
        _logger.i('User signed out');
      }
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final apiBase = dotenv.env['API_BASE_URL'] ?? '';
      if (apiBase.isNotEmpty) {
        // Use backend auth
        final resp = await ApiAuthService.signIn(email, password);
        if (resp.statusCode == 200) {
          final data = resp.data;
          final token = data['token'];
          final userMap = data['user'];
          if (token != null) {
            await StorageService.setUserToken(token);
            ApiClient.setAuthToken(token);
          }
          _user = UserModel(
            id: userMap['id'] ?? '',
            email: userMap['email'] ?? email,
            fullName: userMap['fullName'] ?? '',
            role: userMap['role'] ?? 'applicant',
            isActive: true,
            createdAt: DateTime.now(),
          );
          _isAuthenticated = true;
          _logger.i('Sign in successful (api): ${_user?.email}');
          return true;
        } else {
          _setError(resp.data?.toString() ?? 'Sign in failed');
          return false;
        }
      }

      // Fallback to firebase auth service
      final user = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _logger.i('Sign in successful: ${user.email}');
        return true;
      } else {
        _setError('Sign in failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _logger.e('Sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final apiBase = dotenv.env['API_BASE_URL'] ?? '';
      if (apiBase.isNotEmpty) {
        final resp = await ApiAuthService.signUp(email, password, fullName);
        if (resp.statusCode == 200) {
          final data = resp.data;
          final token = data['token'];
          final userMap = data['user'];
          if (token != null) {
            await StorageService.setUserToken(token);
            ApiClient.setAuthToken(token);
          }
          _user = UserModel(
            id: userMap['id'] ?? '',
            email: userMap['email'] ?? email,
            fullName: userMap['fullName'] ?? fullName,
            role: userMap['role'] ?? role,
            isActive: true,
            createdAt: DateTime.now(),
          );
          _isAuthenticated = true;
          _logger.i('Sign up successful (api): ${_user?.email}');
          return true;
        } else {
          _setError(resp.data?.toString() ?? 'Sign up failed');
          return false;
        }
      }

      // Fallback to firebase
      final user = await AuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _logger.i('Sign up successful: ${user.email}');
        return true;
      } else {
        _setError('Sign up failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _logger.e('Sign up error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      if (kDebugMode) {
        // In debug mode avoid calling remote Firebase signOut which may not be
        // initialized. Just clear local state/storage so dev flows work.
        _logger.w('Debug mode signOut: skipping remote signOut');
      } else {
        await AuthService.signOut();
      }

      // Clear local state regardless
      _user = null;
      _isAuthenticated = false;
      _logger.i('Sign out successful (local state cleared)');
    } catch (e) {
      _setError(e.toString());
      _logger.e('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.resetPassword(email);
      _logger.i('Password reset email sent to: $email');
      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.e('Password reset error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Backend API Login - New implementation using our API service
  Future<bool> loginWithBackend({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check backend connectivity first
      final isBackendHealthy = await ApiService.checkBackendHealth();
      if (!isBackendHealthy) {
        _setError('Backend server is not available. Please try again later.');
        return false;
      }

      // Attempt login
      final result = await ApiService.login(email, password);
      
      if (result['success'] == true) {
        final userData = result['data'];
        final userInfo = userData['user'];
        
        // Create user model from backend response
        _user = UserModel(
          id: userInfo['id'] ?? '',
          email: userInfo['email'] ?? email,
          fullName: userInfo['fullName'] ?? '',
          role: userInfo['role'] ?? 'applicant',
          isActive: true,
          createdAt: DateTime.now(),
        );
        
        _isAuthenticated = true;
        
        // Store user data locally
        await StorageService.setUserToken(userData['token'] ?? '');
        await StorageService.setUserId(userInfo['id'] ?? '');
        await StorageService.setUserRole(userInfo['role'] ?? 'applicant');
        
        _logger.i('Backend login successful: ${_user?.email}');
        return true;
      } else {
        _setError(result['error'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _logger.e('Backend login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Backend API Registration
  Future<bool> registerWithBackend({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.register(email, password, fullName);
      
      if (result['success'] == true) {
        _logger.i('Backend registration successful: $email');
        
        // Auto-login after successful registration
        return await loginWithBackend(email: email, password: password);
      } else {
        _setError(result['error'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _logger.e('Backend registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Enhanced sign out with backend cleanup
  Future<void> signOutFromBackend() async {
    _setLoading(true);
    _clearError();

    try {
      // Clear API service token
      ApiService.logout();
      
      // Clear local state
      _user = null;
      _isAuthenticated = false;
      
      // Clear stored user data
      await StorageService.remove('userToken');
      await StorageService.remove('userId');
      await StorageService.remove('userRole');
      
      _logger.i('Backend sign out successful');
    } catch (e) {
      _setError(e.toString());
      _logger.e('Backend sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.updatePassword(newPassword);
      _logger.i('Password updated successfully');
      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.e('Password update error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (_user != null) {
        _user = _user!.copyWith(
          fullName: displayName ?? _user!.fullName,
          profileImageUrl: photoURL ?? _user!.profileImageUrl,
        );
      }

      _logger.i('Profile updated successfully');
      return true;
    } catch (e) {
      _setError(e.toString());
      _logger.e('Profile update error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    return _user?.hasPermission(permission) ?? false;
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final storedUser = AuthService.getStoredUser();
      if (storedUser != null) {
        _user = storedUser;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error refreshing user: $e');
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
