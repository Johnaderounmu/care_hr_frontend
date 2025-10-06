import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/document_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/custom_platform_file.dart';

class DocumentService {
  static final Logger _logger = Logger();
  static final Dio _dio = Dio();
  static const String _baseUrl =
      'https://api.careconnect.com/documents'; // Replace with actual API

  // Upload document
  static Future<DocumentModel?> uploadDocument({
    required CustomPlatformFile file,
    required DocumentType type,
    String? applicantId,
    String? notes,
  }) async {
    try {
      _logger.i('Uploading document: ${file.name}');

      // Validate file
      if (!_validateFile(file)) {
        throw Exception('Invalid file type or size');
      }

      // Create document model
      final document = DocumentModel(
        id: const Uuid().v4(),
        name: file.name,
        type: type.toString().split('.').last,
        filePath: file.path ?? '',
        fileUrl: '', // Will be set after upload
        fileSize: file.size,
        mimeType: file.extension ?? '',
        status: DocumentStatus.uploaded,
        applicantId: applicantId,
        uploadedAt: DateTime.now(),
        notes: notes,
      );

      // Save locally first
      await _saveDocumentLocally(document);

      // Upload to server (simulate for now)
      await _uploadToServer(document, file);

      _logger.i('Document uploaded successfully: ${document.id}');
      return document;
    } catch (e) {
      _logger.e('Error uploading document: $e');
      throw Exception('Failed to upload document: $e');
    }
  }

  // Get documents by applicant
  static Future<List<DocumentModel>> getDocumentsByApplicant(
      String applicantId) async {
    try {
      _logger.i('Getting documents for applicant: $applicantId');

      // Get from local storage first
      final localDocuments = await _getLocalDocuments();
      final applicantDocuments = localDocuments
          .where((doc) => doc.applicantId == applicantId)
          .toList();

      // Sort by upload date (newest first)
      applicantDocuments.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      return applicantDocuments;
    } catch (e) {
      _logger.e('Error getting documents: $e');
      return [];
    }
  }

