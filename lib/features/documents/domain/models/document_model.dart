import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 1)
class DocumentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String filePath;

  @HiveField(4)
  final String fileUrl;

  @HiveField(5)
  final int fileSize;

  @HiveField(6)
  final String mimeType;

  @HiveField(7)
  final DocumentStatus status;

  @HiveField(8)
  final String? applicantId;

  @HiveField(9)
  final String? reviewerId;

  @HiveField(10)
  final DateTime uploadedAt;

  @HiveField(11)
  final DateTime? reviewedAt;

  @HiveField(12)
  final DateTime? expiresAt;

  @HiveField(13)
  final String? rejectionReason;

  @HiveField(14)
  final String? notes;

  @HiveField(15)
  final Map<String, dynamic>? metadata;

  DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    required this.status,
    this.applicantId,
    this.reviewerId,
    required this.uploadedAt,
    this.reviewedAt,
    this.expiresAt,
    this.rejectionReason,
    this.notes,
    this.metadata,
  });

  // Create DocumentModel from Map
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      filePath: map['filePath'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      mimeType: map['mimeType'] ?? '',
      status: DocumentStatus.fromString(map['status'] ?? 'pending'),
      applicantId: map['applicantId'],
      reviewerId: map['reviewerId'],
      uploadedAt:
          DateTime.parse(map['uploadedAt'] ?? DateTime.now().toIso8601String()),
      reviewedAt:
          map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt']) : null,
      expiresAt:
          map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      rejectionReason: map['rejectionReason'],
      notes: map['notes'],
      metadata: map['metadata'],
    );
  }

  // Convert DocumentModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'filePath': filePath,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'status': status.toString(),
      'applicantId': applicantId,
      'reviewerId': reviewerId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Copy with method
  DocumentModel copyWith({
    String? id,
    String? name,
    String? type,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    String? mimeType,
    DocumentStatus? status,
    String? applicantId,
    String? reviewerId,
    DateTime? uploadedAt,
    DateTime? reviewedAt,
    DateTime? expiresAt,
    String? rejectionReason,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      applicantId: applicantId ?? this.applicantId,
      reviewerId: reviewerId ?? this.reviewerId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get file extension
  String get fileExtension {
    return name.split('.').last.toLowerCase();
  }

  // Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Check if document is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if document needs review
  bool get needsReview {
    return status == DocumentStatus.pending ||
        status == DocumentStatus.uploaded;
  }

  // Check if document is verified
  bool get isVerified {
    return status == DocumentStatus.verified ||
        status == DocumentStatus.approved;
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case DocumentStatus.verified:
      case DocumentStatus.approved:
        return 'green';
      case DocumentStatus.rejected:
        return 'red';
      case DocumentStatus.expired:
        return 'red';
      case DocumentStatus.pending:
      case DocumentStatus.uploaded:
        return 'yellow';
      case DocumentStatus.reviewed:
        return 'blue';
    }
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 2)
enum DocumentStatus {
  @HiveField(0)
  uploaded,

  @HiveField(1)
  pending,

  @HiveField(2)
  reviewed,

  @HiveField(3)
  verified,

  @HiveField(4)
  approved,

  @HiveField(5)
  rejected,

  @HiveField(6)
  expired;

  static DocumentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'uploaded':
        return DocumentStatus.uploaded;
      case 'pending':
        return DocumentStatus.pending;
      case 'reviewed':
        return DocumentStatus.reviewed;
      case 'verified':
        return DocumentStatus.verified;
      case 'approved':
        return DocumentStatus.approved;
      case 'rejected':
        return DocumentStatus.rejected;
      case 'expired':
        return DocumentStatus.expired;
      default:
        return DocumentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case DocumentStatus.uploaded:
        return 'Uploaded';
      case DocumentStatus.pending:
        return 'Pending Review';
      case DocumentStatus.reviewed:
        return 'Reviewed';
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
    }
  }
}

@HiveType(typeId: 3)
enum DocumentType {
  @HiveField(0)
  resume,

  @HiveField(1)
  coverLetter,

  @HiveField(2)
  license,

  @HiveField(3)
  certification,

  @HiveField(4)
  backgroundCheck,

  @HiveField(5)
  references,

  @HiveField(6)
  identity,

  @HiveField(7)
  other;

  static DocumentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'resume':
        return DocumentType.resume;
      case 'cover_letter':
      case 'coverletter':
        return DocumentType.coverLetter;
      case 'license':
        return DocumentType.license;
      case 'certification':
        return DocumentType.certification;
      case 'background_check':
      case 'backgroundcheck':
        return DocumentType.backgroundCheck;
      case 'references':
        return DocumentType.references;
      case 'identity':
        return DocumentType.identity;
      default:
        return DocumentType.other;
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.resume:
        return 'Resume';
      case DocumentType.coverLetter:
        return 'Cover Letter';
      case DocumentType.license:
        return 'License';
      case DocumentType.certification:
        return 'Certification';
      case DocumentType.backgroundCheck:
        return 'Background Check';
      case DocumentType.references:
        return 'References';
      case DocumentType.identity:
        return 'Identity Document';
      case DocumentType.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case DocumentType.resume:
        return 'description';
      case DocumentType.coverLetter:
        return 'mail';
      case DocumentType.license:
        return 'card_membership';
      case DocumentType.certification:
        return 'school';
      case DocumentType.backgroundCheck:
        return 'verified_user';
      case DocumentType.references:
        return 'people';
      case DocumentType.identity:
        return 'badge';
      case DocumentType.other:
        return 'insert_drive_file';
    }
  }
}
