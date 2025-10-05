import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class UserFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final Color? color;

  const UserFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : chipColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : chipColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RoleFilterChip extends StatelessWidget {
  final String role;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const RoleFilterChip({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return UserFilterChip(
      label: role,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: _getRoleIcon(role),
      color: _getRoleColor(role),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'hr':
        return Icons.people;
      case 'applicant':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'hr':
        return AppColors.primary;
      case 'applicant':
        return AppColors.success;
      default:
        return AppColors.mutedLight;
    }
  }
}

class StatusFilterChip extends StatelessWidget {
  final String status;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const StatusFilterChip({
    super.key,
    required this.status,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return UserFilterChip(
      label: status,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: _getStatusIcon(status),
      color: _getStatusColor(status),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.cancel;
      case 'suspended':
        return Icons.pause_circle;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.circle;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.mutedLight;
      case 'suspended':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      default:
        return AppColors.mutedLight;
    }
  }
}

class DepartmentFilterChip extends StatelessWidget {
  final String department;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const DepartmentFilterChip({
    super.key,
    required this.department,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return UserFilterChip(
      label: department,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: _getDepartmentIcon(department),
      color: _getDepartmentColor(department),
    );
  }

  IconData _getDepartmentIcon(String department) {
    switch (department.toLowerCase()) {
      case 'human resources':
        return Icons.people;
      case 'engineering':
        return Icons.engineering;
      case 'design':
        return Icons.design_services;
      case 'product':
        return Icons.analytics;
      case 'marketing':
        return Icons.campaign;
      case 'sales':
        return Icons.sell;
      case 'operations':
        return Icons.settings;
      case 'it':
        return Icons.computer;
      default:
        return Icons.business;
    }
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'human resources':
        return AppColors.primary;
      case 'engineering':
        return AppColors.success;
      case 'design':
        return AppColors.warning;
      case 'product':
        return AppColors.info;
      case 'marketing':
        return Colors.purple;
      case 'sales':
        return Colors.orange;
      case 'operations':
        return AppColors.mutedLight;
      case 'it':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }
}

class ManagerFilterChip extends StatelessWidget {
  final String manager;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const ManagerFilterChip({
    super.key,
    required this.manager,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return UserFilterChip(
      label: manager,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: Icons.supervisor_account,
      color: AppColors.info,
    );
  }
}

class PermissionFilterChip extends StatelessWidget {
  final String permission;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const PermissionFilterChip({
    super.key,
    required this.permission,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return UserFilterChip(
      label: permission,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: Icons.security,
      color: _getPermissionColor(permission),
    );
  }

  Color _getPermissionColor(String permission) {
    if (permission.toLowerCase().contains('admin') ||
        permission.toLowerCase().contains('delete')) {
      return AppColors.error;
    } else if (permission.toLowerCase().contains('create') ||
        permission.toLowerCase().contains('edit')) {
      return AppColors.warning;
    } else if (permission.toLowerCase().contains('view') ||
        permission.toLowerCase().contains('read')) {
      return AppColors.success;
    } else {
      return AppColors.primary;
    }
  }
}
