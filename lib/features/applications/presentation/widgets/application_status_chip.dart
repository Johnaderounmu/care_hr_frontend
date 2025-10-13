import 'package:flutter/material.dart';
import '../../../job_application/domain/models/job_application_model.dart';

class ApplicationStatusChip extends StatelessWidget {
  final ApplicationStatus status;
  final VoidCallback? onTap;

  const ApplicationStatusChip({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(),
            width: 1,
          ),
        ),
        child: Text(
          status.displayName,
          style: TextStyle(
            color: _getStatusColor(),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ApplicationStatus.submitted:
        return Colors.blue;
      case ApplicationStatus.underReview:
        return Colors.orange;
      case ApplicationStatus.shortlisted:
        return Colors.purple;
      case ApplicationStatus.interviewScheduled:
        return Colors.indigo;
      case ApplicationStatus.interviewCompleted:
        return Colors.teal;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.hired:
        return Colors.green;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
    }
  }
}