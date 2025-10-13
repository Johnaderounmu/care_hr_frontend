import 'package:flutter/material.dart';

void main() {
  runApp(const CareHRiOSTest());
}

class CareHRiOSTest extends StatelessWidget {
  const CareHRiOSTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care HR iOS Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const IOSTestHomePage(),
    );
  }
}

class IOSTestHomePage extends StatefulWidget {
  const IOSTestHomePage({super.key});

  @override
  State<IOSTestHomePage> createState() => _IOSTestHomePageState();
}

class _IOSTestHomePageState extends State<IOSTestHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Care HR - iOS Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.business_center,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Care HR System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Successfully running on iOS!'),
            const SizedBox(height: 30),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DemoFeaturesPage(),
                  ),
                );
              },
              child: const Text('View Demo Features'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DemoFeaturesPage extends StatelessWidget {
  const DemoFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care HR Demo Features'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FeatureCard(
            icon: Icons.people,
            title: 'HR Dashboard',
            description: 'Manage employees, view analytics, and track performance.',
            color: Colors.blue,
          ),
          FeatureCard(
            icon: Icons.work,
            title: 'Job Listings',
            description: 'Post job openings and manage applications.',
            color: Colors.green,
          ),
          FeatureCard(
            icon: Icons.description,
            title: 'Document Management',
            description: 'Upload, review, and manage HR documents.',
            color: Colors.orange,
          ),
          FeatureCard(
            icon: Icons.analytics,
            title: 'Reports & Analytics',
            description: 'Generate reports and view data insights.',
            color: Colors.purple,
          ),
          FeatureCard(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'Stay updated with real-time notifications.',
            color: Colors.red,
          ),
          FeatureCard(
            icon: Icons.calendar_today,
            title: 'Interview Scheduling',
            description: 'Schedule and manage job interviews.',
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}