import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class JobFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final Color? color;

  const JobFilterChip({
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
    return JobFilterChip(
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
      case 'engineering':
        return Icons.engineering;
      case 'design':
        return Icons.design_services;
      case 'product':
        return Icons.analytics;
      case 'marketing':
        return Icons.campaign;
      case 'data & analytics':
        return Icons.analytics_outlined;
      case 'sales':
        return Icons.sell;
      case 'operations':
        return Icons.settings;
      case 'human resources':
        return Icons.people;
      default:
        return Icons.business;
    }
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'engineering':
        return AppColors.primary;
      case 'design':
        return AppColors.warning;
      case 'product':
        return AppColors.info;
      case 'marketing':
        return AppColors.success;
      case 'data & analytics':
        return Colors.purple;
      case 'sales':
        return Colors.orange;
      case 'operations':
        return AppColors.mutedLight;
      case 'human resources':
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }
}

class LocationFilterChip extends StatelessWidget {
  final String location;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const LocationFilterChip({
    super.key,
    required this.location,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return JobFilterChip(
      label: location,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: _getLocationIcon(location),
      color: _getLocationColor(location),
    );
  }

  IconData _getLocationIcon(String location) {
    if (location.toLowerCase().contains('remote')) {
      return Icons.home_work;
    } else if (location.toLowerCase().contains('hybrid')) {
      return Icons.location_on;
    } else {
      return Icons.location_city;
    }
  }

  Color _getLocationColor(String location) {
    if (location.toLowerCase().contains('remote')) {
      return AppColors.success;
    } else if (location.toLowerCase().contains('hybrid')) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }
}

class ExperienceLevelFilterChip extends StatelessWidget {
  final String experienceLevel;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const ExperienceLevelFilterChip({
    super.key,
    required this.experienceLevel,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return JobFilterChip(
      label: experienceLevel,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: _getExperienceIcon(experienceLevel),
      color: _getExperienceColor(experienceLevel),
    );
  }

  IconData _getExperienceIcon(String level) {
    switch (level.toLowerCase()) {
      case 'entry level':
        return Icons.star_border;
      case 'mid-level':
        return Icons.star_half;
      case 'senior':
        return Icons.star;
      case 'lead':
        return Icons.star;
      case 'director':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }

  Color _getExperienceColor(String level) {
    switch (level.toLowerCase()) {
      case 'entry level':
        return AppColors.success;
      case 'mid-level':
        return AppColors.warning;
      case 'senior':
        return AppColors.primary;
      case 'lead':
        return AppColors.error;
      case 'director':
        return Colors.purple;
      default:
        return AppColors.mutedLight;
    }
  }
}

class EmploymentTypeFilterChip extends StatelessWidget {
  final String employmentType;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const EmploymentTypeFilterChip({
    super.key,
    required this.employmentType,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return JobFilterChip(
      label: employmentType,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: _getEmploymentTypeIcon(employmentType),
      color: _getEmploymentTypeColor(employmentType),
    );
  }

  IconData _getEmploymentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'full-time':
        return Icons.work;
      case 'part-time':
        return Icons.schedule;
      case 'contract':
        return Icons.assignment;
      case 'internship':
        return Icons.school;
      case 'freelance':
        return Icons.person;
      default:
        return Icons.work;
    }
  }

  Color _getEmploymentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full-time':
        return AppColors.primary;
      case 'part-time':
        return AppColors.warning;
      case 'contract':
        return AppColors.info;
      case 'internship':
        return AppColors.success;
      case 'freelance':
        return Colors.purple;
      default:
        return AppColors.mutedLight;
    }
  }
}

class SalaryRangeFilterChip extends StatelessWidget {
  final String salaryRange;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const SalaryRangeFilterChip({
    super.key,
    required this.salaryRange,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return JobFilterChip(
      label: salaryRange,
      isSelected: isSelected,
      onTap: onTap,
      count: count,
      icon: Icons.attach_money,
      color: _getSalaryRangeColor(salaryRange),
    );
  }

  Color _getSalaryRangeColor(String range) {
    if (range.toLowerCase().contains('under') ||
        range.toLowerCase().contains('50,000')) {
      return AppColors.success;
    } else if (range.toLowerCase().contains('50,000') ||
        range.toLowerCase().contains('75,000')) {
      return AppColors.warning;
    } else if (range.toLowerCase().contains('75,000') ||
        range.toLowerCase().contains('100,000')) {
      return AppColors.info;
    } else if (range.toLowerCase().contains('100,000') ||
        range.toLowerCase().contains('125,000')) {
      return AppColors.primary;
    } else if (range.toLowerCase().contains('125,000') ||
        range.toLowerCase().contains('150,000')) {
      return AppColors.error;
    } else if (range.toLowerCase().contains('150,000') ||
        range.toLowerCase().contains('200,000')) {
      return Colors.purple;
    } else {
      return Colors.pink;
    }
  }
}
