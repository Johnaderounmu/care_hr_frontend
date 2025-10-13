import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Testing backend connection...');
  
  try {
    // Test health endpoint
    final healthResponse = await http.get(
      Uri.parse('http://localhost:4000/health'),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('Health check status: ${healthResponse.statusCode}');
    print('Health response: ${healthResponse.body}');
    
    // Test auth endpoints
    final loginResponse = await http.post(
      Uri.parse('http://localhost:4000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'test@example.com',
        'password': 'password123'
      }),
    );
    
    print('Login status: ${loginResponse.statusCode}');
    print('Login response: ${loginResponse.body}');
    
    // Test jobs endpoint (should work without auth)
    final jobsResponse = await http.get(
      Uri.parse('http://localhost:4000/api/jobs'),
      headers: {'Content-Type': 'application/json'},
    );
    
    print('Jobs status: ${jobsResponse.statusCode}');
    print('Jobs response: ${jobsResponse.body}');
    
  } catch (e) {
    print('Error: $e');
  }
}