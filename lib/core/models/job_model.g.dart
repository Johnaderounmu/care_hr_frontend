// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobModelAdapter extends TypeAdapter<JobModel> {
  @override
  final int typeId = 10;

  @override
  JobModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      requirements: fields[3] as String?,
      department: fields[4] as String,
      location: fields[5] as String,
      type: fields[6] as String,
      status: fields[7] as String,
      salaryRange: fields[8] as String?,
      experienceLevel: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime?,
      createdById: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JobModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.requirements)
      ..writeByte(4)
      ..write(obj.department)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.salaryRange)
      ..writeByte(9)
      ..write(obj.experienceLevel)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.createdById);
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
