import 'package:hive/hive.dart';

part 'user_role.g.dart';

@HiveType(typeId: 36)
enum UserRole {
  @HiveField(0)
  admin,

  @HiveField(1)
  hr,

  @HiveField(2)
  applicant,
}

extension UserRoleParsing on UserRole {
  String get asString {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.hr:
        return 'hr';
      case UserRole.applicant:
        return 'applicant';
    }
  }

  static UserRole fromString(String s) {
    final normalized = s.toLowerCase();
    if (normalized.contains('admin')) return UserRole.admin;
    if (normalized.contains('hr')) return UserRole.hr;
    return UserRole.applicant;
  }
}
