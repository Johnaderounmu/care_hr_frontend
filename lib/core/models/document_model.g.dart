// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 11;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      filename: fields[1] as String,
      originalName: fields[2] as String,
      mimeType: fields[3] as String,
      size: fields[4] as int,
      url: fields[5] as String,
      type: fields[6] as String,
      status: fields[7] as String,
      description: fields[8] as String?,
      reviewNotes: fields[9] as String?,
      uploadedById: fields[10] as String,
      jobApplicationId: fields[11] as String?,
      reviewedById: fields[12] as String?,
      reviewedAt: fields[13] as DateTime?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filename)
      ..writeByte(2)
      ..write(obj.originalName)
      ..writeByte(3)
      ..write(obj.mimeType)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.reviewNotes)
      ..writeByte(10)
      ..write(obj.uploadedById)
      ..writeByte(11)
      ..write(obj.jobApplicationId)
      ..writeByte(12)
      ..write(obj.reviewedById)
      ..writeByte(13)
      ..write(obj.reviewedAt)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
