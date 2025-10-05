import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class UserSearchBar extends StatelessWidget {
  final String? hintText;
  final Function(String) onSearchChanged;
  final String? initialValue;
  final bool enabled;

  const UserSearchBar({
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
          hintText: hintText ?? 'Search users by name, email, department...',
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

class AdvancedUserSearchBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearchChanged;
  final Map<String, dynamic>? initialFilters;

  const AdvancedUserSearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialFilters,
  });

  @override
  State<AdvancedUserSearchBar> createState() => _AdvancedUserSearchBarState();
}

class _AdvancedUserSearchBarState extends State<AdvancedUserSearchBar> {
  late TextEditingController _searchController;
  String _selectedRole = '';
  String _selectedStatus = '';
  String _selectedDepartment = '';
  String _selectedManager = '';

  final List<String> _roles = [
    'Admin',
    'HR',
    'Applicant',
  ];

  final List<String> _statuses = [
    'Active',
    'Inactive',
    'Suspended',
    'Pending',
  ];

  final List<String> _departments = [
    'Human Resources',
    'Engineering',
    'Design',
    'Product',
    'Marketing',
    'Sales',
    'Operations',
    'IT',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    if (widget.initialFilters != null) {
      _searchController.text = widget.initialFilters!['query'] ?? '';
      _selectedRole = widget.initialFilters!['role'] ?? '';
      _selectedStatus = widget.initialFilters!['status'] ?? '';
      _selectedDepartment = widget.initialFilters!['department'] ?? '';
      _selectedManager = widget.initialFilters!['manager'] ?? '';
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
      'role': _selectedRole.isEmpty ? null : _selectedRole,
      'status': _selectedStatus.isEmpty ? null : _selectedStatus,
      'department': _selectedDepartment.isEmpty ? null : _selectedDepartment,
      'manager': _selectedManager.isEmpty ? null : _selectedManager,
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
              hintText: 'Search users by name, email, department...',
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
                label: 'Role',
                value: _selectedRole,
                items: _roles,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value ?? '';
                  });
                  _updateSearch();
                },
              ),
              _buildDropdown(
                label: 'Status',
                value: _selectedStatus,
                items: _statuses,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? '';
                  });
                  _updateSearch();
                },
              ),
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
                label: 'Manager',
                value: _selectedManager,
                items: ['John Smith', 'Sarah Johnson', 'Michael Chen'],
                onChanged: (value) {
                  setState(() {
                    _selectedManager = value ?? '';
                  });
                  _updateSearch();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clear Filters Button
          if (_selectedRole.isNotEmpty ||
              _selectedStatus.isNotEmpty ||
              _selectedDepartment.isNotEmpty ||
              _selectedManager.isNotEmpty ||
              _searchController.text.isNotEmpty)
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedRole = '';
                      _selectedStatus = '';
                      _selectedDepartment = '';
                      _selectedManager = '';
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
