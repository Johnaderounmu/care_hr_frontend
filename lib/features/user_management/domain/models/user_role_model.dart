import 'package:hive/hive.dart';

// removed unused import of core user_role

part 'user_role_model.g.dart';

@HiveType(typeId: 11)
class UserRoleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<Permission> permissions;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  String createdBy;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  bool isSystemRole;

  @HiveField(9)
  int priority; // Higher priority roles override lower ones

  UserRoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
    this.isSystemRole = false,
    this.priority = 0,
  });

  UserRoleModel copyWith({
    String? id,
    String? name,
    String? description,
    List<Permission>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
    bool? isSystemRole,
    int? priority,
  }) {
    return UserRoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      isSystemRole: isSystemRole ?? this.isSystemRole,
      priority: priority ?? this.priority,
    );
  }

  bool hasPermission(Permission permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<Permission> requiredPermissions) {
    return requiredPermissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<Permission> requiredPermissions) {
    return requiredPermissions.every((permission) => hasPermission(permission));
  }

  void addPermission(Permission permission) {
    if (!permissions.contains(permission)) {
      permissions.add(permission);
    }
  }

  void removePermission(Permission permission) {
    permissions.remove(permission);
  }

  void updatePermissions(List<Permission> newPermissions) {
    permissions = List.from(newPermissions);
  }
}

@HiveType(typeId: 12)
enum Permission {
  // User Management
  @HiveField(0)
  viewUsers,

  @HiveField(1)
  createUsers,

  @HiveField(2)
  editUsers,

  @HiveField(3)
  deleteUsers,

  @HiveField(4)
  manageUserRoles,

  @HiveField(5)
  viewUserPermissions,

  // Job Management
  @HiveField(6)
  viewJobs,

  @HiveField(7)
  createJobs,

  @HiveField(8)
  editJobs,

  @HiveField(9)
  deleteJobs,

  @HiveField(10)
  publishJobs,

  // Application Management
  @HiveField(11)
  viewApplications,

  @HiveField(12)
  reviewApplications,

  @HiveField(13)
  shortlistApplications,

  @HiveField(14)
  rejectApplications,

  @HiveField(15)
  hireApplicants,

  @HiveField(16)
  manageApplicationStatus,

  // Document Management
  @HiveField(17)
  viewDocuments,

  @HiveField(18)
  uploadDocuments,

  @HiveField(19)
  reviewDocuments,

  @HiveField(20)
  approveDocuments,

  @HiveField(21)
  rejectDocuments,

  @HiveField(22)
  deleteDocuments,

  // Interview Management
  @HiveField(23)
  viewInterviews,

  @HiveField(24)
  scheduleInterviews,

  @HiveField(25)
  conductInterviews,

  @HiveField(26)
  provideInterviewFeedback,

  @HiveField(27)
  rescheduleInterviews,

  @HiveField(28)
  cancelInterviews,

  // Reporting
  @HiveField(29)
  viewReports,

  @HiveField(30)
  generateReports,

  @HiveField(31)
  exportReports,

  @HiveField(32)
  viewAnalytics,

  // System Settings
  @HiveField(33)
  viewSystemSettings,

  @HiveField(34)
  editSystemSettings,

  @HiveField(35)
  manageNotifications,

  @HiveField(36)
  manageEmailTemplates,

  @HiveField(37)
  manageSystemUsers,

  @HiveField(38)
  viewAuditLogs,

  @HiveField(39)
  manageBackupRestore,

  // Dashboard Access
  @HiveField(40)
  viewHRDashboard,

  @HiveField(41)
  viewApplicantDashboard,

  @HiveField(42)
  viewAdminDashboard,

  // Profile Management
  @HiveField(43)
  editOwnProfile,

  @HiveField(44)
  viewOwnApplications,

  @HiveField(45)
  submitApplications,

  @HiveField(46)
  withdrawApplications,

  // Communication
  @HiveField(47)
  sendNotifications,

  @HiveField(48)
  sendEmails,

  @HiveField(49)
  manageAnnouncements,

  @HiveField(50)
  viewMessages,

  @HiveField(51)
  sendMessages,

  // Advanced Features
  @HiveField(52)
  bulkOperations,

  @HiveField(53)
  dataImport,

  @HiveField(54)
  dataExport,

  @HiveField(55)
  apiAccess,

  @HiveField(56)
  systemMaintenance;

