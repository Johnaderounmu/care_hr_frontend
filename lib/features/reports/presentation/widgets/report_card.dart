import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onDownload,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Report Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Report Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // Report Details
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.category,
                    label: report.category.displayName,
                    color: _getCategoryColor(),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.description,
                    label: report.type.displayName,
                    color: AppColors.info,
                  ),
                  if (report.recordCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.numbers,
                      label: '${report.recordCount} records',
                      color: AppColors.success,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  // Generated Info
                  Icon(
                    Icons.person,
                    size: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'By ${report.generatedBy}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                  ),

                  const Spacer(),

                  // Time
                  Text(
                    report.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                  ),

                  const SizedBox(width: 8),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'download':
                          onDownload?.call();
                          break;
                        case 'share':
                          onShare?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 18),
                            SizedBox(width: 8),
                            Text('Download'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 18),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.primary,
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

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (report.status) {
      case ReportStatus.pending:
        statusColor = AppColors.info;
        statusText = 'Pending';
        break;
      case ReportStatus.processing:
        statusColor = AppColors.warning;
        statusText = 'Processing';
        break;
      case ReportStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case ReportStatus.failed:
        statusColor = AppColors.error;
        statusText = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (report.category) {
      case ReportCategory.applications:
        return AppColors.primary;
      case ReportCategory.interviews:
        return AppColors.info;
      case ReportCategory.users:
        return AppColors.success;
      case ReportCategory.jobs:
        return AppColors.warning;
      case ReportCategory.documents:
        return Colors.purple;
      case ReportCategory.performance:
        return Colors.orange;
      case ReportCategory.compliance:
        return AppColors.error;
      case ReportCategory.system:
        return AppColors.mutedLight;
    }
  }

  IconData _getCategoryIcon() {
    switch (report.category) {
      case ReportCategory.applications:
        return Icons.description;
      case ReportCategory.interviews:
        return Icons.event;
      case ReportCategory.users:
        return Icons.people;
      case ReportCategory.jobs:
        return Icons.work;
      case ReportCategory.documents:
        return Icons.folder;
      case ReportCategory.performance:
        return Icons.trending_up;
      case ReportCategory.compliance:
        return Icons.security;
      case ReportCategory.system:
        return Icons.settings;
    }
  }
}

class CompactReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const CompactReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Report Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                  size: 16,
                ),
              ),

              const SizedBox(width: 12),

              // Report Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status Indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 8),

              // Download Button
              if (report.isCompleted && onDownload != null)
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (report.category) {
      case ReportCategory.applications:
        return AppColors.primary;
      case ReportCategory.interviews:
        return AppColors.info;
      case ReportCategory.users:
        return AppColors.success;
      case ReportCategory.jobs:
        return AppColors.warning;
      case ReportCategory.documents:
        return Colors.purple;
      case ReportCategory.performance:
        return Colors.orange;
      case ReportCategory.compliance:
        return AppColors.error;
      case ReportCategory.system:
        return AppColors.mutedLight;
    }
  }

  IconData _getCategoryIcon() {
    switch (report.category) {
      case ReportCategory.applications:
        return Icons.description;
      case ReportCategory.interviews:
        return Icons.event;
      case ReportCategory.users:
        return Icons.people;
      case ReportCategory.jobs:
        return Icons.work;
      case ReportCategory.documents:
        return Icons.folder;
      case ReportCategory.performance:
        return Icons.trending_up;
      case ReportCategory.compliance:
        return Icons.security;
      case ReportCategory.system:
        return Icons.settings;
    }
  }

  Color _getStatusColor() {
    switch (report.status) {
      case ReportStatus.pending:
        return AppColors.info;
      case ReportStatus.processing:
        return AppColors.warning;
      case ReportStatus.completed:
        return AppColors.success;
      case ReportStatus.failed:
        return AppColors.error;
    }
  }
}
