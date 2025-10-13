import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/job_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/models/job_model.dart';

class EnhancedJobListingPage extends StatefulWidget {
  const EnhancedJobListingPage({super.key});

  @override
  State<EnhancedJobListingPage> createState() => _EnhancedJobListingPageState();
}

class _EnhancedJobListingPageState extends State<EnhancedJobListingPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  title: 'Available Jobs',
                  subtitle: 'Find your next opportunity',
                  user: authProvider.user,
                );
              },
            ),

            // Content
            Expanded(
              child: Consumer<JobProvider>(
                builder: (context, jobProvider, child) {
                  if (jobProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (jobProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading jobs',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            jobProvider.error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => jobProvider.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => jobProvider.loadJobs(),
                    child: Column(
                      children: [
                        // Search and Filters
                        _buildSearchAndFilters(jobProvider),
                        
                        // Job List
                        Expanded(
                          child: _buildJobList(jobProvider),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(JobProvider jobProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: jobProvider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        jobProvider.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => jobProvider.setSearchQuery(value),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Department Filter
                _buildFilterChip(
                  label: jobProvider.selectedDepartment ?? 'All Departments',
                  isSelected: jobProvider.selectedDepartment != null,
                  onTap: () => _showDepartmentFilter(jobProvider),
                ),
                const SizedBox(width: 8),

                // Type Filter
                _buildFilterChip(
                  label: jobProvider.selectedType ?? 'All Types',
                  isSelected: jobProvider.selectedType != null,
                  onTap: () => _showTypeFilter(jobProvider),
                ),
                const SizedBox(width: 8),

                // Status Filter
                _buildFilterChip(
                  label: jobProvider.selectedStatus ?? 'All Status',
                  isSelected: jobProvider.selectedStatus != null,
                  onTap: () => _showStatusFilter(jobProvider),
                ),
                const SizedBox(width: 8),

                // Clear Filters
                if (jobProvider.searchQuery.isNotEmpty ||
                    jobProvider.selectedDepartment != null ||
                    jobProvider.selectedType != null ||
                    jobProvider.selectedStatus != null)
                  _buildFilterChip(
                    label: 'Clear Filters',
                    isSelected: false,
                    onTap: () {
                      _searchController.clear();
                      jobProvider.clearFilters();
                    },
                    isAction: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isAction = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isAction
                  ? Colors.red[50]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAction
                    ? Colors.red[300]!
                    : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isAction
                    ? Colors.red[700]
                    : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(JobProvider jobProvider) {
    if (jobProvider.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobProvider.jobs.length,
      itemBuilder: (context, index) {
        final job = jobProvider.jobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.department} • ${job.location}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(job.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(job.type.replaceAll('_', ' ').toUpperCase()),
                  const SizedBox(width: 8),
                  if (job.experienceLevel != null)
                    _buildInfoChip(job.experienceLevel!.toUpperCase()),
                  const Spacer(),
                  Text(
                    'Posted ${_formatDate(job.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'draft':
        color = Colors.orange;
        break;
      case 'closed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDepartmentFilter(JobProvider jobProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Department',
        options: ['All Departments', ...jobProvider.departments],
        selectedValue: jobProvider.selectedDepartment,
        onSelected: (value) => jobProvider.setDepartmentFilter(
          value == 'All Departments' ? null : value,
        ),
      ),
    );
  }

  void _showTypeFilter(JobProvider jobProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Type',
        options: ['All Types', ...jobProvider.jobTypes],
        selectedValue: jobProvider.selectedType,
        onSelected: (value) => jobProvider.setTypeFilter(
          value == 'All Types' ? null : value,
        ),
      ),
    );
  }

  void _showStatusFilter(JobProvider jobProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Status',
        options: const ['All Status', 'active', 'draft', 'closed'],
        selectedValue: jobProvider.selectedStatus,
        onSelected: (value) => jobProvider.setStatusFilter(
          value == 'All Status' ? null : value,
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...options.map((option) => ListTile(
                title: Text(option),
                trailing: selectedValue == option
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showJobDetails(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${job.department} • ${job.location}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(job.description),
                      if (job.requirements != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Requirements',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(job.requirements!),
                      ],
                      if (job.salaryRange != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Salary Range',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(job.salaryRange!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/application-form', extra: job);
                  },
                  child: const Text('Apply Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}