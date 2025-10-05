import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/document_model.dart';
import '../../data/services/document_service.dart';
import '../widgets/document_list_item.dart';
import '../widgets/document_status_filter.dart';

class ApplicantDocumentsPage extends StatefulWidget {
  const ApplicantDocumentsPage({super.key});

  @override
  State<ApplicantDocumentsPage> createState() => _ApplicantDocumentsPageState();
}

class _ApplicantDocumentsPageState extends State<ApplicantDocumentsPage> {
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  DocumentStatus? _statusFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              children: [
                // Header
                AppHeader(
                  title: 'My Documents',
                  subtitle:
                      'Manage your uploaded documents for your application',
                  user: authProvider.user,
                  showBackButton: true,
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/document-upload');
                      },
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Upload New Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),

                // Content
                Expanded(
                  child: Column(
                    children: [
                      // Filters and Search
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Search Bar
                            TextField(
                              onChanged: (value) async {
                                setState(() {
                                  _searchQuery = value;
                                });
                                await _filterDocuments();
                              },
                              decoration: InputDecoration(
                                hintText: 'Search documents...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                                border: Theme.of(context)
                                    .inputDecorationTheme
                                    .border,
                                enabledBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .enabledBorder,
                                focusedBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .focusedBorder,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Status Filter
                            DocumentStatusFilter(
                              selectedStatus: _statusFilter,
                              onStatusChanged: (status) {
                                setState(() {
                                  _statusFilter = status;
                                });
                                _filterDocuments();
                              },
                            ),
                          ],
                        ),
                      ),

                      // Documents List
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                                ),
                              )
                            : _documents.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    itemCount: _documents.length,
                                    itemBuilder: (context, index) {
                                      final document = _documents[index];
                                      return DocumentListItem(
                                        document: document,
                                        onTap: () => _viewDocument(document),
                                        onDelete: () =>
                                            _deleteDocument(document),
                                        onDownload: () =>
                                            _downloadDocument(document),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Documents Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first document to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/document-upload');
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applicantId = authProvider.user?.id;

      if (applicantId != null) {
        final documents =
            await DocumentService.getDocumentsByApplicant(applicantId);
        setState(() {
          _documents = documents;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _filterDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await DocumentService.getAllDocuments(
        status: _statusFilter,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _documents = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering documents: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _viewDocument(DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${document.type}'),
            Text('Size: ${document.fileSizeFormatted}'),
            Text('Uploaded: ${_formatDate(document.uploadedAt)}'),
            if (document.expiresAt != null)
              Text('Expires: ${_formatDate(document.expiresAt!)}'),
            if (document.notes != null) ...[
              const SizedBox(height: 8),
              Text('Notes: ${document.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadDocument(document);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(DocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DocumentService.deleteDocument(document.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadDocuments();
      }
    }
  }

  Future<void> _downloadDocument(DocumentModel document) async {
    try {
      final filePath = await DocumentService.downloadDocument(document);
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document downloaded to: $filePath'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading document: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
