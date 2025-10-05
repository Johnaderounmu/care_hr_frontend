import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/extended_user_model.dart';
import '../../domain/models/user_role_model.dart';
import '../../../../core/models/user_role.dart';

class UserManagementService {
  static const String _usersBoxName = 'extended_users';
  static const String _rolesBoxName = 'user_roles';
  static const String _auditLogBoxName = 'user_audit_logs';

  static Box<ExtendedUserModel>? _usersBox;
  static Box<UserRoleModel>? _rolesBox;
  static Box<UserAuditLogModel>? _auditLogBox;

  static Future<void> init() async {
    _usersBox = await Hive.openBox<ExtendedUserModel>(_usersBoxName);
    _rolesBox = await Hive.openBox<UserRoleModel>(_rolesBoxName);
    _auditLogBox = await Hive.openBox<UserAuditLogModel>(_auditLogBoxName);
  }

  static Box<ExtendedUserModel> get usersBox {
    if (_usersBox == null) {
      throw Exception(
          'UserManagementService not initialized. Call UserManagementService.init() first.');
    }
    return _usersBox!;
  }

  static Box<UserRoleModel> get rolesBox {
    if (_rolesBox == null) {
      throw Exception(
          'UserManagementService not initialized. Call UserManagementService.init() first.');
    }
    return _rolesBox!;
  }

  static Box<UserAuditLogModel> get auditLogBox {
    if (_auditLogBox == null) {
      throw Exception(
          'UserManagementService not initialized. Call UserManagementService.init() first.');
    }
    return _auditLogBox!;
  }

  // User Management
  static Future<String> createUser(ExtendedUserModel user) async {
    final userWithId = user.copyWith(id: const Uuid().v4());
    await usersBox.put(userWithId.id, userWithId);
    await _logUserAction(userWithId.id, 'USER_CREATED', details: {
      'email': userWithId.email,
      'role': userWithId.role.toString(),
      'status': userWithId.status.toString(),
    });
    return userWithId.id;
  }

  static Future<ExtendedUserModel?> getUser(String id) async {
    return usersBox.get(id);
  }

  static Future<ExtendedUserModel?> getUserByEmail(String email) async {
    return usersBox.values.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
  }

  static Future<List<ExtendedUserModel>> getAllUsers() async {
    return usersBox.values.toList();
  }

  static Future<List<ExtendedUserModel>> getUsersByRole(UserRole role) async {
    return usersBox.values.where((user) => user.role == role).toList();
  }

  static Future<List<ExtendedUserModel>> getUsersByStatus(
      UserStatus status) async {
    return usersBox.values.where((user) => user.status == status).toList();
  }

  static Future<List<ExtendedUserModel>> getUsersByDepartment(
      String department) async {
    return usersBox.values
        .where((user) => user.department == department)
        .toList();
  }

  static Future<bool> updateUser(ExtendedUserModel user) async {
    final existingUser = await getUser(user.id);
    if (existingUser == null) return false;

    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await usersBox.put(updatedUser.id, updatedUser);

    await _logUserAction(user.id, 'USER_UPDATED', details: {
      'changes': _getUserChanges(existingUser, updatedUser),
    });

    return true;
  }

  static Future<bool> deleteUser(String userId) async {
    final user = await getUser(userId);
    if (user == null) return false;

    await usersBox.delete(userId);
    await _logUserAction(userId, 'USER_DELETED', details: {
      'email': user.email,
      'role': user.role.toString(),
    });

    return true;
  }

  static Future<bool> suspendUser(String userId, String reason) async {
    final user = await getUser(userId);
    if (user == null) return false;

    final updatedUser = user.copyWith(
      status: UserStatus.suspended,
      updatedAt: DateTime.now(),
      metadata: {
        ...user.metadata ?? {},
        'suspension_reason': reason,
        'suspended_at': DateTime.now().toIso8601String(),
      },
    );

    await usersBox.put(userId, updatedUser);
    await _logUserAction(userId, 'USER_SUSPENDED', details: {
      'reason': reason,
      'suspended_at': DateTime.now().toIso8601String(),
    });

    return true;
  }

