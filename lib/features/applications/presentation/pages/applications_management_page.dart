import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../job_application/data/services/job_application_service.dart';
import '../../../job_application/data/services/job_service.dart';
import '../../../job_application/domain/models/job_application_model.dart';
import '../../../job_application/domain/models/job_model.dart';
import '../widgets/application_status_chip.dart';
import '../widgets/application_list_item.dart';

class ApplicationsManagementPage extends StatefulWidget {
  const ApplicationsManagementPage({super.key});

  @override
  State<ApplicationsManagementPage> createState() => _ApplicationsManagementPageState();
}

class _ApplicationsManagementPageState extends State<ApplicationsManagementPage> {
  List<JobApplicationModel> _applications = [];
  List<JobApplicationModel> _filteredApplications = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ApplicationStatus? _selectedStatus;
  String? _selectedDepartment;
  Map<String, JobModel> _jobsCache = {};

  final List<ApplicationStatus> _statusOptions = [
    ApplicationStatus.submitted,
    ApplicationStatus.underReview,
    ApplicationStatus.shortlisted,
    ApplicationStatus.interviewScheduled,
    ApplicationStatus.interviewCompleted,
    ApplicationStatus.rejected,
    ApplicationStatus.hired,
    ApplicationStatus.withdrawn,
  ];

  final List<String> _departmentOptions = [
    'All',
    'Engineering',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    
    try {
      final applications = await JobApplicationService.getAllApplications();
      final jobs = await JobService.getAllJobs();
      
      // Cache jobs for quick lookup
      _jobsCache = {for (var job in jobs) job.id: job};
      
      setState(() {
        _applications = applications;
        _filteredApplications = applications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading applications: $e')),
        );
      }
    }
  }

  void _filterApplications() {
    setState(() {
      _filteredApplications = _applications.where((application) {
        final job = _jobsCache[application.jobId];
        
        final matchesSearch = _searchQuery.isEmpty ||
            application.applicantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (job?.title.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        final matchesStatus = _selectedStatus == null || 
            application.status == _selectedStatus;
            
        final matchesDepartment = _selectedDepartment == null || 
            _selectedDepartment == 'All' || 
            (job?.department == _selectedDepartment);
        
        return matchesSearch && matchesStatus && matchesDepartment;
      }).toList();
    });
  }

  Future<void> _updateApplicationStatus(String applicationId, ApplicationStatus newStatus) async {
    try {
      await JobApplicationService.updateApplicationStatus(applicationId, newStatus);
      await _loadApplications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
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
                  title: 'Applications Management',
                  subtitle: 'Manage job applications and candidates',
                  user: authProvider.user,
                  showBackButton: true,
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
                      hintText: 'Search applicants or positions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterApplications();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter chips
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ApplicationStatus>(
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _selectedStatus,
                          items: [
                            const DropdownMenuItem<ApplicationStatus>(
                              value: null,
                              child: Text('All'),
                            ),
                            ..._statusOptions.map((status) {
                              return DropdownMenuItem<ApplicationStatus>(
                                value: status,
                                child: Text(status.displayName),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatus = value);
                            _filterApplications();
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Department',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _selectedDepartment,
                          items: _departmentOptions.map((dept) {
                            return DropdownMenuItem(
                              value: dept == 'All' ? null : dept,
                              child: Text(dept),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedDepartment = value);
                            _filterApplications();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Statistics
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.backgroundLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total', _applications.length.toString(), Icons.people),
                  _buildStatCard(
                    'Pending', 
                    _applications.where((app) => app.status == ApplicationStatus.submitted).length.toString(),
                    Icons.pending_actions,
                  ),
                  _buildStatCard(
                    'Interviews', 
                    _applications.where((app) => app.status == ApplicationStatus.interviewScheduled).length.toString(),
                    Icons.event,
                  ),
                  _buildStatCard(
                    'Hired', 
                    _applications.where((app) => app.status == ApplicationStatus.hired).length.toString(),
                    Icons.check_circle,
                  ),
                ],
              ),
            ),

            // Applications List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredApplications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No applications found',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadApplications,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredApplications.length,
                            itemBuilder: (context, index) {
                              final application = _filteredApplications[index];
                              return ApplicationListItem(
                                application: application,
                                onStatusUpdate: (newStatus) => _updateApplicationStatus(
                                  application.id,
                                  newStatus,
                                ),
                                onTap: () => _showApplicationDetails(application),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(JobApplicationModel application) {
    final job = _jobsCache[application.jobId];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        application.applicantName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ApplicationStatusChip(status: application.status),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  job?.title ?? 'Position not found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Contact Information', [
                          'Email: ${application.applicantEmail}',
                          'Applied: ${application.appliedDate.toString().split(' ')[0]}',
                        ]),
                        
                        const SizedBox(height: 24),
                        
                        if (job != null)
                          _buildDetailSection('Position Details', [
                            'Department: ${job.department}',
                            'Location: ${job.location}',
                            'Experience Level: ${job.experienceLevel}',
                          ]),
                        
                        if (application.coverLetter != null) ...[
                          const SizedBox(height: 24),
                          _buildDetailSection('Cover Letter', [application.coverLetter!]),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.push('/schedule-interview', extra: application);
                                },
                                child: const Text('Schedule Interview'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showStatusUpdateDialog(application);
                                },
                                child: const Text('Update Status'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...details.map((detail) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(detail),
        )),
      ],
    );
  }

  void _showStatusUpdateDialog(JobApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Application Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions.map((status) {
            return ListTile(
              title: Text(status.displayName),
              leading: Radio<ApplicationStatus>(
                value: status,
                groupValue: application.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    _updateApplicationStatus(application.id, value);
                  }
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}