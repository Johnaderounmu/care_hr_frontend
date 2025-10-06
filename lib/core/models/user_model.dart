// Removed Firebase import - using PostgreSQL backend
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String? phoneNumber;

  @HiveField(5)
  final String? profileImageUrl;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? lastLoginAt;

  @HiveField(9)
  final Map<String, dynamic>? preferences;

  @HiveField(10)
  final List<String>? permissions;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
    this.permissions,
  });

  // Create UserModel from PostgreSQL backend response
  factory UserModel.fromPostgreSQL(Map<String, dynamic> userData, String token) {
    return UserModel(
      id: userData['id']?.toString() ?? '',
      email: userData['email'] ?? '',
      fullName: userData['fullName'] ?? userData['full_name'] ?? '',
      role: userData['role'] ?? 'applicant',
      phoneNumber: userData['phoneNumber'] ?? userData['phone_number'],
      profileImageUrl: userData['profileImageUrl'] ?? userData['profile_image_url'],
      isActive: userData['isActive'] ?? userData['is_active'] ?? true,
      createdAt: userData['createdAt'] != null 
          ? DateTime.parse(userData['createdAt']) 
          : (userData['created_at'] != null 
              ? DateTime.parse(userData['created_at']) 
              : DateTime.now()),
      lastLoginAt: DateTime.now(),
      preferences: userData['preferences'] != null 
          ? Map<String, dynamic>.from(userData['preferences']) 
          : null,
      permissions: userData['permissions'] != null 
          ? List<String>.from(userData['permissions']) 
          : null,
    );
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'applicant',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      preferences: map['preferences'],
      permissions: map['permissions'] != null
          ? List<String>.from(map['permissions'])
          : null,
    );
  }

  // Create UserModel from JSON (same as fromMap for API calls)
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  // Create UserModel from Firebase User (for backward compatibility)
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser?.uid ?? '',
      email: firebaseUser?.email ?? '',
      fullName: firebaseUser?.displayName ?? '',
      role: 'applicant', // Default role for Firebase users
      phoneNumber: firebaseUser?.phoneNumber,
      profileImageUrl: firebaseUser?.photoURL,
      isActive: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: null,
      permissions: null,
    );
  }

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences,
      'permissions': permissions,
    };
  }

  // Convert UserModel to JSON (same as toMap for API calls)
  Map<String, dynamic> toJson() => toMap();

  // Copy with method
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    List<String>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      permissions: permissions ?? this.permissions,
    );
  }

  // Check if user is HR Admin
  bool get isHRAdmin => role == 'hr_admin' || role == 'admin';

  // Check if user is Applicant
  bool get isApplicant => role == 'applicant';

  // Check if user is HR Manager
  bool get isHRManager => role == 'hr_manager';

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (permissions == null) return false;
    return permissions!.contains(permission);
  }

  // Get user initials
  String get initials {
    final nameParts = fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  // Get display name (fallback to email if fullName is empty)
  String get displayName => fullName.isNotEmpty ? fullName : email;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
