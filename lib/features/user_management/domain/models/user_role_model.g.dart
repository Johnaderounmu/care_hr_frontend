// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRoleModelAdapter extends TypeAdapter<UserRoleModel> {
  @override
  final int typeId = 11;

  @override
  UserRoleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserRoleModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      permissions: (fields[3] as List).cast<Permission>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      createdBy: fields[6] as String,
      isActive: fields[7] as bool,
      isSystemRole: fields[8] as bool,
      priority: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserRoleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.permissions)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.isSystemRole)
      ..writeByte(9)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PermissionAdapter extends TypeAdapter<Permission> {
  @override
  final int typeId = 12;

  @override
  Permission read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Permission.viewUsers;
      case 1:
        return Permission.createUsers;
      case 2:
        return Permission.editUsers;
      case 3:
        return Permission.deleteUsers;
      case 4:
        return Permission.manageUserRoles;
      case 5:
        return Permission.viewUserPermissions;
      case 6:
        return Permission.viewJobs;
      case 7:
        return Permission.createJobs;
      case 8:
        return Permission.editJobs;
      case 9:
        return Permission.deleteJobs;
      case 10:
        return Permission.publishJobs;
      case 11:
        return Permission.viewApplications;
      case 12:
        return Permission.reviewApplications;
      case 13:
        return Permission.shortlistApplications;
      case 14:
        return Permission.rejectApplications;
      case 15:
        return Permission.hireApplicants;
      case 16:
        return Permission.manageApplicationStatus;
      case 17:
        return Permission.viewDocuments;
      case 18:
        return Permission.uploadDocuments;
      case 19:
        return Permission.reviewDocuments;
      case 20:
        return Permission.approveDocuments;
      case 21:
        return Permission.rejectDocuments;
      case 22:
        return Permission.deleteDocuments;
      case 23:
        return Permission.viewInterviews;
      case 24:
        return Permission.scheduleInterviews;
      case 25:
        return Permission.conductInterviews;
      case 26:
        return Permission.provideInterviewFeedback;
      case 27:
        return Permission.rescheduleInterviews;
      case 28:
        return Permission.cancelInterviews;
      case 29:
        return Permission.viewReports;
      case 30:
        return Permission.generateReports;
      case 31:
        return Permission.exportReports;
      case 32:
        return Permission.viewAnalytics;
      case 33:
        return Permission.viewSystemSettings;
      case 34:
        return Permission.editSystemSettings;
      case 35:
        return Permission.manageNotifications;
      case 36:
        return Permission.manageEmailTemplates;
      case 37:
        return Permission.manageSystemUsers;
      case 38:
        return Permission.viewAuditLogs;
      case 39:
        return Permission.manageBackupRestore;
      case 40:
        return Permission.viewHRDashboard;
      case 41:
        return Permission.viewApplicantDashboard;
      case 42:
        return Permission.viewAdminDashboard;
      case 43:
        return Permission.editOwnProfile;
      case 44:
        return Permission.viewOwnApplications;
      case 45:
        return Permission.submitApplications;
      case 46:
        return Permission.withdrawApplications;
      case 47:
        return Permission.sendNotifications;
      case 48:
        return Permission.sendEmails;
      case 49:
        return Permission.manageAnnouncements;
      case 50:
        return Permission.viewMessages;
      case 51:
        return Permission.sendMessages;
      case 52:
        return Permission.bulkOperations;
      case 53:
        return Permission.dataImport;
      case 54:
        return Permission.dataExport;
      case 55:
        return Permission.apiAccess;
      case 56:
        return Permission.systemMaintenance;
      default:
        return Permission.viewUsers;
    }
  }

  @override
  void write(BinaryWriter writer, Permission obj) {
    switch (obj) {
      case Permission.viewUsers:
        writer.writeByte(0);
        break;
      case Permission.createUsers:
        writer.writeByte(1);
        break;
      case Permission.editUsers:
        writer.writeByte(2);
        break;
      case Permission.deleteUsers:
        writer.writeByte(3);
        break;
      case Permission.manageUserRoles:
        writer.writeByte(4);
        break;
      case Permission.viewUserPermissions:
        writer.writeByte(5);
        break;
      case Permission.viewJobs:
        writer.writeByte(6);
        break;
      case Permission.createJobs:
        writer.writeByte(7);
        break;
      case Permission.editJobs:
        writer.writeByte(8);
        break;
      case Permission.deleteJobs:
        writer.writeByte(9);
        break;
      case Permission.publishJobs:
        writer.writeByte(10);
        break;
      case Permission.viewApplications:
        writer.writeByte(11);
        break;
      case Permission.reviewApplications:
        writer.writeByte(12);
        break;
      case Permission.shortlistApplications:
        writer.writeByte(13);
        break;
      case Permission.rejectApplications:
        writer.writeByte(14);
        break;
      case Permission.hireApplicants:
        writer.writeByte(15);
        break;
      case Permission.manageApplicationStatus:
        writer.writeByte(16);
        break;
      case Permission.viewDocuments:
        writer.writeByte(17);
        break;
      case Permission.uploadDocuments:
        writer.writeByte(18);
        break;
      case Permission.reviewDocuments:
        writer.writeByte(19);
        break;
      case Permission.approveDocuments:
        writer.writeByte(20);
        break;
      case Permission.rejectDocuments:
        writer.writeByte(21);
        break;
      case Permission.deleteDocuments:
        writer.writeByte(22);
        break;
      case Permission.viewInterviews:
        writer.writeByte(23);
        break;
      case Permission.scheduleInterviews:
        writer.writeByte(24);
        break;
      case Permission.conductInterviews:
        writer.writeByte(25);
        break;
      case Permission.provideInterviewFeedback:
        writer.writeByte(26);
        break;
      case Permission.rescheduleInterviews:
        writer.writeByte(27);
        break;
      case Permission.cancelInterviews:
        writer.writeByte(28);
        break;
      case Permission.viewReports:
        writer.writeByte(29);
        break;
      case Permission.generateReports:
        writer.writeByte(30);
        break;
      case Permission.exportReports:
        writer.writeByte(31);
        break;
      case Permission.viewAnalytics:
        writer.writeByte(32);
        break;
      case Permission.viewSystemSettings:
        writer.writeByte(33);
        break;
      case Permission.editSystemSettings:
        writer.writeByte(34);
        break;
      case Permission.manageNotifications:
        writer.writeByte(35);
        break;
      case Permission.manageEmailTemplates:
        writer.writeByte(36);
        break;
      case Permission.manageSystemUsers:
        writer.writeByte(37);
        break;
      case Permission.viewAuditLogs:
        writer.writeByte(38);
        break;
      case Permission.manageBackupRestore:
        writer.writeByte(39);
        break;
      case Permission.viewHRDashboard:
        writer.writeByte(40);
        break;
      case Permission.viewApplicantDashboard:
        writer.writeByte(41);
        break;
      case Permission.viewAdminDashboard:
        writer.writeByte(42);
        break;
      case Permission.editOwnProfile:
        writer.writeByte(43);
        break;
      case Permission.viewOwnApplications:
        writer.writeByte(44);
        break;
      case Permission.submitApplications:
        writer.writeByte(45);
        break;
      case Permission.withdrawApplications:
        writer.writeByte(46);
        break;
      case Permission.sendNotifications:
        writer.writeByte(47);
        break;
      case Permission.sendEmails:
        writer.writeByte(48);
        break;
      case Permission.manageAnnouncements:
        writer.writeByte(49);
        break;
      case Permission.viewMessages:
        writer.writeByte(50);
        break;
      case Permission.sendMessages:
        writer.writeByte(51);
        break;
      case Permission.bulkOperations:
        writer.writeByte(52);
        break;
      case Permission.dataImport:
        writer.writeByte(53);
        break;
      case Permission.dataExport:
        writer.writeByte(54);
        break;
      case Permission.apiAccess:
        writer.writeByte(55);
        break;
      case Permission.systemMaintenance:
        writer.writeByte(56);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
