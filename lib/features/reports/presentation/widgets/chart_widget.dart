import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ChartWidget extends StatelessWidget {
  final String title;
  final String chartType;
  final Map<String, dynamic> data;
  final List<Color> colors;
  final VoidCallback? onTap;

  const ChartWidget({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
    required this.colors,
    this.onTap,
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _getChartIcon(chartType),
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Chart Content
              Expanded(
                child: _buildChartContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 32,
              color: AppColors.mutedLight.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: TextStyle(
                color: AppColors.mutedLight.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    switch (chartType) {
      case 'pie':
      case 'doughnut':
        return _buildPieChart();
      case 'bar':
        return _buildBarChart();
      case 'line':
        return _buildLineChart();
      default:
        return _buildSimpleChart();
    }
  }

  Widget _buildPieChart() {
    final entries = data.entries.toList();
    final total = entries.fold<double>(
        0, (sum, entry) => sum + (entry.value as num).toDouble());

    if (total == 0) {
      return const Center(child: Text('No data'));
    }

    return Column(
      children: [
        // Pie chart representation
        Expanded(
          child: Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: PieChartPainter(
                  entries: entries,
                  colors: colors,
                  isDoughnut: chartType == 'doughnut',
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Legend
        Wrap(
          spacing: 4,
          runSpacing: 2,
          children: entries.asMap().entries.take(2).map((entry) {
            final index = entry.key;
            final dataEntry = entry.value;
            final color = colors[index % colors.length];
            final percentage =
                ((dataEntry.value as num).toDouble() / total * 100)
                    .toStringAsFixed(0);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '${dataEntry.key} ($percentage%)',
                  style: const TextStyle(fontSize: 8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final entries = data.entries.toList();
    final maxValue = entries.isEmpty
        ? 0
        : entries
            .map((e) => (e.value as num).toDouble())
            .reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return const Center(child: Text('No data'));
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: entries.take(3).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final dataEntry = entry.value;
              final value = (dataEntry.value as num).toDouble();
              final height = maxValue > 0 ? (value / maxValue) : 0.0;
              final color = colors[index % colors.length];

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 50 * height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dataEntry.key.length > 4 
                          ? dataEntry.key.substring(0, 4) + '...' 
                          : dataEntry.key,
                        style: const TextStyle(fontSize: 7),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    final entries = data.entries.toList();

    if (entries.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: LineChartPainter(
              entries: entries,
              color: colors.first,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${entries.length} data points',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.mutedLight.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleChart() {
    return Column(
      children: data.entries.map((entry) {
        final index = data.entries.toList().indexOf(entry);
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${entry.value}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getChartIcon(String type) {
    switch (type) {
      case 'pie':
        return Icons.pie_chart;
      case 'doughnut':
        return Icons.donut_large;
      case 'bar':
        return Icons.bar_chart;
      case 'line':
        return Icons.show_chart;
      default:
        return Icons.analytics;
    }
  }
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, dynamic>> entries;
  final List<Color> colors;
  final bool isDoughnut;

  PieChartPainter({
    required this.entries,
    required this.colors,
    this.isDoughnut = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = isDoughnut ? radius * 0.4 : 0.0;

    final total = entries.fold<double>(
        0, (sum, entry) => sum + (entry.value as num).toDouble());

    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final value = (entry.value as num).toDouble();
      final sweepAngle = (value / total) * 2 * math.pi;
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      if (isDoughnut) {
        final innerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(center, innerRadius, innerPaint);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
  final List<MapEntry<String, dynamic>> entries;
  final Color color;

  LineChartPainter({
    required this.entries,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final values = entries.map((e) => (e.value as num).toDouble()).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (i / (entries.length - 1)) * size.width;
      final normalizedValue = (values[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// math import already at top
