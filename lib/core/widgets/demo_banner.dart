import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ApiService.isUsingMockData) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade700,
            Colors.orange.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.science,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🧪 DEMO MODE: Using mock data - full functionality available!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _showDemoInfo(context);
            },
            child: Text(
              'Learn More',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.science, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Demo Mode Active'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re experiencing a fully functional demo of the Care HR system!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('✅ All features are working:'),
            const SizedBox(height: 8),
            Text('• User registration and login'),
            Text('• Job browsing and search'),
            Text('• Application submission'),
            Text('• Real-time interface updates'),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Demo Data Information:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Using simulated backend responses with realistic job listings and user interactions. Data is not persisted between sessions.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }
}