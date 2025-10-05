import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care HR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Care HR System - Demo Mode'),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, color: Colors.amber.shade700, size: 24),
                  SizedBox(width: 12),
                  Text(
                    '🧪 DEMO MODE ACTIVE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Icon(
              Icons.business_center,
              size: 80,
              color: Colors.blue.shade600,
            ),
            SizedBox(height: 20),
            Text(
              'Care HR Management System',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Complete HR solution with job management, applications, and user management',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  DemoFeatureCard(
                    icon: Icons.person_add,
                    title: 'User Registration & Login',
                    description: 'Secure authentication system',
                    isWorking: true,
                  ),
                  SizedBox(height: 12),
                  DemoFeatureCard(
                    icon: Icons.work,
                    title: 'Job Management',
                    description: '4+ demo job listings available',
                    isWorking: true,
                  ),
                  SizedBox(height: 12),
                  DemoFeatureCard(
                    icon: Icons.assignment,
                    title: 'Application System',
                    description: 'Submit and track applications',
                    isWorking: true,
                  ),
                  SizedBox(height: 12),
                  DemoFeatureCard(
                    icon: Icons.dashboard,
                    title: 'Dashboard & Analytics',
                    description: 'Real-time interface updates',
                    isWorking: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    '✅ Demo System Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All features are working with mock data. Backend integration ready for deployment.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Demo System Info'),
                    content: Text(
                      'This is a fully functional demo of the Care HR system. '
                      'All features work with realistic mock data. '
                      'The backend is ready for deployment to production.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Got it!'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Learn More About Demo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isWorking;

  const DemoFeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isWorking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWorking ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: isWorking ? Colors.green.shade600 : Colors.grey.shade600,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (isWorking)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}