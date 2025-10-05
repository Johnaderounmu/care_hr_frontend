import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:4000';
  static bool _useMockData = false;
  
  static String? _token;
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Mock data for demo
  static final List<Map<String, dynamic>> _mockJobs = [
    {
      'id': '1',
      'title': 'Senior Flutter Developer',
      'department': 'Engineering',
      'location': 'Remote',
      'type': 'full-time',
      'description': 'We are seeking a skilled Flutter developer to join our growing team. You will be responsible for developing cross-platform mobile applications and working closely with our design and backend teams.',
      'requirements': ['Flutter', 'Dart', 'REST APIs', 'State Management'],
      'salary': '\$90,000 - \$130,000',
      'status': 'active',
      'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String()
    },
    {
      'id': '2',
      'title': 'Product Manager',
      'department': 'Product',
      'location': 'San Francisco, CA',
      'type': 'full-time',
      'description': 'Join our product team to help shape the future of our HR platform. You will work with engineering, design, and stakeholders to define product roadmaps and features.',
      'requirements': ['Product Management', 'Analytics', 'Leadership', 'Agile'],
      'salary': '\$120,000 - \$160,000',
      'status': 'active',
      'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String()
    },
    {
      'id': '3',
      'title': 'UX/UI Designer',
      'department': 'Design',
      'location': 'New York, NY',
      'type': 'full-time',
      'description': 'We are looking for a creative UX/UI designer to help us create intuitive and beautiful user experiences for our HR management platform.',
      'requirements': ['Figma', 'User Research', 'Prototyping', 'Design Systems'],
      'salary': '\$80,000 - \$110,000',
      'status': 'active',
      'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String()
    },
    {
      'id': '4',
      'title': 'DevOps Engineer',
      'department': 'Engineering',
      'location': 'Austin, TX',
      'type': 'full-time',
      'description': 'Help us scale our infrastructure and improve our deployment processes. You will work on CI/CD, monitoring, and cloud infrastructure.',
      'requirements': ['Docker', 'Kubernetes', 'AWS', 'CI/CD'],
      'salary': '\$100,000 - \$140,000',
      'status': 'active',
      'createdAt': DateTime.now().subtract(Duration(days: 7)).toIso8601String()
    }
  ];

  static final Map<String, dynamic> _mockUser = {
    'id': 'demo-user-123',
    'email': 'demo@example.com',
    'fullName': 'Demo User',
    'role': 'applicant'
  };

  static Future<bool> _checkBackendAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      print('Backend unavailable, using mock data: $e');
      _useMockData = true;
      return false;
    }
  }

    // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Check backend availability first
    bool backendAvailable = await _checkBackendAvailability();
    
    if (!backendAvailable || _useMockData) {
      // Mock login for demo
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      _token = 'mock-jwt-token-123';
      
      return {
        'success': true, 
        'user': {
          ..._mockUser,
          'email': email,
          'role': email.contains('hr') ? 'hr_admin' : 'applicant'
        }, 
        'token': _token
      };
    }
    
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        _token = data['token'];
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      // Fallback to mock on network error
      _useMockData = true;
      return login(email, password); // Retry with mock
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    // Check backend availability first
    bool backendAvailable = await _checkBackendAvailability();
    
    if (!backendAvailable || _useMockData) {
      // Mock registration for demo
      await Future.delayed(Duration(milliseconds: 700)); // Simulate network delay
      _token = 'mock-jwt-token-456';
      
      return {
        'success': true, 
        'user': {
          'id': 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
          'fullName': fullName,
          'role': 'applicant'
        }, 
        'token': _token
      };
    }
    
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = data['token'];
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      // Fallback to mock on network error
      _useMockData = true;
      return register(email, password, fullName); // Retry with mock
    }
  }

  // Job endpoints
  static Future<Map<String, dynamic>> fetchJobs() async {
    if (_useMockData) {
      await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
      return {'success': true, 'jobs': _mockJobs};
    }
    
    try {
      final response = await http.get(
        Uri.parse('\$baseUrl/api/jobs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'jobs': data['jobs'] ?? []};
      } else {
        return {'success': false, 'error': 'Failed to fetch jobs'};
      }
    } catch (e) {
      // Fallback to mock data on network error
      _useMockData = true;
      return fetchJobs(); // Retry with mock
    }
  }

  static Future<Map<String, dynamic>?> getJob(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/jobs/$jobId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching job: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> searchJobs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/jobs/search?q=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching jobs: $e');
      return [];
    }
  }

  // Applications endpoints
  static Future<Map<String, dynamic>> submitApplication(Map<String, dynamic> application) async {
    if (_useMockData) {
      await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
      return {
        'success': true, 
        'application': {
          'id': 'app-${DateTime.now().millisecondsSinceEpoch}',
          ...application,
          'status': 'submitted',
          'submittedAt': DateTime.now().toIso8601String()
        }
      };
    }
    
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/api/applications'),
        headers: headers,
        body: jsonEncode(application),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'application': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'error': data['error'] ?? 'Failed to submit application'};
      }
    } catch (e) {
      // Fallback to mock on network error
      _useMockData = true;
      return submitApplication(application); // Retry with mock
    }
  }

  static Future<List<Map<String, dynamic>>> getMyApplications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/applications/my-applications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
  }

  // Health check
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }

  // Logout
  static void logout() {
    _token = null;
  }

  // Utility methods for demo mode
  static bool get isUsingMockData => _useMockData;
  
  static void enableMockMode() {
    _useMockData = true;
  }
  
  static void disableMockMode() {
    _useMockData = false;
  }
}