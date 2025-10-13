import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 11)
class DocumentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String filename;

  @HiveField(2)
  final String originalName;

  @HiveField(3)
  final String mimeType;

  @HiveField(4)
  final int size;

  @HiveField(5)
  final String url;

  @HiveField(6)
  final String type; // resume, cover_letter, portfolio, certificate, id_document, other

  @HiveField(7)
  final String status; // pending, approved, rejected, requires_update

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final String? reviewNotes;

  @HiveField(10)
  final String uploadedById;

  @HiveField(11)
  final String? jobApplicationId;

  @HiveField(12)
  final String? reviewedById;

  @HiveField(13)
  final DateTime? reviewedAt;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime? updatedAt;

  DocumentModel({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.url,
    required this.type,
    required this.status,
    this.description,
    this.reviewNotes,
    required this.uploadedById,
    this.jobApplicationId,
    this.reviewedById,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      originalName: json['originalName'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      description: json['description'],
      reviewNotes: json['reviewNotes'],
      uploadedById: json['uploadedById'] ?? '',
      jobApplicationId: json['jobApplicationId'],
      reviewedById: json['reviewedById'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt']) : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'url': url,
      'type': type,
      'status': status,
      'description': description,
      'reviewNotes': reviewNotes,
      'uploadedById': uploadedById,
      'jobApplicationId': jobApplicationId,
      'reviewedById': reviewedById,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'requires_update':
        return 'Requires Update';
      default:
        return 'Unknown';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case 'resume':
        return 'Resume';
      case 'cover_letter':
        return 'Cover Letter';
      case 'portfolio':
        return 'Portfolio';
      case 'certificate':
        return 'Certificate';
      case 'id_document':
        return 'ID Document';
      case 'other':
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, filename: $filename, type: $type, status: $status)';
  }
}