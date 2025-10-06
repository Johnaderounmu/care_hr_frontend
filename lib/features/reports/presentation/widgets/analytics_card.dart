import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;
  final String? subtitle;
  final VoidCallback? onTap;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              // Icon
              Icon(
                icon,
                color: color,
                size: 12,
              ),
              const SizedBox(width: 4),
              // Value and title - horizontal layout to fix overflow
              Expanded(
                child: Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Trend
              if (trend != null && trendUp != null) ...[
                const SizedBox(width: 3),
                Icon(
                  trendUp == true ? Icons.trending_up : Icons.trending_down,
                  size: 8,
                  color: trendUp == true ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 1),
                Text(
                  trend!,
                  style: TextStyle(
                    color: trendUp == true ? AppColors.success : AppColors.error,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}