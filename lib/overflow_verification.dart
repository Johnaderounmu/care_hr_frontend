import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'features/dashboard/presentation/widgets/dashboard_card.dart';
import 'features/dashboard/presentation/widgets/chart_card.dart';

void main() {
  runApp(OverflowVerificationApp());
}

class OverflowVerificationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow Verification Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OverflowVerificationPage(),
    );
  }
}

class OverflowVerificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overflow Verification - All Fixed Components'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Cards (Fixed - Aspect Ratio 2.2)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2, // Fixed from 1.8
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
                  title: AppStrings.pendingReviews, // Fixed: shortened from "Pending Document Reviews"
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
            SizedBox(height: 32),
            Text(
              'Chart Cards (Fixed - Aspect Ratio 1.1)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1, // Fixed from 0.9
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ChartCard(
                  title: 'Applications This Week',
                  value: '42',
                  chart: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.trending_up, color: AppColors.primary),
                    ),
                  ),
                ),
                ChartCard(
                  title: 'Document Processing Rate',
                  value: '89%',
                  chart: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.bar_chart, color: AppColors.success),
                    ),
                  ),
                ),
                ChartCard(
                  title: 'Interview Success Rate',
                  value: '76%',
                  chart: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.pie_chart, color: AppColors.warning),
                    ),
                  ),
                ),
                ChartCard(
                  title: 'Employee Satisfaction',
                  value: '4.2/5',
                  chart: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.speed, color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Long Text Test (Fixed - Flexible Wrapping)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 40),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Very Long Title That Should Wrap Properly Without Causing Overflow Issues',
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'This is a very long subtitle that demonstrates the flexible text wrapping fixes implemented to prevent overflow',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Overflow Fixes Applied:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Dashboard card aspect ratio: 1.8 → 2.2'),
                  Text('• Chart card aspect ratio: 0.9 → 1.1'),
                  Text('• Icon sizes reduced: 48x48 → 40x40'),
                  Text('• Text styles: headlineMedium → headlineSmall'),
                  Text('• Added Flexible widgets around text'),
                  Text('• Shortened "Pending Document Reviews" → "Pending Reviews"'),
                  Text('• Added mainAxisSize: MainAxisSize.min'),
                  Text('• Proper overflow handling with ellipsis'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}