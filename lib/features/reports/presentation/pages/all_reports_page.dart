import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../data/services/report_service.dart';
import '../../domain/models/report_model.dart';
import '../widgets/report_card.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  List<ReportModel> _reports = [];
  List<ReportModel> _filteredReports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    try {
      final reports = await ReportService.getAllReports();
      setState(() {
        _reports = reports;
        _filteredReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  void _filterReports() {
    setState(() {
      _filteredReports = _reports.where((report) {
        final matchesSearch = _searchQuery.isEmpty ||
            report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesCategory = _selectedCategory == null || 
            report.category == _selectedCategory;
            
        final matchesStatus = _selectedStatus == null || 
            report.status == _selectedStatus;
        
        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
      
      // Sort by generation date (newest first)
      _filteredReports.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return AppHeader(
                  title: 'All Reports',
                  subtitle: 'Browse and manage generated reports',
                  user: authProvider.user,
                  showBackButton: true,
                  actions: [
                    IconButton(
                      onPressed: () => context.push('/reports/generate-report'),
                      icon: const Icon(Icons.add),
                      tooltip: 'Generate New Report',
                    ),
                  ],
                );
              },
            ),

            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search reports...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterReports();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ReportCategory>(
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _selectedCategory,
                          items: [
                            const DropdownMenuItem<ReportCategory>(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...ReportCategory.values.map((category) {
                              return DropdownMenuItem<ReportCategory>(
                                value: category,
                                child: Text(_getCategoryDisplayName(category)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                            _filterReports();
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: DropdownButtonFormField<ReportStatus>(
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _selectedStatus,
                          items: [
                            const DropdownMenuItem<ReportStatus>(
                              value: null,
                              child: Text('All Status'),
                            ),
                            ...ReportStatus.values.map((status) {
                              return DropdownMenuItem<ReportStatus>(
                                value: status,
                                child: Text(_getStatusDisplayName(status)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatus = value);
                            _filterReports();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reports List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _reports.isEmpty ? 'No reports generated yet' : 'No reports match your filters',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _reports.isEmpty 
                                    ? 'Generate your first report to get started'
                                    : 'Try adjusting your search criteria',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (_reports.isEmpty) ...[
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/reports/generate-report'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Generate Report'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadReports,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = _filteredReports[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ReportCard(
                                  report: report,
                                  onTap: () => context.push('/reports/report-details/${report.id}'),
                                  onDelete: () => _deleteReport(report),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/generate-report'),
        icon: const Icon(Icons.add),
        label: const Text('Generate Report'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _getCategoryDisplayName(ReportCategory category) {
    switch (category) {
      case ReportCategory.applications:
        return 'Job Applications';
      case ReportCategory.interviews:
        return 'Interviews';
      case ReportCategory.users:
        return 'User Activity';
      case ReportCategory.jobs:
        return 'Job Postings';
      case ReportCategory.documents:
        return 'Documents';
      case ReportCategory.performance:
        return 'Performance';
      case ReportCategory.compliance:
        return 'Compliance';
      default:
        return 'System';
    }
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.processing:
        return 'Processing';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.failed:
        return 'Failed';
    }
  }

  Future<void> _deleteReport(ReportModel report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReportService.deleteReport(report.id);
        await _loadReports();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}