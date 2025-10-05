import 'package:hive/hive.dart';

// removed unused import
import '../../../../core/models/user_role.dart';
import 'user_role_model.dart';

part 'extended_user_model.g.dart';

@HiveType(typeId: 13)
class ExtendedUserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String firstName;

  @HiveField(3)
  String lastName;

  @HiveField(4)
  String? phoneNumber;

  @HiveField(5)
  String? profilePicture;

  @HiveField(6)
  UserRole role;

  @HiveField(7)
  List<String> assignedRoles;

  @HiveField(8)
  List<Permission> additionalPermissions;

  @HiveField(9)
  UserStatus status;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  DateTime? lastLoginAt;

  @HiveField(13)
  String? createdBy;

  @HiveField(14)
  String? department;

  @HiveField(15)
  String? jobTitle;

  @HiveField(16)
  String? employeeId;

  @HiveField(17)
  DateTime? hireDate;

  @HiveField(18)
  String? managerId;

  @HiveField(19)
  List<String> teamMemberIds;

  @HiveField(20)
  Map<String, dynamic>? preferences;

  @HiveField(21)
  List<String> skills;

  @HiveField(22)
  String? bio;

  @HiveField(23)
  String? linkedinUrl;

  @HiveField(24)
  String? githubUrl;

  @HiveField(25)
  String? portfolioUrl;

  @HiveField(26)
  bool isEmailVerified;

  @HiveField(27)
  bool isPhoneVerified;

  @HiveField(28)
  bool twoFactorEnabled;

  @HiveField(29)
  DateTime? passwordChangedAt;

  @HiveField(30)
  int loginAttempts;

  @HiveField(31)
  DateTime? lockedUntil;

  @HiveField(32)
  List<String> ipAddresses;

  @HiveField(33)
  String? timezone;

  @HiveField(34)
  String? language;

  @HiveField(35)
  bool notificationsEnabled;

  @HiveField(36)
  Map<String, bool> notificationPreferences;

  @HiveField(37)
  List<String> tags;

  @HiveField(38)
  Map<String, dynamic>? metadata;

  ExtendedUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePicture,
    required this.role,
    this.assignedRoles = const [],
    this.additionalPermissions = const [],
    this.status = UserStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.createdBy,
    this.department,
    this.jobTitle,
    this.employeeId,
    this.hireDate,
    this.managerId,
    this.teamMemberIds = const [],
    this.preferences,
    this.skills = const [],
    this.bio,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.twoFactorEnabled = false,
    this.passwordChangedAt,
    this.loginAttempts = 0,
    this.lockedUntil,
    this.ipAddresses = const [],
    this.timezone,
    this.language,
    this.notificationsEnabled = true,
    this.notificationPreferences = const {},
    this.tags = const [],
    this.metadata,
  });

  ExtendedUserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    UserRole? role,
    List<String>? assignedRoles,
    List<Permission>? additionalPermissions,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? createdBy,
    String? department,
    String? jobTitle,
    String? employeeId,
    DateTime? hireDate,
    String? managerId,
    List<String>? teamMemberIds,
    Map<String, dynamic>? preferences,
    List<String>? skills,
    String? bio,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? twoFactorEnabled,
    DateTime? passwordChangedAt,
    int? loginAttempts,
    DateTime? lockedUntil,
    List<String>? ipAddresses,
    String? timezone,
    String? language,
    bool? notificationsEnabled,
    Map<String, bool>? notificationPreferences,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return ExtendedUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      assignedRoles: assignedRoles ?? this.assignedRoles,
      additionalPermissions:
          additionalPermissions ?? this.additionalPermissions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdBy: createdBy ?? this.createdBy,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      employeeId: employeeId ?? this.employeeId,
      hireDate: hireDate ?? this.hireDate,
      managerId: managerId ?? this.managerId,
      teamMemberIds: teamMemberIds ?? this.teamMemberIds,
      preferences: preferences ?? this.preferences,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      ipAddresses: ipAddresses ?? this.ipAddresses,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  String get fullName => '$firstName $lastName';

  String get displayName => fullName;

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';

  bool get isActive => status == UserStatus.active;
  bool get isInactive => status == UserStatus.inactive;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  bool get isHRUser => role == UserRole.hr || assignedRoles.contains('hr');
  bool get isApplicant => role == UserRole.applicant;
  bool get isAdmin => role == UserRole.admin || assignedRoles.contains('admin');

  bool hasPermission(Permission permission) {
    // Check additional permissions first
    if (additionalPermissions.contains(permission)) {
      return true;
    }

    // Check role-based permissions
    // This would typically check against the user's assigned roles
    // For now, we'll use a simplified approach
    return _getRolePermissions().contains(permission);
  }

  bool hasAnyPermission(List<Permission> requiredPermissions) {
    return requiredPermissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<Permission> requiredPermissions) {
    return requiredPermissions.every((permission) => hasPermission(permission));
  }

  List<Permission> _getRolePermissions() {
    // Simplified implementation: return permissions based on role
    // In a real app, this would be fetched from role records
    List<Permission> perms = <Permission>[];
    switch (role) {
      case UserRole.admin:
        perms = List.from(Permission.values);
        break;
      case UserRole.hr:
        perms = [
          Permission.viewUsers,
          Permission.viewJobs,
          Permission.createJobs,
          Permission.editJobs,
          Permission.viewApplications,
          Permission.reviewApplications,
          Permission.viewHRDashboard,
        ];
        break;
      case UserRole.applicant:
        perms = [
          Permission.viewJobs,
          Permission.submitApplications,
          Permission.viewOwnApplications,
          Permission.editOwnProfile,
          Permission.viewApplicantDashboard,
        ];
        break;
    }

    return perms;
  }

  void addRole(String roleId) {
    if (!assignedRoles.contains(roleId)) {
      assignedRoles.add(roleId);
    }
  }

  void removeRole(String roleId) {
    assignedRoles.remove(roleId);
  }

  void addPermission(Permission permission) {
    if (!additionalPermissions.contains(permission)) {
      additionalPermissions.add(permission);
    }
  }

  void removePermission(Permission permission) {
    additionalPermissions.remove(permission);
  }

  void updateLastLogin() {
    lastLoginAt = DateTime.now();
    loginAttempts = 0;
    lockedUntil = null;
  }

  void incrementLoginAttempts() {
    loginAttempts++;
    if (loginAttempts >= 5) {
      lockedUntil = DateTime.now().add(const Duration(minutes: 30));
    }
  }

  void resetLoginAttempts() {
    loginAttempts = 0;
    lockedUntil = null;
  }

  Map<String, dynamic> toBasicUserModel() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString(),
      'profilePicture': profilePicture,
    };
  }
}

