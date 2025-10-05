import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/document_model.dart';

class DocumentStatusFilter extends StatelessWidget {
  final DocumentStatus? selectedStatus;
  final Function(DocumentStatus?) onStatusChanged;

  const DocumentStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Status',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: 'All',
                isSelected: selectedStatus == null,
                onTap: () => onStatusChanged(null),
              ),
              const SizedBox(width: 8),
              ...DocumentStatus.values.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    context,
                    label: status.displayName,
                    isSelected: selectedStatus == status,
                    statusColor: _getStatusColor(status),
                    onTap: () => onStatusChanged(status),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? statusColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (statusColor ?? AppColors.primary).withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (statusColor ?? AppColors.primary)
                : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusColor != null && isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (statusColor ?? AppColors.primary)
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
      case DocumentStatus.approved:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
      case DocumentStatus.expired:
        return AppColors.error;
      case DocumentStatus.pending:
      case DocumentStatus.uploaded:
        return AppColors.warning;
      case DocumentStatus.reviewed:
        return AppColors.info;
    }
  }
}

class DocumentTypeFilter extends StatelessWidget {
  final String? selectedType;
  final Function(String?) onTypeChanged;

  const DocumentTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    const documentTypes = DocumentType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Type',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              context,
              label: 'All Types',
              isSelected: selectedType == null,
              onTap: () => onTypeChanged(null),
            ),
            ...documentTypes.map((type) {
              return _buildFilterChip(
                context,
                label: type.displayName,
                isSelected: selectedType == type.toString().split('.').last,
                onTap: () => onTypeChanged(type.toString().split('.').last),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class DocumentDateFilter extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final Function(DateTimeRange?) onDateRangeChanged;

  const DocumentDateFilter({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Date',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                context,
                label: 'All Time',
                isSelected: selectedDateRange == null,
                onTap: () => onDateRangeChanged(null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateButton(
                context,
                label: 'Last 7 Days',
                isSelected: _isLast7Days(),
                onTap: () => onDateRangeChanged(
                  DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 7)),
                    end: DateTime.now(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                context,
                label: 'Last 30 Days',
                isSelected: _isLast30Days(),
                onTap: () => onDateRangeChanged(
                  DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateButton(
                context,
                label: 'Custom Range',
                isSelected: _isCustomRange(),
                onTap: () => _selectCustomDateRange(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  bool _isLast7Days() {
    if (selectedDateRange == null) return false;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return selectedDateRange!.start.isAtSameMomentAs(weekAgo) &&
        selectedDateRange!.end.isAtSameMomentAs(now);
  }

  bool _isLast30Days() {
    if (selectedDateRange == null) return false;
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return selectedDateRange!.start.isAtSameMomentAs(monthAgo) &&
        selectedDateRange!.end.isAtSameMomentAs(now);
  }

  bool _isCustomRange() {
    if (selectedDateRange == null) return false;
    return !_isLast7Days() && !_isLast30Days();
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      onDateRangeChanged(picked);
    }
  }
}

