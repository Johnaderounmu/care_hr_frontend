import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Logger _logger = Logger();

  // Current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  static User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  static Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final userModel = UserModel.fromFirebaseUser(result.user!);

        // Store user data locally (ensure token is non-null)
        final token = await result.user!.getIdToken();
        if (token != null && token.isNotEmpty) {
          await StorageService.setUserToken(token);
        }
        await StorageService.setUserId(result.user!.uid);
        await StorageService.setUserRole(userModel.role);

        _logger.i('User signed in successfully: ${userModel.email}');
        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Sign in error: $e');
      throw Exception('An unexpected error occurred');
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
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(fullName);

        final userModel = UserModel(
          id: result.user!.uid,
          email: email,
          fullName: fullName,
          role: role,
          isActive: true,
          createdAt: DateTime.now(),
        );

        // Store user data locally (ensure token is non-null)
        final token = await result.user!.getIdToken();
        if (token != null && token.isNotEmpty) {
          await StorageService.setUserToken(token);
        }
        await StorageService.setUserId(result.user!.uid);
        await StorageService.setUserRole(userModel.role);

        _logger.i('User signed up successfully: ${userModel.email}');
        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Sign up error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await StorageService.clear();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      throw Exception('Failed to sign out');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      _logger.e('Password reset error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Password reset error: $e');
      throw Exception('Failed to send password reset email');
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _logger.i('Password updated successfully');
      } else {
        throw Exception('No user logged in');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Password update error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Password update error: $e');
      throw Exception('Failed to update password');
    }
  }

  // Update profile
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        _logger.i('Profile updated successfully');
      } else {
        throw Exception('No user logged in');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Profile update error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Profile update error: $e');
      throw Exception('Failed to update profile');
    }
  }

  // Get stored user data
  static UserModel? getStoredUser() {
    try {
      final userId = StorageService.getUserId();
      final userRole = StorageService.getUserRole();
      final userToken = StorageService.getUserToken();

      if (userId != null && userRole != null && userToken != null) {
        return UserModel(
          id: userId,
          email: currentUser?.email ?? '',
          fullName: currentUser?.displayName ?? '',
          role: userRole,
          isActive: true,
          createdAt: DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      _logger.e('Error getting stored user: $e');
      return null;
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated {
    return currentUser != null && StorageService.getUserToken() != null;
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}
