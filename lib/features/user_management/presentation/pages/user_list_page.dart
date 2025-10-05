import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
// Removed unused app_strings import
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/extended_user_model.dart';
import '../../data/services/user_management_service.dart';
import '../widgets/user_card.dart';
import '../widgets/user_filter_chip.dart';
import '../widgets/user_search_bar.dart';
import '../../../../core/models/user_role.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<ExtendedUserModel> _users = [];
  List<ExtendedUserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  UserRole? _selectedRole;
  UserStatus? _selectedStatus;
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await UserManagementService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          final matchesSearch =
              user.firstName.toLowerCase().contains(lowerQuery) ||
                  user.lastName.toLowerCase().contains(lowerQuery) ||
                  user.email.toLowerCase().contains(lowerQuery) ||
                  user.department?.toLowerCase().contains(lowerQuery) == true ||
                  user.jobTitle?.toLowerCase().contains(lowerQuery) == true ||
                  user.skills
                      .any((skill) => skill.toLowerCase().contains(lowerQuery));

          if (!matchesSearch) return false;
        }

        // Role filter
        if (_selectedRole != null && user.role != _selectedRole) {
          return false;
        }

        // Status filter
        if (_selectedStatus != null && user.status != _selectedStatus) {
          return false;
        }

        // Department filter
        if (_selectedDepartment != null &&
            user.department != _selectedDepartment) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedRole = null;
      _selectedStatus = null;
      _selectedDepartment = null;
    });
    _filterUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeader(
        title: 'User Management',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/user-management/create-user'),
            icon: const Icon(Icons.person_add),
          ),
          IconButton(
            onPressed: _loadUsers,
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
                UserSearchBar(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                    _filterUsers();
                  },
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      UserFilterChip(
                        label: 'All Users',
                        isSelected: _selectedRole == null &&
                            _selectedStatus == null &&
                            _selectedDepartment == null,
                        onTap: _clearFilters,
                        count: _users.length,
                      ),
                      const SizedBox(width: 8),

                      // Role Filter
                      UserFilterChip(
                        label: 'Role',
                        isSelected: _selectedRole != null,
                        onTap: () => _showRoleFilter(),
                        count: _selectedRole != null ? 1 : null,
                        icon: Icons.person,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),

                      // Status Filter
                      UserFilterChip(
                        label: 'Status',
                        isSelected: _selectedStatus != null,
                        onTap: () => _showStatusFilter(),
                        count: _selectedStatus != null ? 1 : null,
                        icon: Icons.circle,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),

                      // Department Filter
                      UserFilterChip(
                        label: 'Department',
                        isSelected: _selectedDepartment != null,
                        onTap: () => _showDepartmentFilter(),
                        count: _selectedDepartment != null ? 1 : null,
                        icon: Icons.business,
                        color: AppColors.success,
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
                  '${_filteredUsers.length} user${_filteredUsers.length == 1 ? '' : 's'} found',
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
                    _selectedRole != null ||
                    _selectedStatus != null ||
                    _selectedDepartment != null)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: UserCard(
                                user: user,
                                onTap: () => context.push(
                                    '/user-management/user-details/${user.id}'),
                                onEdit: () => context.push(
                                    '/user-management/edit-user/${user.id}'),
                                onSuspend: () => _showSuspendUserDialog(user),
                                onActivate: () => _activateUser(user),
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
            Icons.people_outline,
            size: 64,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
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
            'Try adjusting your search criteria or create a new user.',
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

  void _showRoleFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Role',
        items: UserRole.values
            .map((role) => role.toString().split('.').last)
            .toList(),
        selectedItem: _selectedRole?.toString().split('.').last,
        onItemSelected: (role) {
          setState(() {
            _selectedRole = role != null
                ? UserRole.values
                    .firstWhere((r) => r.toString().split('.').last == role)
                : null;
          });
          _filterUsers();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Status',
        items: UserStatus.values
            .map((status) => status.toString().split('.').last)
            .toList(),
        selectedItem: _selectedStatus?.toString().split('.').last,
        onItemSelected: (status) {
          setState(() {
            _selectedStatus = status != null
                ? UserStatus.values
                    .firstWhere((s) => s.toString().split('.').last == status)
                : null;
          });
          _filterUsers();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDepartmentFilter() {
    final departments = _users
        .map((user) => user.department)
        .where((dept) => dept != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        title: 'Select Department',
        items: departments,
        selectedItem: _selectedDepartment,
        onItemSelected: (department) {
          setState(() {
            _selectedDepartment = department;
          });
          _filterUsers();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFilterBottomSheet({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Function(String?) onItemSelected,
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
                    onChanged: (value) => onItemSelected(value),
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
                    onItemSelected(null);
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

  void _showSuspendUserDialog(ExtendedUserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to suspend ${user.fullName}?'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason for suspension',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement suspend user
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.fullName} has been suspended')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _activateUser(ExtendedUserModel user) async {
    try {
      await UserManagementService.activateUser(user.id);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.fullName} has been activated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error activating user: $e')),
        );
      }
    }
  }
}