  String get displayName {
    switch (this) {
      // User Management
      case Permission.viewUsers:
        return 'View Users';
      case Permission.createUsers:
        return 'Create Users';
      case Permission.editUsers:
        return 'Edit Users';
      case Permission.deleteUsers:
        return 'Delete Users';
      case Permission.manageUserRoles:
        return 'Manage User Roles';
      case Permission.viewUserPermissions:
        return 'View User Permissions';

      // Job Management
      case Permission.viewJobs:
        return 'View Jobs';
      case Permission.createJobs:
        return 'Create Jobs';
      case Permission.editJobs:
        return 'Edit Jobs';
      case Permission.deleteJobs:
        return 'Delete Jobs';
      case Permission.publishJobs:
        return 'Publish Jobs';

      // Application Management
      case Permission.viewApplications:
        return 'View Applications';
      case Permission.reviewApplications:
        return 'Review Applications';
      case Permission.shortlistApplications:
        return 'Shortlist Applications';
      case Permission.rejectApplications:
        return 'Reject Applications';
      case Permission.hireApplicants:
        return 'Hire Applicants';
      case Permission.manageApplicationStatus:
        return 'Manage Application Status';

      // Document Management
      case Permission.viewDocuments:
        return 'View Documents';
      case Permission.uploadDocuments:
        return 'Upload Documents';
      case Permission.reviewDocuments:
        return 'Review Documents';
      case Permission.approveDocuments:
        return 'Approve Documents';
      case Permission.rejectDocuments:
        return 'Reject Documents';
      case Permission.deleteDocuments:
        return 'Delete Documents';

      // Interview Management
      case Permission.viewInterviews:
        return 'View Interviews';
      case Permission.scheduleInterviews:
        return 'Schedule Interviews';
      case Permission.conductInterviews:
        return 'Conduct Interviews';
      case Permission.provideInterviewFeedback:
        return 'Provide Interview Feedback';
      case Permission.rescheduleInterviews:
        return 'Reschedule Interviews';
      case Permission.cancelInterviews:
        return 'Cancel Interviews';

      // Reporting
      case Permission.viewReports:
        return 'View Reports';
      case Permission.generateReports:
        return 'Generate Reports';
      case Permission.exportReports:
        return 'Export Reports';
      case Permission.viewAnalytics:
        return 'View Analytics';

      // System Settings
      case Permission.viewSystemSettings:
        return 'View System Settings';
      case Permission.editSystemSettings:
        return 'Edit System Settings';
      case Permission.manageNotifications:
        return 'Manage Notifications';
      case Permission.manageEmailTemplates:
        return 'Manage Email Templates';
      case Permission.manageSystemUsers:
        return 'Manage System Users';
      case Permission.viewAuditLogs:
        return 'View Audit Logs';
      case Permission.manageBackupRestore:
        return 'Manage Backup/Restore';

      // Dashboard Access
      case Permission.viewHRDashboard:
        return 'View HR Dashboard';
      case Permission.viewApplicantDashboard:
        return 'View Applicant Dashboard';
      case Permission.viewAdminDashboard:
        return 'View Admin Dashboard';

      // Profile Management
      case Permission.editOwnProfile:
        return 'Edit Own Profile';
      case Permission.viewOwnApplications:
        return 'View Own Applications';
      case Permission.submitApplications:
        return 'Submit Applications';
      case Permission.withdrawApplications:
        return 'Withdraw Applications';

      // Communication
      case Permission.sendNotifications:
        return 'Send Notifications';
      case Permission.sendEmails:
        return 'Send Emails';
      case Permission.manageAnnouncements:
        return 'Manage Announcements';
      case Permission.viewMessages:
        return 'View Messages';
      case Permission.sendMessages:
        return 'Send Messages';

      // Advanced Features
      case Permission.bulkOperations:
        return 'Bulk Operations';
      case Permission.dataImport:
        return 'Data Import';
      case Permission.dataExport:
        return 'Data Export';
      case Permission.apiAccess:
        return 'API Access';
      case Permission.systemMaintenance:
        return 'System Maintenance';
    }
  }

