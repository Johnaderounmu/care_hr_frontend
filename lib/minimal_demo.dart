import 'package:flutter/material.dart';

void main() {
  runApp(const MinimalHRApp());
}

class MinimalHRApp extends StatelessWidget {
  const MinimalHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareHR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareHR System Demo'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Backend API Running'),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Flutter Demo Active'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'Job Management',
                    Icons.work,
                    'Create, edit, and manage job postings',
                  ),
                  _buildFeatureCard(
                    context,
                    'Applications',
                    Icons.assignment,
                    'Track and review job applications',
                  ),
                  _buildFeatureCard(
                    context,
                    'Interviews',
                    Icons.event,
                    'Schedule and manage interviews',
                  ),
                  _buildFeatureCard(
                    context,
                    'Documents',
                    Icons.folder,
                    'Store and organize HR documents',
                  ),
                  _buildFeatureCard(
                    context,
                    'Reports',
                    Icons.analytics,
                    'Generate HR analytics and reports',
                  ),
                  _buildFeatureCard(
                    context,
                    'User Management',
                    Icons.people,
                    'Manage HR staff and applicants',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature demo')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}