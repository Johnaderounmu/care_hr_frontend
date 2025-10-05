// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobModelAdapter extends TypeAdapter<JobModel> {
  @override
  final int typeId = 26;

  @override
  JobModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobModel(
      id: fields[0] as String,
      title: fields[1] as String,
      department: fields[2] as String,
      location: fields[3] as String,
      employmentType: fields[4] as String,
      experienceLevel: fields[5] as String,
      description: fields[6] as String,
      requirements: (fields[7] as List).cast<String>(),
      responsibilities: (fields[8] as List).cast<String>(),
      benefits: (fields[9] as List).cast<String>(),
      salaryRange: fields[10] as String,
      postedDate: fields[11] as DateTime,
      applicationDeadline: fields[12] as DateTime,
      status: fields[13] as JobStatus,
      postedBy: fields[14] as String,
      maxApplications: fields[15] as int,
      currentApplications: fields[16] as int,
      isRemote: fields[17] as bool,
      skills: (fields[18] as List).cast<String>(),
      companyName: fields[19] as String,
      contactEmail: fields[20] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JobModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.department)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.employmentType)
      ..writeByte(5)
      ..write(obj.experienceLevel)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.requirements)
      ..writeByte(8)
      ..write(obj.responsibilities)
      ..writeByte(9)
      ..write(obj.benefits)
      ..writeByte(10)
      ..write(obj.salaryRange)
      ..writeByte(11)
      ..write(obj.postedDate)
      ..writeByte(12)
      ..write(obj.applicationDeadline)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.postedBy)
      ..writeByte(15)
      ..write(obj.maxApplications)
      ..writeByte(16)
      ..write(obj.currentApplications)
      ..writeByte(17)
      ..write(obj.isRemote)
      ..writeByte(18)
      ..write(obj.skills)
      ..writeByte(19)
      ..write(obj.companyName)
      ..writeByte(20)
      ..write(obj.contactEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JobStatusAdapter extends TypeAdapter<JobStatus> {
  @override
  final int typeId = 27;

  @override
  JobStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return JobStatus.draft;
      case 1:
        return JobStatus.active;
      case 2:
        return JobStatus.closed;
      case 3:
        return JobStatus.expired;
      default:
        return JobStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, JobStatus obj) {
    switch (obj) {
      case JobStatus.draft:
        writer.writeByte(0);
        break;
      case JobStatus.active:
        writer.writeByte(1);
        break;
      case JobStatus.closed:
        writer.writeByte(2);
        break;
      case JobStatus.expired:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
