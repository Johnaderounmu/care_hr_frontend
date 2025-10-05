// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 1;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      filePath: fields[3] as String,
      fileUrl: fields[4] as String,
      fileSize: fields[5] as int,
      mimeType: fields[6] as String,
      status: fields[7] as DocumentStatus,
      applicantId: fields[8] as String?,
      reviewerId: fields[9] as String?,
      uploadedAt: fields[10] as DateTime,
      reviewedAt: fields[11] as DateTime?,
      expiresAt: fields[12] as DateTime?,
      rejectionReason: fields[13] as String?,
      notes: fields[14] as String?,
      metadata: (fields[15] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.fileUrl)
      ..writeByte(5)
      ..write(obj.fileSize)
      ..writeByte(6)
      ..write(obj.mimeType)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.applicantId)
      ..writeByte(9)
      ..write(obj.reviewerId)
      ..writeByte(10)
      ..write(obj.uploadedAt)
      ..writeByte(11)
      ..write(obj.reviewedAt)
      ..writeByte(12)
      ..write(obj.expiresAt)
      ..writeByte(13)
      ..write(obj.rejectionReason)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.metadata);
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

class DocumentStatusAdapter extends TypeAdapter<DocumentStatus> {
  @override
  final int typeId = 2;

  @override
  DocumentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentStatus.uploaded;
      case 1:
        return DocumentStatus.pending;
      case 2:
        return DocumentStatus.reviewed;
      case 3:
        return DocumentStatus.verified;
      case 4:
        return DocumentStatus.approved;
      case 5:
        return DocumentStatus.rejected;
      case 6:
        return DocumentStatus.expired;
      default:
        return DocumentStatus.uploaded;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentStatus obj) {
    switch (obj) {
      case DocumentStatus.uploaded:
        writer.writeByte(0);
        break;
      case DocumentStatus.pending:
        writer.writeByte(1);
        break;
      case DocumentStatus.reviewed:
        writer.writeByte(2);
        break;
      case DocumentStatus.verified:
        writer.writeByte(3);
        break;
      case DocumentStatus.approved:
        writer.writeByte(4);
        break;
      case DocumentStatus.rejected:
        writer.writeByte(5);
        break;
      case DocumentStatus.expired:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final int typeId = 3;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.resume;
      case 1:
        return DocumentType.coverLetter;
      case 2:
        return DocumentType.license;
      case 3:
        return DocumentType.certification;
      case 4:
        return DocumentType.backgroundCheck;
      case 5:
        return DocumentType.references;
      case 6:
        return DocumentType.identity;
      case 7:
        return DocumentType.other;
      default:
        return DocumentType.resume;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.resume:
        writer.writeByte(0);
        break;
      case DocumentType.coverLetter:
        writer.writeByte(1);
        break;
      case DocumentType.license:
        writer.writeByte(2);
        break;
      case DocumentType.certification:
        writer.writeByte(3);
        break;
      case DocumentType.backgroundCheck:
        writer.writeByte(4);
        break;
      case DocumentType.references:
        writer.writeByte(5);
        break;
      case DocumentType.identity:
        writer.writeByte(6);
        break;
      case DocumentType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