@HiveType(typeId: 14)
enum UserStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  inactive,

  @HiveField(2)
  suspended,

  @HiveField(3)
  pending;

  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.inactive:
        return 'Inactive';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.pending:
        return 'Pending';
    }
  }

  String get description {
    switch (this) {
      case UserStatus.active:
        return 'User account is active and can access the system';
      case UserStatus.inactive:
        return 'User account is inactive and cannot access the system';
      case UserStatus.suspended:
        return 'User account is temporarily suspended';
      case UserStatus.pending:
        return 'User account is pending approval';
    }
  }
}

// Audit Log Model for tracking user actions
@HiveType(typeId: 15)
class UserAuditLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String action;

  @HiveField(3)
  String? targetUserId;

  @HiveField(4)
  String? targetResource;

  @HiveField(5)
  String? targetResourceId;

  @HiveField(6)
  Map<String, dynamic>? details;

  @HiveField(7)
  DateTime timestamp;

  @HiveField(8)
  String ipAddress;

  @HiveField(9)
  String? userAgent;

  @HiveField(10)
  String? sessionId;

  @HiveField(11)
  AuditLogLevel level;

  UserAuditLogModel({
    required this.id,
    required this.userId,
    required this.action,
    this.targetUserId,
    this.targetResource,
    this.targetResourceId,
    this.details,
    required this.timestamp,
    required this.ipAddress,
    this.userAgent,
    this.sessionId,
    this.level = AuditLogLevel.info,
  });

  UserAuditLogModel copyWith({
    String? id,
    String? userId,
    String? action,
    String? targetUserId,
    String? targetResource,
    String? targetResourceId,
    Map<String, dynamic>? details,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
    String? sessionId,
    AuditLogLevel? level,
  }) {
    return UserAuditLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      targetUserId: targetUserId ?? this.targetUserId,
      targetResource: targetResource ?? this.targetResource,
      targetResourceId: targetResourceId ?? this.targetResourceId,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      sessionId: sessionId ?? this.sessionId,
      level: level ?? this.level,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

@HiveType(typeId: 16)
enum AuditLogLevel {
  @HiveField(0)
  info,

  @HiveField(1)
  warning,

  @HiveField(2)
  error,

  @HiveField(3)
  security;

  String get displayName {
    switch (this) {
      case AuditLogLevel.info:
        return 'Info';
      case AuditLogLevel.warning:
        return 'Warning';
      case AuditLogLevel.error:
        return 'Error';
      case AuditLogLevel.security:
        return 'Security';
    }
  }
}
