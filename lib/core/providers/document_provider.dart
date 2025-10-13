import 'package:flutter/foundation.dart';
import '../models/document_model.dart';
import '../services/enhanced_api_service.dart';

class DocumentProvider extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  List<DocumentModel> _filteredDocuments = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedStatus;

  List<DocumentModel> get documents => _filteredDocuments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedType => _selectedType;
  String? get selectedStatus => _selectedStatus;

  List<String> get documentTypes {
    const types = ['resume', 'cover_letter', 'portfolio', 'certificate', 'id_document', 'other'];
    return types;
  }

  List<String> get documentStatuses {
    const statuses = ['pending', 'approved', 'rejected', 'requires_update'];
    return statuses;
  }

  Future<void> loadDocuments({bool loadAll = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final documentsData = await EnhancedApiService.getDocuments(
        uploadedById: loadAll ? '' : null, // Empty string to load all documents for HR
      );
      _documents = documentsData.map((data) => DocumentModel.fromJson(data)).toList();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load documents: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentModel?> uploadDocument(Map<String, dynamic> documentData) async {
    try {
      final result = await EnhancedApiService.uploadDocument(documentData);
      if (result != null) {
        final newDocument = DocumentModel.fromJson(result);
        _documents.insert(0, newDocument);
        _applyFilters();
        notifyListeners();
        return newDocument;
      }
    } catch (e) {
      _error = 'Failed to upload document: ${e.toString()}';
      notifyListeners();
    }
    return null;
  }

  Future<bool> updateDocumentStatus(String documentId, String status, {String? reviewNotes}) async {
    try {
      final success = await EnhancedApiService.updateDocumentStatus(
        documentId, 
        status, 
        reviewNotes: reviewNotes,
      );
      
      if (success) {
        // Update local document
        final docIndex = _documents.indexWhere((doc) => doc.id == documentId);
        if (docIndex != -1) {
          final updatedDoc = DocumentModel(
            id: _documents[docIndex].id,
            filename: _documents[docIndex].filename,
            originalName: _documents[docIndex].originalName,
            mimeType: _documents[docIndex].mimeType,
            size: _documents[docIndex].size,
            url: _documents[docIndex].url,
            type: _documents[docIndex].type,
            status: status,
            description: _documents[docIndex].description,
            reviewNotes: reviewNotes ?? _documents[docIndex].reviewNotes,
            uploadedById: _documents[docIndex].uploadedById,
            jobApplicationId: _documents[docIndex].jobApplicationId,
            reviewedById: _documents[docIndex].reviewedById,
            reviewedAt: DateTime.now(),
            createdAt: _documents[docIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          _documents[docIndex] = updatedDoc;
          _applyFilters();
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = 'Failed to update document status: ${e.toString()}';
      notifyListeners();
    }
    return false;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setTypeFilter(String? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedStatus = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredDocuments = _documents.where((document) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesFilename = document.filename.toLowerCase().contains(query);
        final matchesOriginalName = document.originalName.toLowerCase().contains(query);
        final matchesType = document.typeDisplayName.toLowerCase().contains(query);
        if (!matchesFilename && !matchesOriginalName && !matchesType) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null && document.type != _selectedType) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && document.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();

    // Sort by creation date (newest first)
    _filteredDocuments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  DocumentModel? getDocumentById(String id) {
    try {
      return _documents.firstWhere((document) => document.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DocumentModel> getPendingDocuments() {
    return _documents.where((doc) => doc.status == 'pending').toList();
  }

  List<DocumentModel> getApprovedDocuments() {
    return _documents.where((doc) => doc.status == 'approved').toList();
  }

  List<DocumentModel> getRejectedDocuments() {
    return _documents.where((doc) => doc.status == 'rejected').toList();
  }

  int get totalDocuments => _documents.length;
  int get pendingDocumentsCount => _documents.where((doc) => doc.status == 'pending').length;
  int get approvedDocumentsCount => _documents.where((doc) => doc.status == 'approved').length;
  int get rejectedDocumentsCount => _documents.where((doc) => doc.status == 'rejected').length;

  Map<String, int> get documentCountsByType {
    final counts = <String, int>{};
    for (final type in documentTypes) {
      counts[type] = _documents.where((doc) => doc.type == type).length;
    }
    return counts;
  }

  void refresh() {
    loadDocuments();
  }
}