import 'package:flutter/material.dart';

void main() {
  runApp(const StandaloneHRApp());
}

class StandaloneHRApp extends StatelessWidget {
  const StandaloneHRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareHR iOS Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // Use Material 2 for better iOS compatibility
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareHR System'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Status',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const StatusRow(
                        icon: Icons.check_circle,
                        text: 'iOS Demo Running',
                        color: Colors.green,
                      ),
                      const StatusRow(
                        icon: Icons.smartphone,
                        text: 'Native iOS Build',
                        color: Colors.blue,
                      ),
                      const StatusRow(
                        icon: Icons.business,
                        text: 'HR System Active',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Features Grid
              Text(
                'HR Management Features',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    FeatureCard(
                      title: 'Jobs',
                      icon: Icons.work,
                      description: 'Manage job postings',
                      color: Colors.blue[600]!,
                    ),
                    FeatureCard(
                      title: 'Applications',
                      icon: Icons.assignment,
                      description: 'Track applications',
                      color: Colors.green[600]!,
                    ),
                    FeatureCard(
                      title: 'Interviews',
                      icon: Icons.event,
                      description: 'Schedule meetings',
                      color: Colors.orange[600]!,
                    ),
                    FeatureCard(
                      title: 'Documents',
                      icon: Icons.folder,
                      description: 'File management',
                      color: Colors.purple[600]!,
                    ),
                    FeatureCard(
                      title: 'Reports',
                      icon: Icons.analytics,
                      description: 'HR analytics',
                      color: Colors.red[600]!,
                    ),
                    FeatureCard(
                      title: 'Users',
                      icon: Icons.people,
                      description: 'User management',
                      color: Colors.teal[600]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const StatusRow({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color color;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title feature tapped!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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