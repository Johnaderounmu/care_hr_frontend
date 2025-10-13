import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../data/services/report_service.dart';
import '../../domain/models/report_model.dart';

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key});

  @override
  State<GenerateReportPage> createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  final _formKey = GlobalKey<FormState>();
  
  ReportType _selectedType = ReportType.summary;
  ReportCategory _selectedCategory = ReportCategory.applications;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedDepartment;
  bool _isGenerating = false;

  final List<String> _departments = [
    'Engineering',
    'Marketing', 
    'Sales',
    'HR',
    'Finance',
    'Operations',
    'Customer Support',
    'Design',
    'Product',
  ];

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
                  title: 'Generate Report',
                  subtitle: 'Create custom reports and analytics',
                  user: authProvider.user,
                  showBackButton: true,
                );
              },
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Type Section
                      _buildSection(
                        'Report Type',
                        [
                          _buildReportTypeCard(
                            ReportType.summary,
                            'Summary Report',
                            'Overview of key metrics and statistics',
                            Icons.summarize,
                          ),
                          const SizedBox(height: 12),
                          _buildReportTypeCard(
                            ReportType.detailed,
                            'Detailed Report',
                            'Comprehensive analysis with detailed breakdowns',
                            Icons.analytics,
                          ),
                          const SizedBox(height: 12),
                          _buildReportTypeCard(
                            ReportType.chart,
                            'Chart Report',
                            'Visual charts and graphs',
                            Icons.bar_chart,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Report Category Section
                      _buildSection(
                        'Report Category',
                        [
                          _buildCategoryCard(
                            ReportCategory.applications,
                            'Job Applications',
                            'Application status, trends, and analytics',
                            Icons.work,
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryCard(
                            ReportCategory.jobs,
                            'Job Postings',
                            'Job posting performance and metrics',
                            Icons.post_add,
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryCard(
                            ReportCategory.users,
                            'User Activity',
                            'User engagement and activity analysis',
                            Icons.people,
                          ),
                          const SizedBox(height: 12),
                          _buildCategoryCard(
                            ReportCategory.documents,
                            'Documents',
                            'Document management and processing',
                            Icons.description,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Filters Section
                      _buildSection(
                        'Filters',
                        [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateField(
                                  label: 'From Date',
                                  value: _fromDate,
                                  onTap: () => _selectDate(true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateField(
                                  label: 'To Date',
                                  value: _toDate,
                                  onTap: () => _selectDate(false),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Department (Optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            value: _selectedDepartment,
                            hint: const Text('All Departments'),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedDepartment = value),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isGenerating ? null : _generateReport,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isGenerating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Generating Report...'),
                                  ],
                                )
                              : const Text('Generate Report'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _isGenerating ? null : () => context.pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildReportTypeCard(
    ReportType type,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.primary : Colors.grey[200],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    ReportCategory category,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    
    return InkWell(
      onTap: () => setState(() => _selectedCategory = category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.grey[300]!,
            width: 2,
          ),
          color: isSelected ? AppColors.secondary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.secondary : Colors.grey[200],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.secondary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.secondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate ?? DateTime.now() : _toDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = date;
          if (_toDate != null && _toDate!.isBefore(date)) {
            _toDate = null;
          }
        } else {
          _toDate = date;
          if (_fromDate != null && _fromDate!.isAfter(date)) {
            _fromDate = null;
          }
        }
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final generatedBy = authProvider.user?.email ?? 'unknown';

      String reportId;
      
      switch (_selectedCategory) {
        case ReportCategory.applications:
          reportId = await ReportService.generateApplicationSummaryReport(
            generatedBy: generatedBy,
            fromDate: _fromDate,
            toDate: _toDate,
            department: _selectedDepartment,
          );
          break;
        case ReportCategory.users:
          reportId = await ReportService.generateUserActivityReport(
            generatedBy: generatedBy,
            fromDate: _fromDate,
            toDate: _toDate,
          );
          break;
        case ReportCategory.jobs:
          reportId = await ReportService.generateJobPerformanceReport(
            generatedBy: generatedBy,
            fromDate: _fromDate,
            toDate: _toDate,
            department: _selectedDepartment,
          );
          break;
        default:
          // Use application summary report as fallback for other categories
          reportId = await ReportService.generateApplicationSummaryReport(
            generatedBy: generatedBy,
            fromDate: _fromDate,
            toDate: _toDate,
            department: _selectedDepartment,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to the generated report
        context.go('/reports/report-details/$reportId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}