  String get category {
    switch (this) {
      // User Management
      case Permission.viewUsers:
      case Permission.createUsers:
      case Permission.editUsers:
      case Permission.deleteUsers:
      case Permission.manageUserRoles:
      case Permission.viewUserPermissions:
        return 'User Management';

      // Job Management
      case Permission.viewJobs:
      case Permission.createJobs:
      case Permission.editJobs:
      case Permission.deleteJobs:
      case Permission.publishJobs:
        return 'Job Management';

      // Application Management
      case Permission.viewApplications:
      case Permission.reviewApplications:
      case Permission.shortlistApplications:
      case Permission.rejectApplications:
      case Permission.hireApplicants:
      case Permission.manageApplicationStatus:
        return 'Application Management';

      // Document Management
      case Permission.viewDocuments:
      case Permission.uploadDocuments:
      case Permission.reviewDocuments:
      case Permission.approveDocuments:
      case Permission.rejectDocuments:
      case Permission.deleteDocuments:
        return 'Document Management';

      // Interview Management
      case Permission.viewInterviews:
      case Permission.scheduleInterviews:
      case Permission.conductInterviews:
      case Permission.provideInterviewFeedback:
      case Permission.rescheduleInterviews:
      case Permission.cancelInterviews:
        return 'Interview Management';

      // Reporting
      case Permission.viewReports:
      case Permission.generateReports:
      case Permission.exportReports:
      case Permission.viewAnalytics:
        return 'Reporting';

      // System Settings
      case Permission.viewSystemSettings:
      case Permission.editSystemSettings:
      case Permission.manageNotifications:
      case Permission.manageEmailTemplates:
      case Permission.manageSystemUsers:
      case Permission.viewAuditLogs:
      case Permission.manageBackupRestore:
        return 'System Settings';

      // Dashboard Access
      case Permission.viewHRDashboard:
      case Permission.viewApplicantDashboard:
      case Permission.viewAdminDashboard:
        return 'Dashboard Access';

      // Profile Management
      case Permission.editOwnProfile:
      case Permission.viewOwnApplications:
      case Permission.submitApplications:
      case Permission.withdrawApplications:
        return 'Profile Management';

      // Communication
      case Permission.sendNotifications:
      case Permission.sendEmails:
      case Permission.manageAnnouncements:
      case Permission.viewMessages:
      case Permission.sendMessages:
        return 'Communication';

      // Advanced Features
      case Permission.bulkOperations:
      case Permission.dataImport:
      case Permission.dataExport:
      case Permission.apiAccess:
      case Permission.systemMaintenance:
        return 'Advanced Features';
    }
  }
}

// Predefined Role Types
enum SystemRoleType {
  superAdmin,
  hrAdmin,
  hrManager,
  hrRecruiter,
  interviewer,
  applicant,
  guest;

  String get displayName {
    switch (this) {
      case SystemRoleType.superAdmin:
        return 'Super Administrator';
      case SystemRoleType.hrAdmin:
        return 'HR Administrator';
      case SystemRoleType.hrManager:
        return 'HR Manager';
      case SystemRoleType.hrRecruiter:
        return 'HR Recruiter';
      case SystemRoleType.interviewer:
        return 'Interviewer';
      case SystemRoleType.applicant:
        return 'Applicant';
      case SystemRoleType.guest:
        return 'Guest';
    }
  }

  String get description {
    switch (this) {
      case SystemRoleType.superAdmin:
        return 'Full system access with all permissions';
      case SystemRoleType.hrAdmin:
        return 'Complete HR management capabilities';
      case SystemRoleType.hrManager:
        return 'HR oversight and management functions';
      case SystemRoleType.hrRecruiter:
        return 'Recruitment and hiring responsibilities';
      case SystemRoleType.interviewer:
        return 'Interview scheduling and feedback';
      case SystemRoleType.applicant:
        return 'Job application and profile management';
      case SystemRoleType.guest:
        return 'Limited read-only access';
    }
  }

