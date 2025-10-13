import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EnhancedApiService {
  static String get baseUrl {
    const url = 'http://localhost:4000';
    // For Android emulator, replace localhost with 10.0.2.2 to access host machine
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }
  static String? _token;
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        _token = data['token'];
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      // Return mock success for offline demo
      if (email == 'admin@careehr.com' || email == 'test@example.com') {
        return {
          'success': true, 
          'user': {
            'id': '1',
            'email': email,
            'fullName': 'Demo User',
            'role': email.contains('admin') ? 'HR_ADMIN' : 'APPLICANT'
          }, 
          'token': 'demo_token_123'
        };
      }
      return {'success': false, 'error': 'Network error. Using offline mode.'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String email, 
    String password, 
    String fullName,
    {String role = 'applicant'}
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        _token = data['token'];
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Jobs endpoints
  static Future<List<Map<String, dynamic>>> getJobs({Map<String, dynamic>? filters}) async {
    try {
      String url = '$baseUrl/api/jobs';
      if (filters != null && filters.isNotEmpty) {
        final params = filters.entries
            .where((e) => e.value != null)
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        if (params.isNotEmpty) {
          url += '?$params';
        }
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        List<Map<String, dynamic>> jobs = [];
        
        if (data is List) {
          // Direct array response
          jobs = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['jobs'] != null) {
          // Wrapped in jobs object
          jobs = List<Map<String, dynamic>>.from(data['jobs']);
        } else {
          // Fallback: treat as empty array
          jobs = [];
        }
        
        // Return mock data if no jobs or if jobs are malformed
        if (jobs.isEmpty) {
          return _getMockJobs();
        }
        
        return jobs;
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching jobs: $e');
      }
      // Return mock data for offline mode or errors
      return _getMockJobs();
    }
  }

  static List<Map<String, dynamic>> _getMockJobs() {
    return [
      {
        'id': '1',
        'title': 'Senior Flutter Developer',
        'department': 'Engineering',
        'location': 'Remote',
        'type': 'full-time',
        'status': 'published',
        'description': 'We are seeking a skilled Flutter developer to join our growing team.',
        'requirements': 'Flutter, Dart, REST APIs, State Management',
        'salaryRange': '\$90,000 - \$130,000',
        'experienceLevel': 'senior',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'title': 'Product Manager',
        'department': 'Product',
        'location': 'San Francisco, CA',
        'type': 'full-time',
        'status': 'published',
        'description': 'Join our product team to help shape the future of our HR platform.',
        'requirements': 'Product Management, Analytics, Leadership, Agile',
        'salaryRange': '\$120,000 - \$160,000',
        'experienceLevel': 'mid',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'title': 'HR Specialist',
        'department': 'Human Resources',
        'location': 'New York, NY',
        'type': 'full-time',
        'status': 'published',
        'description': 'Help manage our growing team and improve HR processes.',
        'requirements': 'HR Experience, Communication, HRIS Systems, Compliance',
        'salaryRange': '\$65,000 - \$85,000',
        'experienceLevel': 'mid',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }
    ];
  }

  static Future<Map<String, dynamic>?> createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/jobs'),
        headers: headers,
        body: jsonEncode(jobData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create job');
      }
    } catch (e) {
      debugPrint('Error creating job: $e');
      return null;
    }
  }

  // Applications endpoints
  static Future<List<Map<String, dynamic>>> getApplications({
    String? status,
    String? jobId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (jobId != null) queryParams['jobId'] = jobId;

      final uri = Uri.parse('$baseUrl/api/applications').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      debugPrint('Error fetching applications: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> submitApplication(Map<String, dynamic> applicationData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/applications'),
        headers: headers,
        body: jsonEncode(applicationData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit application');
      }
    } catch (e) {
      debugPrint('Error submitting application: $e');
      return null;
    }
  }

  static Future<bool> updateApplicationStatus(String applicationId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/applications/$applicationId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating application status: $e');
      return false;
    }
  }

  // Documents endpoints
  static Future<List<Map<String, dynamic>>> getDocuments({
    String? status,
    String? type,
    String? uploadedById,
  }) async {
    try {
      String endpoint = '/api/documents/my-documents';
      if (uploadedById != null) {
        endpoint = '/api/documents/all';
      }

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (uploadedById != null) queryParams['uploadedById'] = uploadedById;

      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching documents: $e');
      }
      // Return mock data for offline mode or errors
      return _getMockDocuments();
    }
  }

  static List<Map<String, dynamic>> _getMockDocuments() {
    return [
      {
        'id': '1',
        'filename': 'john_doe_resume.pdf',
        'originalName': 'John Doe Resume.pdf',
        'type': 'resume',
        'status': 'approved',
        'uploadedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'uploadedById': '2',
        'uploaderName': 'John Doe',
        'size': 245760,
        'mimeType': 'application/pdf',
        'url': 'https://example.com/documents/john_doe_resume.pdf',
        'jobApplicationId': '1',
      },
      {
        'id': '2',
        'filename': 'jane_smith_cover_letter.pdf',
        'originalName': 'Jane Smith Cover Letter.pdf',
        'type': 'cover_letter',
        'status': 'pending',
        'uploadedAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'uploadedById': '3',
        'uploaderName': 'Jane Smith',
        'size': 156432,
        'mimeType': 'application/pdf',
        'url': 'https://example.com/documents/jane_smith_cover_letter.pdf',
        'jobApplicationId': '2',
      },
      {
        'id': '3',
        'filename': 'mike_johnson_portfolio.zip',
        'originalName': 'Mike Johnson Portfolio.zip',
        'type': 'portfolio',
        'status': 'requires_update',
        'uploadedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'uploadedById': '4',
        'uploaderName': 'Mike Johnson',
        'size': 5242880,
        'mimeType': 'application/zip',
        'url': 'https://example.com/documents/mike_johnson_portfolio.zip',
        'jobApplicationId': '3',
        'reviewNotes': 'Please update portfolio with recent projects',
      },
    ];
  }

  static Future<Map<String, dynamic>?> uploadDocument(Map<String, dynamic> documentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/documents/upload'),
        headers: headers,
        body: jsonEncode(documentData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to upload document');
      }
    } catch (e) {
      debugPrint('Error uploading document: $e');
      return null;
    }
  }

  static Future<bool> updateDocumentStatus(
    String documentId, 
    String status, 
    {String? reviewNotes}
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/documents/$documentId/status'),
        headers: headers,
        body: jsonEncode({
          'status': status,
          if (reviewNotes != null) 'reviewNotes': reviewNotes,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating document status: $e');
      return false;
    }
  }

  // Reports endpoints
  static Future<Map<String, dynamic>?> getDashboardAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reports/analytics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getApplicationStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/api/reports/applications-stats')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load application stats');
      }
    } catch (e) {
      debugPrint('Error fetching application stats: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getHiringPipelineData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reports/hiring-pipeline'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load hiring pipeline data');
      }
    } catch (e) {
      debugPrint('Error fetching hiring pipeline data: $e');
      return null;
    }
  }

  // Notifications endpoints
  static Future<Map<String, dynamic>?> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'unreadOnly': unreadOnly.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/notifications')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notifications: $e');
      }
      // Return mock data for offline mode or errors
      return _getMockNotifications(page, limit, unreadOnly);
    }
  }

  static Map<String, dynamic> _getMockNotifications(int page, int limit, bool unreadOnly) {
    final mockNotifications = [
      {
        'id': '1',
        'title': 'New Job Application',
        'message': 'John Doe applied for Senior Flutter Developer position',
        'type': 'application_received',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'userId': 'hr-1',
        'metadata': {'applicationId': '1', 'jobId': '1'},
      },
      {
        'id': '2',
        'title': 'Document Review Required',
        'message': 'Jane Smith uploaded a new resume for Product Manager position',
        'type': 'document_uploaded',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'userId': 'hr-1',
        'metadata': {'documentId': '2', 'applicationId': '2'},
      },
      {
        'id': '3',
        'title': 'Interview Scheduled',
        'message': 'Interview with Mike Johnson scheduled for tomorrow at 2 PM',
        'type': 'interview_scheduled',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'userId': 'hr-1',
        'metadata': {'interviewId': '1', 'applicationId': '3'},
      },
      {
        'id': '4',
        'title': 'Application Status Updated',
        'message': 'Sarah Wilson\'s application moved to interview stage',
        'type': 'status_updated',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'userId': 'hr-1',
        'metadata': {'applicationId': '4', 'status': 'interview'},
      },
    ];

    List<Map<String, dynamic>> filteredNotifications = mockNotifications;
    if (unreadOnly) {
      filteredNotifications = mockNotifications.where((n) => !(n['read'] as bool)).toList();
    }

    // Simple pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedNotifications = filteredNotifications.length > startIndex
        ? filteredNotifications.sublist(
            startIndex,
            endIndex > filteredNotifications.length ? filteredNotifications.length : endIndex,
          )
        : <Map<String, dynamic>>[];

    return {
      'notifications': paginatedNotifications,
      'totalCount': filteredNotifications.length,
      'currentPage': page,
      'totalPages': (filteredNotifications.length / limit).ceil(),
      'hasNextPage': page * limit < filteredNotifications.length,
      'hasPreviousPage': page > 1,
    };
  }

  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error fetching notification count: $e');
      return 0;
    }
  }

  // Interviews endpoints
  static Future<List<Map<String, dynamic>>> getInterviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/interviews/my-interviews'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load interviews');
      }
    } catch (e) {
      debugPrint('Error fetching interviews: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> scheduleInterview(Map<String, dynamic> interviewData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/interviews/schedule'),
        headers: headers,
        body: jsonEncode(interviewData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to schedule interview');
      }
    } catch (e) {
      debugPrint('Error scheduling interview: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getUpcomingInterviews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/interviews/upcoming/list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load upcoming interviews');
      }
    } catch (e) {
      debugPrint('Error fetching upcoming interviews: $e');
      return [];
    }
  }

  // Helper method to check backend availability
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      return false;
    }
  }
}