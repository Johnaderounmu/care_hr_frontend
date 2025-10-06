import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'features/dashboard/presentation/widgets/dashboard_card.dart';

void main() {
  runApp(OverflowTestApp());
}

class OverflowTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OverflowTestPage(),
    );
  }
}

class OverflowTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overflow Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 2.2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: const [
            DashboardCard(
              title: AppStrings.activeApplicants,
              value: '125',
              icon: Icons.people,
              color: AppColors.primary,
            ),
            DashboardCard(
              title: AppStrings.pendingReviews,
              value: '32',
              icon: Icons.description,
              color: AppColors.warning,
            ),
            DashboardCard(
              title: AppStrings.upcomingExpirations,
              value: '15',
              icon: Icons.schedule,
              color: AppColors.error,
            ),
            DashboardCard(
              title: AppStrings.recentlyUploaded,
              value: '20',
              icon: Icons.cloud_upload,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}