  List<Permission> get defaultPermissions {
    switch (this) {
      case SystemRoleType.superAdmin:
        return Permission.values;

      case SystemRoleType.hrAdmin:
        return [
          // User Management
          Permission.viewUsers,
          Permission.createUsers,
          Permission.editUsers,
          Permission.deleteUsers,
          Permission.manageUserRoles,
          Permission.viewUserPermissions,

          // Job Management
          Permission.viewJobs,
          Permission.createJobs,
          Permission.editJobs,
          Permission.deleteJobs,
          Permission.publishJobs,

          // Application Management
          Permission.viewApplications,
          Permission.reviewApplications,
          Permission.shortlistApplications,
          Permission.rejectApplications,
          Permission.hireApplicants,
          Permission.manageApplicationStatus,

          // Document Management
          Permission.viewDocuments,
          Permission.reviewDocuments,
          Permission.approveDocuments,
          Permission.rejectDocuments,

          // Interview Management
          Permission.viewInterviews,
          Permission.scheduleInterviews,
          Permission.conductInterviews,
          Permission.provideInterviewFeedback,
          Permission.rescheduleInterviews,
          Permission.cancelInterviews,

          // Reporting
          Permission.viewReports,
          Permission.generateReports,
          Permission.exportReports,
          Permission.viewAnalytics,

          // System Settings
          Permission.viewSystemSettings,
          Permission.editSystemSettings,
          Permission.manageNotifications,
          Permission.manageEmailTemplates,

          // Dashboard Access
          Permission.viewHRDashboard,
          Permission.viewAdminDashboard,

          // Communication
          Permission.sendNotifications,
          Permission.sendEmails,
          Permission.manageAnnouncements,
          Permission.viewMessages,
          Permission.sendMessages,

          // Advanced Features
          Permission.bulkOperations,
          Permission.dataExport,
        ];

      case SystemRoleType.hrManager:
        return [
          // User Management
          Permission.viewUsers,
          Permission.editUsers,

          // Job Management
          Permission.viewJobs,
          Permission.createJobs,
          Permission.editJobs,
          Permission.publishJobs,

          // Application Management
          Permission.viewApplications,
          Permission.reviewApplications,
          Permission.shortlistApplications,
          Permission.rejectApplications,
          Permission.hireApplicants,
          Permission.manageApplicationStatus,

          // Document Management
          Permission.viewDocuments,
          Permission.reviewDocuments,
          Permission.approveDocuments,
          Permission.rejectDocuments,

          // Interview Management
          Permission.viewInterviews,
          Permission.scheduleInterviews,
          Permission.conductInterviews,
          Permission.provideInterviewFeedback,
          Permission.rescheduleInterviews,
          Permission.cancelInterviews,

          // Reporting
          Permission.viewReports,
          Permission.generateReports,
          Permission.exportReports,
          Permission.viewAnalytics,

          // Dashboard Access
          Permission.viewHRDashboard,

          // Communication
          Permission.sendNotifications,
          Permission.sendEmails,
          Permission.viewMessages,
          Permission.sendMessages,
        ];

      case SystemRoleType.hrRecruiter:
        return [
          // Job Management
          Permission.viewJobs,
          Permission.createJobs,
          Permission.editJobs,

          // Application Management
          Permission.viewApplications,
          Permission.reviewApplications,
          Permission.shortlistApplications,
          Permission.rejectApplications,
          Permission.manageApplicationStatus,

          // Document Management
          Permission.viewDocuments,
          Permission.reviewDocuments,

          // Interview Management
          Permission.viewInterviews,
          Permission.scheduleInterviews,
          Permission.conductInterviews,
          Permission.provideInterviewFeedback,

          // Reporting
          Permission.viewReports,
          Permission.generateReports,

          // Dashboard Access
          Permission.viewHRDashboard,

          // Communication
          Permission.sendNotifications,
          Permission.sendEmails,
          Permission.viewMessages,
          Permission.sendMessages,
        ];

      case SystemRoleType.interviewer:
        return [
          // Application Management
          Permission.viewApplications,

          // Document Management
          Permission.viewDocuments,

          // Interview Management
          Permission.viewInterviews,
          Permission.conductInterviews,
          Permission.provideInterviewFeedback,

          // Dashboard Access
          Permission.viewHRDashboard,

          // Communication
          Permission.viewMessages,
          Permission.sendMessages,
        ];

      case SystemRoleType.applicant:
        return [
          // Job Management
          Permission.viewJobs,

          // Document Management
          Permission.viewDocuments,
          Permission.uploadDocuments,

          // Dashboard Access
          Permission.viewApplicantDashboard,

          // Profile Management
          Permission.editOwnProfile,
          Permission.viewOwnApplications,
          Permission.submitApplications,
          Permission.withdrawApplications,

          // Communication
          Permission.viewMessages,
          Permission.sendMessages,
        ];

      case SystemRoleType.guest:
        return [
          // Job Management
          Permission.viewJobs,

          // Dashboard Access
          Permission.viewApplicantDashboard,
        ];
    }
  }
}