  static Future<bool> activateUser(String userId) async {
    final user = await getUser(userId);
    if (user == null) return false;

    final updatedUser = user.copyWith(
      status: UserStatus.active,
      updatedAt: DateTime.now(),
      metadata: {
        ...user.metadata ?? {},
        'activated_at': DateTime.now().toIso8601String(),
      },
    );

    await usersBox.put(userId, updatedUser);
    await _logUserAction(userId, 'USER_ACTIVATED');

    return true;
  }

  static Future<bool> updateUserPermissions(
      String userId, List<Permission> permissions) async {
    final user = await getUser(userId);
    if (user == null) return false;

    final updatedUser = user.copyWith(
      additionalPermissions: permissions,
      updatedAt: DateTime.now(),
    );

    await usersBox.put(userId, updatedUser);
    await _logUserAction(userId, 'USER_PERMISSIONS_UPDATED', details: {
      'permissions': permissions.map((p) => p.toString()).toList(),
    });

    return true;
  }

  static Future<bool> assignRole(String userId, String roleId) async {
    final user = await getUser(userId);
    if (user == null) return false;

    final updatedUser = user.copyWith(
      assignedRoles: [...user.assignedRoles, roleId],
      updatedAt: DateTime.now(),
    );

    await usersBox.put(userId, updatedUser);
    await _logUserAction(userId, 'ROLE_ASSIGNED', details: {
      'role_id': roleId,
    });

    return true;
  }

  static Future<bool> removeRole(String userId, String roleId) async {
    final user = await getUser(userId);
    if (user == null) return false;

    final updatedRoles = List<String>.from(user.assignedRoles);
    updatedRoles.remove(roleId);

    final updatedUser = user.copyWith(
      assignedRoles: updatedRoles,
      updatedAt: DateTime.now(),
    );

    await usersBox.put(userId, updatedUser);
    await _logUserAction(userId, 'ROLE_REMOVED', details: {
      'role_id': roleId,
    });

    return true;
  }

  // Role Management
  static Future<String> createRole(UserRoleModel role) async {
    final roleWithId = role.copyWith(id: const Uuid().v4());
    await rolesBox.put(roleWithId.id, roleWithId);
    await _logUserAction('system', 'ROLE_CREATED', details: {
      'role_name': roleWithId.name,
      'role_id': roleWithId.id,
    });
    return roleWithId.id;
  }

  static Future<UserRoleModel?> getRole(String id) async {
    return rolesBox.get(id);
  }

  static Future<List<UserRoleModel>> getAllRoles() async {
    return rolesBox.values.toList();
  }

  static Future<List<UserRoleModel>> getActiveRoles() async {
    return rolesBox.values.where((role) => role.isActive).toList();
  }

  static Future<bool> updateRole(UserRoleModel role) async {
    final updatedRole = role.copyWith(updatedAt: DateTime.now());
    await rolesBox.put(updatedRole.id, updatedRole);
    await _logUserAction('system', 'ROLE_UPDATED', details: {
      'role_name': updatedRole.name,
      'role_id': updatedRole.id,
    });
    return true;
  }

  static Future<bool> deleteRole(String roleId) async {
    final role = await getRole(roleId);
    if (role == null) return false;

    if (role.isSystemRole) {
      throw Exception('Cannot delete system roles');
    }

    await rolesBox.delete(roleId);
    await _logUserAction('system', 'ROLE_DELETED', details: {
      'role_name': role.name,
      'role_id': roleId,
    });

    return true;
  }

