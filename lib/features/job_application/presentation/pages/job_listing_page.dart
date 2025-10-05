import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Unused constants imports removed to satisfy analyzer
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/job_model.dart';
import '../../data/services/job_service.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_chip.dart';
import '../widgets/job_search_bar.dart';

class JobListingPage extends StatefulWidget {
  const JobListingPage({super.key});

  @override
  State<JobListingPage> createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobListingPage> {
  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedDepartment;
  String? _selectedLocation;
  String? _selectedEmploymentType;
  String? _selectedExperienceLevel;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await JobService.getActiveJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading jobs: $e')),
        );
      }
    }
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          final matchesSearch = job.title.toLowerCase().contains(lowerQuery) ||
              job.description.toLowerCase().contains(lowerQuery) ||
              job.department.toLowerCase().contains(lowerQuery) ||
              job.location.toLowerCase().contains(lowerQuery) ||
              job.requirements
                  .any((req) => req.toLowerCase().contains(lowerQuery)) ||
              job.skills
                  .any((skill) => skill.toLowerCase().contains(lowerQuery));

          if (!matchesSearch) return false;
        }

        // Department filter
        if (_selectedDepartment != null &&
            job.department != _selectedDepartment) {
          return false;
        }

        // Location filter
        if (_selectedLocation != null && job.location != _selectedLocation) {
          return false;
        }

        // Employment type filter
        if (_selectedEmploymentType != null &&
            job.employmentType != _selectedEmploymentType) {
          return false;
        }

        // Experience level filter
        if (_selectedExperienceLevel != null &&
            job.experienceLevel != _selectedExperienceLevel) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDepartment = null;
      _selectedLocation = null;
      _selectedEmploymentType = null;
      _selectedExperienceLevel = null;
    });
    _filterJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeader(
        title: 'Job Opportunities',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Search Bar
                JobSearchBar(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                    _filterJobs();
                  },
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      JobFilterChip(
                        label: 'All Jobs',
                        isSelected: _selectedDepartment == null &&
                            _selectedLocation == null &&
                            _selectedEmploymentType == null &&
                            _selectedExperienceLevel == null,
                        onTap: _clearFilters,
                        count: _jobs.length,
                      ),
                      const SizedBox(width: 8),

                      // Department Filter
                      JobFilterChip(
                        label: 'Department',
                        isSelected: _selectedDepartment != null,
                        onTap: () => _showDepartmentFilter(),
                        count: _selectedDepartment != null ? 1 : null,
                      ),
                      const SizedBox(width: 8),

                      // Location Filter
                      JobFilterChip(
                        label: 'Location',
                        isSelected: _selectedLocation != null,
                        onTap: () => _showLocationFilter(),
                        count: _selectedLocation != null ? 1 : null,
                      ),
                      const SizedBox(width: 8),

                      // Employment Type Filter
                      JobFilterChip(
                        label: 'Type',
                        isSelected: _selectedEmploymentType != null,
                        onTap: () => _showEmploymentTypeFilter(),
                        count: _selectedEmploymentType != null ? 1 : null,
                      ),
                      const SizedBox(width: 8),

                      // Experience Level Filter
                      JobFilterChip(
                        label: 'Experience',
                        isSelected: _selectedExperienceLevel != null,
                        onTap: () => _showExperienceLevelFilter(),
                        count: _selectedExperienceLevel != null ? 1 : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredJobs.length} job${_filteredJobs.length == 1 ? '' : 's'} found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty ||
                    _selectedDepartment != null ||
                    _selectedLocation != null ||
                    _selectedEmploymentType != null ||
                    _selectedExperienceLevel != null)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadJobs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: JobCard(
                                job: job,
                                onTap: () =>
                                    context.push('/job-details/${job.id}'),
                                onApply: () =>
                                    context.push('/application-form/${job.id}'),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria or check back later for new opportunities.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showDepartmentFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Department',
        items: _jobs.map((job) => job.department).toSet().toList(),
        selectedItem: _selectedDepartment,
        onItemSelected: (department) {
          setState(() {
            _selectedDepartment = department;
          });
          _filterJobs();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Location',
        items: _jobs.map((job) => job.location).toSet().toList(),
        selectedItem: _selectedLocation,
        onItemSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
          _filterJobs();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEmploymentTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Employment Type',
        items: _jobs.map((job) => job.employmentType).toSet().toList(),
        selectedItem: _selectedEmploymentType,
        onItemSelected: (employmentType) {
          setState(() {
            _selectedEmploymentType = employmentType;
          });
          _filterJobs();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showExperienceLevelFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Experience Level',
        items: _jobs.map((job) => job.experienceLevel).toSet().toList(),
        selectedItem: _selectedExperienceLevel,
        onItemSelected: (experienceLevel) {
          setState(() {
            _selectedExperienceLevel = experienceLevel;
          });
          _filterJobs();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFilterBottomSheet({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Function(String) onItemSelected,
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
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                // final isSelected = item == selectedItem; // unused

                return ListTile(
                  title: Text(item),
                  leading: Radio<String>(
                    value: item,
                    groupValue: selectedItem,
                    onChanged: (value) {
                      if (value != null) {
                        onItemSelected(value);
                      }
                    },
                  ),
                  onTap: () => onItemSelected(item),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (title.contains('Department')) {
                        _selectedDepartment = null;
                      } else if (title.contains('Location')) {
                        _selectedLocation = null;
                      } else if (title.contains('Employment Type')) {
                        _selectedEmploymentType = null;
                      } else if (title.contains('Experience Level')) {
                        _selectedExperienceLevel = null;
                      }
                    });
                    _filterJobs();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
