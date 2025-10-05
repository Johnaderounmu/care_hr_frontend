import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class JobSearchBar extends StatelessWidget {
  final String? hintText;
  final Function(String) onSearchChanged;
  final String? initialValue;
  final bool enabled;

  const JobSearchBar({
    super.key,
    this.hintText,
    required this.onSearchChanged,
    this.initialValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextFormField(
        enabled: enabled,
        initialValue: initialValue,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search jobs, companies, skills...',
          hintStyle: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          suffixIcon: initialValue != null && initialValue!.isNotEmpty
              ? IconButton(
                  onPressed: () => onSearchChanged(''),
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class AdvancedSearchBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearchChanged;
  final Map<String, dynamic>? initialFilters;

  const AdvancedSearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialFilters,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar> {
  late TextEditingController _searchController;
  String _selectedDepartment = '';
  String _selectedLocation = '';
  String _selectedExperienceLevel = '';
  String _selectedEmploymentType = '';
  String _salaryRange = '';

  final List<String> _departments = [
    'Engineering',
    'Design',
    'Product',
    'Marketing',
    'Data & Analytics',
    'Sales',
    'Operations',
    'Human Resources',
  ];

  final List<String> _locations = [
    'San Francisco, CA',
    'New York, NY',
    'Austin, TX',
    'Chicago, IL',
    'Seattle, WA',
    'Remote',
    'Hybrid',
  ];

  final List<String> _experienceLevels = [
    'Entry Level',
    'Mid-level',
    'Senior',
    'Lead',
    'Director',
  ];

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance',
  ];

  final List<String> _salaryRanges = [
    'Under \$50,000',
    '\$50,000 - \$75,000',
    '\$75,000 - \$100,000',
    '\$100,000 - \$125,000',
    '\$125,000 - \$150,000',
    '\$150,000 - \$200,000',
    'Over \$200,000',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    if (widget.initialFilters != null) {
      _searchController.text = widget.initialFilters!['query'] ?? '';
      _selectedDepartment = widget.initialFilters!['department'] ?? '';
      _selectedLocation = widget.initialFilters!['location'] ?? '';
      _selectedExperienceLevel =
          widget.initialFilters!['experienceLevel'] ?? '';
      _selectedEmploymentType = widget.initialFilters!['employmentType'] ?? '';
      _salaryRange = widget.initialFilters!['salaryRange'] ?? '';
    }

    _updateSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch() {
    final filters = {
      'query': _searchController.text,
      'department': _selectedDepartment.isEmpty ? null : _selectedDepartment,
      'location': _selectedLocation.isEmpty ? null : _selectedLocation,
      'experienceLevel':
          _selectedExperienceLevel.isEmpty ? null : _selectedExperienceLevel,
      'employmentType':
          _selectedEmploymentType.isEmpty ? null : _selectedEmploymentType,
      'salaryRange': _salaryRange.isEmpty ? null : _salaryRange,
    };

    widget.onSearchChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (_) => _updateSearch(),
            decoration: InputDecoration(
              hintText: 'Search jobs, companies, skills...',
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _updateSearch();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),

          // Filter Dropdowns
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDropdown(
                label: 'Department',
                value: _selectedDepartment,
                items: _departments,
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value ?? '';
                  });
                  _updateSearch();
                },
              ),
              _buildDropdown(
                label: 'Location',
                value: _selectedLocation,
                items: _locations,
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value ?? '';
                  });
                  _updateSearch();
                },
              ),
              _buildDropdown(
                label: 'Experience',
                value: _selectedExperienceLevel,
                items: _experienceLevels,
                onChanged: (value) {
                  setState(() {
                    _selectedExperienceLevel = value ?? '';
                  });
                  _updateSearch();
                },
              ),
              _buildDropdown(
                label: 'Type',
                value: _selectedEmploymentType,
                items: _employmentTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedEmploymentType = value ?? '';
                  });
                  _updateSearch();
                },
              ),
              _buildDropdown(
                label: 'Salary',
                value: _salaryRange,
                items: _salaryRanges,
                onChanged: (value) {
                  setState(() {
                    _salaryRange = value ?? '';
                  });
                  _updateSearch();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clear Filters Button
          if (_selectedDepartment.isNotEmpty ||
              _selectedLocation.isNotEmpty ||
              _selectedExperienceLevel.isNotEmpty ||
              _selectedEmploymentType.isNotEmpty ||
              _salaryRange.isNotEmpty ||
              _searchController.text.isNotEmpty)
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedDepartment = '';
                      _selectedLocation = '';
                      _selectedExperienceLevel = '';
                      _selectedEmploymentType = '';
                      _salaryRange = '';
                    });
                    _updateSearch();
                  },
                  child: const Text('Clear All Filters'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Any',
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Any'),
              ),
              ...items.map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  )),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

