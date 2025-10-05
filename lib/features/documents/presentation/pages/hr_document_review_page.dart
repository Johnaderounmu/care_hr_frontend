import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/document_model.dart';
import '../../data/services/document_service.dart';
import '../widgets/document_review_card.dart';
import '../widgets/document_status_filter.dart';

class HRDocumentReviewPage extends StatefulWidget {
  const HRDocumentReviewPage({super.key});

  @override
  State<HRDocumentReviewPage> createState() => _HRDocumentReviewPageState();
}

class _HRDocumentReviewPageState extends State<HRDocumentReviewPage> {
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  DocumentStatus? _statusFilter;
  String _searchQuery = '';
  String _selectedTab = 'All Documents';

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
                  title: 'Document Review',
                  subtitle: 'Review and verify applicant documents',
                  user: authProvider.user,
                  showBackButton: true,
                ),

                // Content
                Expanded(
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTabs(),
                      ),

                      // Search and Filters
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Search Bar
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                _filterDocuments();
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
                                      return DocumentReviewCard(
                                        document: document,
                                        onApprove: () =>
                                            _approveDocument(document),
                                        onReject: () =>
                                            _rejectDocument(document),
                                        onView: () => _viewDocument(document),
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

  Widget _buildTabs() {
    final tabs = ['All Documents', 'Verified', 'Unverified'];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = tab;
                });
                _filterDocuments();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
            'No documents match your current filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
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
      final documents = await DocumentService.getAllDocuments(
        status: _statusFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _documents = documents;
      });
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

  void _filterDocuments() {
    setState(() {
      _isLoading = true;
    });
    _loadDocuments();
  }

  Future<void> _approveDocument(DocumentModel document) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reviewerId = authProvider.user?.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Document'),
        content: Text('Are you sure you want to approve "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DocumentService.updateDocumentStatus(
        documentId: document.id,
        status: DocumentStatus.verified,
        reviewerId: reviewerId,
        notes: 'Document approved by HR',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document approved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadDocuments();
      }
    }
  }

  Future<void> _rejectDocument(DocumentModel document) async {
    final reasonController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reviewerId = authProvider.user?.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${document.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Please provide a reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
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
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      final success = await DocumentService.updateDocumentStatus(
        documentId: document.id,
        status: DocumentStatus.rejected,
        reviewerId: reviewerId,
        rejectionReason: reasonController.text,
        notes: 'Document rejected by HR',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document rejected successfully'),
            backgroundColor: AppColors.error,
          ),
        );
        _loadDocuments();
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
            if (document.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Text('Rejection Reason: ${document.rejectionReason}'),
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
              _approveDocument(document);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectDocument(document);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