  // Audit Log Management
  static Future<List<UserAuditLogModel>> getAuditLogs({
    String? userId,
    String? action,
    AuditLogLevel? level,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    var logs = auditLogBox.values.toList();

    if (userId != null) {
      logs = logs.where((log) => log.userId == userId).toList();
    }

    if (action != null) {
      logs = logs.where((log) => log.action.contains(action)).toList();
    }

    if (level != null) {
      logs = logs.where((log) => log.level == level).toList();
    }

    if (fromDate != null) {
      logs = logs.where((log) => log.timestamp.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      logs = logs.where((log) => log.timestamp.isBefore(toDate)).toList();
    }

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null) {
      logs = logs.take(limit).toList();
    }

    return logs;
  }

  static Future<void> _logUserAction(
    String userId,
    String action, {
    String? targetUserId,
    String? targetResource,
    String? targetResourceId,
    Map<String, dynamic>? details,
    AuditLogLevel level = AuditLogLevel.info,
  }) async {
    final log = UserAuditLogModel(
      id: const Uuid().v4(),
      userId: userId,
      action: action,
      targetUserId: targetUserId,
      targetResource: targetResource,
      targetResourceId: targetResourceId,
      details: details,
      timestamp: DateTime.now(),
      ipAddress: '127.0.0.1', // In a real app, get from request
      level: level,
    );

    await auditLogBox.put(log.id, log);
  }

  static Map<String, dynamic> _getUserChanges(
      ExtendedUserModel oldUser, ExtendedUserModel newUser) {
    final changes = <String, dynamic>{};

    if (oldUser.email != newUser.email) {
      changes['email'] = {'old': oldUser.email, 'new': newUser.email};
    }

    if (oldUser.firstName != newUser.firstName) {
      changes['firstName'] = {
        'old': oldUser.firstName,
        'new': newUser.firstName
      };
    }

    if (oldUser.lastName != newUser.lastName) {
      changes['lastName'] = {'old': oldUser.lastName, 'new': newUser.lastName};
    }

    if (oldUser.status != newUser.status) {
      changes['status'] = {
        'old': oldUser.status.toString(),
        'new': newUser.status.toString()
      };
    }

    if (oldUser.role != newUser.role) {
      changes['role'] = {
        'old': oldUser.role.toString(),
        'new': newUser.role.toString()
      };
    }

    if (oldUser.department != newUser.department) {
      changes['department'] = {
        'old': oldUser.department,
        'new': newUser.department
      };
    }

    if (oldUser.jobTitle != newUser.jobTitle) {
      changes['jobTitle'] = {'old': oldUser.jobTitle, 'new': newUser.jobTitle};
    }

    return changes;
  }

  // Statistics
  static Future<Map<String, int>> getUserStats() async {
    final users = await getAllUsers();
    return {
      'total': users.length,
      'active': users.where((user) => user.status == UserStatus.active).length,
      'inactive':
          users.where((user) => user.status == UserStatus.inactive).length,
      'suspended':
          users.where((user) => user.status == UserStatus.suspended).length,
      'pending':
          users.where((user) => user.status == UserStatus.pending).length,
      'hr': users.where((user) => user.role == UserRole.hr).length,
      'admin': users.where((user) => user.role == UserRole.admin).length,
      'applicant':
          users.where((user) => user.role == UserRole.applicant).length,
    };
  }

  static Future<Map<String, int>> getDepartmentStats() async {
    final users = await getAllUsers();
    final departmentStats = <String, int>{};

    for (final user in users) {
      if (user.department != null) {
        departmentStats[user.department!] =
            (departmentStats[user.department!] ?? 0) + 1;
      }
    }

    return departmentStats;
  }

  // Search and Filter
  static Future<List<ExtendedUserModel>> searchUsers(String query) async {
    final lowerQuery = query.toLowerCase();
    return usersBox.values.where((user) {
      return user.firstName.toLowerCase().contains(lowerQuery) ||
          user.lastName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.department?.toLowerCase().contains(lowerQuery) == true ||
          user.jobTitle?.toLowerCase().contains(lowerQuery) == true ||
          user.skills.any((skill) => skill.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static Future<List<ExtendedUserModel>> filterUsers({
    UserRole? role,
    UserStatus? status,
    String? department,
    String? managerId,
    bool? isActive,
  }) async {
    return usersBox.values.where((user) {
      if (role != null && user.role != role) return false;
      if (status != null && user.status != status) return false;
      if (department != null && user.department != department) return false;
      if (managerId != null && user.managerId != managerId) return false;
      if (isActive != null && user.isActive != isActive) return false;
      return true;
    }).toList();
  }

  // Initialize sample data
  static Future<void> initializeSampleData() async {
    if (usersBox.isNotEmpty && rolesBox.isNotEmpty) return;

    // Create system roles
    final systemRoles = [
      UserRoleModel(
        id: 'role_super_admin',
        name: 'Super Administrator',
        description: 'Full system access with all permissions',
        permissions: Permission.values,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        isSystemRole: true,
        priority: 100,
      ),
      UserRoleModel(
        id: 'role_hr_admin',
        name: 'HR Administrator',
        description: 'Complete HR management capabilities',
        permissions: SystemRoleType.hrAdmin.defaultPermissions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        isSystemRole: true,
        priority: 90,
      ),
      UserRoleModel(
        id: 'role_hr_manager',
        name: 'HR Manager',
        description: 'HR oversight and management functions',
        permissions: SystemRoleType.hrManager.defaultPermissions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        isSystemRole: true,
        priority: 80,
      ),
      UserRoleModel(
        id: 'role_hr_recruiter',
        name: 'HR Recruiter',
        description: 'Recruitment and hiring responsibilities',
        permissions: SystemRoleType.hrRecruiter.defaultPermissions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        isSystemRole: true,
        priority: 70,
      ),
      UserRoleModel(
        id: 'role_interviewer',
        name: 'Interviewer',
        description: 'Interview scheduling and feedback',
        permissions: SystemRoleType.interviewer.defaultPermissions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        isSystemRole: true,
        priority: 60,
      ),
      UserRoleModel(
        id: 'role_applicant',
        name: 'Applicant',
        description: 'Job application and profile management',
        permissions: SystemRoleType.applicant.defaultPermissions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
        isSystemRole: true,
        priority: 50,
      ),
    ];

    for (final role in systemRoles) {
      await rolesBox.put(role.id, role);
    }

    // Create sample users
    final sampleUsers = [
      ExtendedUserModel(
        id: 'user_admin_1',
        email: 'admin@carehr.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        assignedRoles: ['role_super_admin'],
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        department: 'IT',
        jobTitle: 'System Administrator',
        employeeId: 'EMP001',
        hireDate: DateTime.now().subtract(const Duration(days: 365)),
        skills: ['System Administration', 'Security', 'Database Management'],
        isEmailVerified: true,
        createdBy: 'system',
      ),
      ExtendedUserModel(
        id: 'user_hr_1',
        email: 'hr.manager@carehr.com',
        firstName: 'Sarah',
        lastName: 'Johnson',
        role: UserRole.hr,
        assignedRoles: ['role_hr_manager'],
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        department: 'Human Resources',
        jobTitle: 'HR Manager',
        employeeId: 'EMP002',
        hireDate: DateTime.now().subtract(const Duration(days: 180)),
        skills: ['HR Management', 'Recruitment', 'Employee Relations'],
        isEmailVerified: true,
        createdBy: 'admin@carehr.com',
      ),
      ExtendedUserModel(
        id: 'user_hr_2',
        email: 'recruiter@carehr.com',
        firstName: 'Michael',
        lastName: 'Chen',
        role: UserRole.hr,
        assignedRoles: ['role_hr_recruiter'],
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        department: 'Human Resources',
        jobTitle: 'Senior Recruiter',
        employeeId: 'EMP003',
        hireDate: DateTime.now().subtract(const Duration(days: 90)),
        skills: ['Recruitment', 'Interviewing', 'Talent Acquisition'],
        isEmailVerified: true,
        createdBy: 'hr.manager@carehr.com',
      ),
      ExtendedUserModel(
        id: 'user_applicant_1',
        email: 'john.smith@email.com',
        firstName: 'John',
        lastName: 'Smith',
        role: UserRole.applicant,
        assignedRoles: ['role_applicant'],
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        skills: ['Flutter', 'Dart', 'Mobile Development', 'REST API'],
        isEmailVerified: true,
      ),
      ExtendedUserModel(
        id: 'user_applicant_2',
        email: 'emily.davis@email.com',
        firstName: 'Emily',
        lastName: 'Davis',
        role: UserRole.applicant,
        assignedRoles: ['role_applicant'],
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        skills: ['UX Design', 'UI Design', 'Figma', 'User Research'],
        isEmailVerified: true,
      ),
    ];

    for (final user in sampleUsers) {
      await usersBox.put(user.id, user);
    }
  }

  static Future<void> close() async {
    await _usersBox?.close();
    await _rolesBox?.close();
    await _auditLogBox?.close();
  }
}
