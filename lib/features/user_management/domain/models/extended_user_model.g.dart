// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extended_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtendedUserModelAdapter extends TypeAdapter<ExtendedUserModel> {
  @override
  final int typeId = 13;

  @override
  ExtendedUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtendedUserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      phoneNumber: fields[4] as String?,
      profilePicture: fields[5] as String?,
      role: fields[6] as UserRole,
      assignedRoles: (fields[7] as List).cast<String>(),
      additionalPermissions: (fields[8] as List).cast<Permission>(),
      status: fields[9] as UserStatus,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      lastLoginAt: fields[12] as DateTime?,
      createdBy: fields[13] as String?,
      department: fields[14] as String?,
      jobTitle: fields[15] as String?,
      employeeId: fields[16] as String?,
      hireDate: fields[17] as DateTime?,
      managerId: fields[18] as String?,
      teamMemberIds: (fields[19] as List).cast<String>(),
      preferences: (fields[20] as Map?)?.cast<String, dynamic>(),
      skills: (fields[21] as List).cast<String>(),
      bio: fields[22] as String?,
      linkedinUrl: fields[23] as String?,
      githubUrl: fields[24] as String?,
      portfolioUrl: fields[25] as String?,
      isEmailVerified: fields[26] as bool,
      isPhoneVerified: fields[27] as bool,
      twoFactorEnabled: fields[28] as bool,
      passwordChangedAt: fields[29] as DateTime?,
      loginAttempts: fields[30] as int,
      lockedUntil: fields[31] as DateTime?,
      ipAddresses: (fields[32] as List).cast<String>(),
      timezone: fields[33] as String?,
      language: fields[34] as String?,
      notificationsEnabled: fields[35] as bool,
      notificationPreferences: (fields[36] as Map).cast<String, bool>(),
      tags: (fields[37] as List).cast<String>(),
      metadata: (fields[38] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedUserModel obj) {
    writer
      ..writeByte(39)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.profilePicture)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.assignedRoles)
      ..writeByte(8)
      ..write(obj.additionalPermissions)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.lastLoginAt)
      ..writeByte(13)
      ..write(obj.createdBy)
      ..writeByte(14)
      ..write(obj.department)
      ..writeByte(15)
      ..write(obj.jobTitle)
      ..writeByte(16)
      ..write(obj.employeeId)
      ..writeByte(17)
      ..write(obj.hireDate)
      ..writeByte(18)
      ..write(obj.managerId)
      ..writeByte(19)
      ..write(obj.teamMemberIds)
      ..writeByte(20)
      ..write(obj.preferences)
      ..writeByte(21)
      ..write(obj.skills)
      ..writeByte(22)
      ..write(obj.bio)
      ..writeByte(23)
      ..write(obj.linkedinUrl)
      ..writeByte(24)
      ..write(obj.githubUrl)
      ..writeByte(25)
      ..write(obj.portfolioUrl)
      ..writeByte(26)
      ..write(obj.isEmailVerified)
      ..writeByte(27)
      ..write(obj.isPhoneVerified)
      ..writeByte(28)
      ..write(obj.twoFactorEnabled)
      ..writeByte(29)
      ..write(obj.passwordChangedAt)
      ..writeByte(30)
      ..write(obj.loginAttempts)
      ..writeByte(31)
      ..write(obj.lockedUntil)
      ..writeByte(32)
      ..write(obj.ipAddresses)
      ..writeByte(33)
      ..write(obj.timezone)
      ..writeByte(34)
      ..write(obj.language)
      ..writeByte(35)
      ..write(obj.notificationsEnabled)
      ..writeByte(36)
      ..write(obj.notificationPreferences)
      ..writeByte(37)
      ..write(obj.tags)
      ..writeByte(38)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAuditLogModelAdapter extends TypeAdapter<UserAuditLogModel> {
  @override
  final int typeId = 15;

  @override
  UserAuditLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAuditLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      action: fields[2] as String,
      targetUserId: fields[3] as String?,
      targetResource: fields[4] as String?,
      targetResourceId: fields[5] as String?,
      details: (fields[6] as Map?)?.cast<String, dynamic>(),
      timestamp: fields[7] as DateTime,
      ipAddress: fields[8] as String,
      userAgent: fields[9] as String?,
      sessionId: fields[10] as String?,
      level: fields[11] as AuditLogLevel,
    );
  }

  @override
  void write(BinaryWriter writer, UserAuditLogModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.targetUserId)
      ..writeByte(4)
      ..write(obj.targetResource)
      ..writeByte(5)
      ..write(obj.targetResourceId)
      ..writeByte(6)
      ..write(obj.details)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.ipAddress)
      ..writeByte(9)
      ..write(obj.userAgent)
      ..writeByte(10)
      ..write(obj.sessionId)
      ..writeByte(11)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAuditLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 14;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.active;
      case 1:
        return UserStatus.inactive;
      case 2:
        return UserStatus.suspended;
      case 3:
        return UserStatus.pending;
      default:
        return UserStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.active:
        writer.writeByte(0);
        break;
      case UserStatus.inactive:
        writer.writeByte(1);
        break;
      case UserStatus.suspended:
        writer.writeByte(2);
        break;
      case UserStatus.pending:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuditLogLevelAdapter extends TypeAdapter<AuditLogLevel> {
  @override
  final int typeId = 16;

  @override
  AuditLogLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AuditLogLevel.info;
      case 1:
        return AuditLogLevel.warning;
      case 2:
        return AuditLogLevel.error;
      case 3:
        return AuditLogLevel.security;
      default:
        return AuditLogLevel.info;
    }
  }

  @override
  void write(BinaryWriter writer, AuditLogLevel obj) {
    switch (obj) {
      case AuditLogLevel.info:
        writer.writeByte(0);
        break;
      case AuditLogLevel.warning:
        writer.writeByte(1);
        break;
      case AuditLogLevel.error:
        writer.writeByte(2);
        break;
      case AuditLogLevel.security:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