  // Get all documents (for HR)
  static Future<List<DocumentModel>> getAllDocuments({
    DocumentStatus? status,
    DocumentType? type,
    String? searchQuery,
  }) async {
    try {
      _logger.i('Getting all documents with filters');

      var documents = await _getLocalDocuments();

      // Apply filters
      if (status != null) {
        documents = documents.where((doc) => doc.status == status).toList();
      }

      if (type != null) {
        documents = documents
            .where((doc) => doc.type == type.toString().split('.').last)
            .toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        documents = documents
            .where((doc) =>
                doc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                doc.type.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      // Sort by upload date (newest first)
      documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      return documents;
    } catch (e) {
      _logger.e('Error getting all documents: $e');
      return [];
    }
  }

  // Update document status
  static Future<bool> updateDocumentStatus({
    required String documentId,
    required DocumentStatus status,
    String? reviewerId,
    String? rejectionReason,
    String? notes,
  }) async {
    try {
      _logger.i('Updating document status: $documentId to $status');

      final documents = await _getLocalDocuments();
      final documentIndex = documents.indexWhere((doc) => doc.id == documentId);

      if (documentIndex == -1) {
        throw Exception('Document not found');
      }

      final document = documents[documentIndex];
      final updatedDocument = document.copyWith(
        status: status,
        reviewerId: reviewerId,
        rejectionReason: rejectionReason,
        notes: notes,
        reviewedAt: DateTime.now(),
      );

      documents[documentIndex] = updatedDocument;
      await StorageService.put(
          'documents', documents.map((doc) => doc.toMap()).toList());

      _logger.i('Document status updated successfully');
      return true;
    } catch (e) {
      _logger.e('Error updating document status: $e');
      return false;
    }
  }

  // Delete document
  static Future<bool> deleteDocument(String documentId) async {
    try {
      _logger.i('Deleting document: $documentId');

      final documents = await _getLocalDocuments();
      documents.removeWhere((doc) => doc.id == documentId);

      await StorageService.put(
          'documents', documents.map((doc) => doc.toMap()).toList());

      // Delete local file if exists
      final document = documents.firstWhere((doc) => doc.id == documentId);
      if (document.filePath.isNotEmpty) {
        final file = File(document.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _logger.i('Document deleted successfully');
      return true;
    } catch (e) {
      _logger.e('Error deleting document: $e');
      return false;
    }
  }

  // Get document by ID
  static Future<DocumentModel?> getDocumentById(String documentId) async {
    try {
      final documents = await _getLocalDocuments();
      return documents.firstWhere((doc) => doc.id == documentId);
    } catch (e) {
      _logger.e('Error getting document by ID: $e');
      return null;
    }
  }

  // Download document
  static Future<String?> downloadDocument(DocumentModel document) async {
    try {
      _logger.i('Downloading document: ${document.name}');

      // If file already exists locally, return the path
      if (document.filePath.isNotEmpty) {
        final file = File(document.filePath);
        if (await file.exists()) {
          return document.filePath;
        }
      }

      // Download from server
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${document.id}_${document.name}';
      final filePath = '${appDir.path}/$fileName';

      await _dio.download(document.fileUrl, filePath);

      // Update document with local path
      final documents = await _getLocalDocuments();
      final documentIndex =
          documents.indexWhere((doc) => doc.id == document.id);
      if (documentIndex != -1) {
        documents[documentIndex] = document.copyWith(filePath: filePath);
        await StorageService.put(
            'documents', documents.map((doc) => doc.toMap()).toList());
      }

      return filePath;
    } catch (e) {
      _logger.e('Error downloading document: $e');
      return null;
    }
  }

  // Get document statistics
  static Future<Map<String, int>> getDocumentStats() async {
    try {
      final documents = await _getLocalDocuments();

      final stats = <String, int>{
        'total': documents.length,
        'pending': documents
            .where((doc) => doc.status == DocumentStatus.pending)
            .length,
        'verified': documents
            .where((doc) => doc.status == DocumentStatus.verified)
            .length,
        'rejected': documents
            .where((doc) => doc.status == DocumentStatus.rejected)
            .length,
        'expired': documents.where((doc) => doc.isExpired).length,
      };

      return stats;
    } catch (e) {
      _logger.e('Error getting document stats: $e');
      return {};
    }
  }

  // Private methods

  static bool _validateFile(CustomPlatformFile file) {
    // Check file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      return false;
    }

    // Check file extension
    final allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
    final extension = file.extension?.toLowerCase();
    if (extension == null || !allowedExtensions.contains(extension)) {
      return false;
    }

    return true;
  }

  static Future<void> _saveDocumentLocally(DocumentModel document) async {
    final documents = await _getLocalDocuments();
    documents.add(document);
    await StorageService.put(
        'documents', documents.map((doc) => doc.toMap()).toList());
  }

  static Future<void> _uploadToServer(
      DocumentModel document, CustomPlatformFile file) async {
    // Simulate server upload
    await Future.delayed(const Duration(seconds: 2));

    // Update document with server URL
    final documents = await _getLocalDocuments();
    final documentIndex = documents.indexWhere((doc) => doc.id == document.id);
    if (documentIndex != -1) {
      documents[documentIndex] = document.copyWith(
        fileUrl: '$_baseUrl/${document.id}',
        status: DocumentStatus.pending,
      );
      await StorageService.put(
          'documents', documents.map((doc) => doc.toMap()).toList());
    }
  }

  static Future<List<DocumentModel>> _getLocalDocuments() async {
    try {
      final documentsData = StorageService.get<List>('documents');
      if (documentsData == null) {
        return [];
      }

      return documentsData
          .map((data) => DocumentModel.fromMap(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      _logger.e('Error getting local documents: $e');
      return [];
    }
  }

  // Initialize with sample data
  static Future<void> initializeSampleData() async {
    try {
      final existingDocuments = await _getLocalDocuments();
      if (existingDocuments.isNotEmpty) return;

      final sampleDocuments = [
        DocumentModel(
          id: const Uuid().v4(),
          name: 'Resume.pdf',
          type: 'resume',
          filePath: '',
          fileUrl: 'https://example.com/resume.pdf',
          fileSize: 1024000,
          mimeType: 'application/pdf',
          status: DocumentStatus.verified,
          applicantId: 'applicant1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 4)),
          notes: 'Resume reviewed and approved',
        ),
        DocumentModel(
          id: const Uuid().v4(),
          name: 'License.pdf',
          type: 'license',
          filePath: '',
          fileUrl: 'https://example.com/license.pdf',
          fileSize: 512000,
          mimeType: 'application/pdf',
          status: DocumentStatus.pending,
          applicantId: 'applicant1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
        DocumentModel(
          id: const Uuid().v4(),
          name: 'Certification.pdf',
          type: 'certification',
          filePath: '',
          fileUrl: 'https://example.com/certification.pdf',
          fileSize: 768000,
          mimeType: 'application/pdf',
          status: DocumentStatus.expired,
          applicantId: 'applicant1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 365)),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await StorageService.put(
          'documents', sampleDocuments.map((doc) => doc.toMap()).toList());
      _logger.i('Sample documents initialized');
    } catch (e) {
      _logger.e('Error initializing sample data: $e');
    }
  }
}
