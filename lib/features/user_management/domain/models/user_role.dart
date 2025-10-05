enum UserRole { admin, hr, applicant }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.hr:
        return 'hr';
      case UserRole.applicant:
        return 'applicant';
    }
  }
}
