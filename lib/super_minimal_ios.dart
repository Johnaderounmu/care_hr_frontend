import 'package:flutter/material.dart';

void main() {
  runApp(const SuperMinimalApp());
}

class SuperMinimalApp extends StatelessWidget {
  const SuperMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello iOS!'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_iphone,
                size: 64,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Flutter App Running on iOS!',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '🎉 Success! 🎉',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.thumb_up),
        ),
      ),
    );
  }
}