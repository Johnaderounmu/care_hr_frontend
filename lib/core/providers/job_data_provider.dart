import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class JobDataService extends ChangeNotifier {
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get jobs => _jobs;
  List<Map<String, dynamic>> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load jobs from backend
  Future<void> loadJobs({Map<String, String>? filters}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.fetchJobs();
      if (response['success'] == true) {
        _jobs = List<Map<String, dynamic>>.from(response['jobs'] ?? []);
      } else {
        _setError(response['error'] ?? 'Failed to load jobs');
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to load jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search jobs
  Future<void> searchJobs(String query) async {
    _setLoading(true);
    _clearError();

    try {
      final jobsData = await ApiService.searchJobs(query);
      _jobs = jobsData;
      notifyListeners();
    } catch (e) {
      _setError('Failed to search jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get specific job
  Future<Map<String, dynamic>?> getJob(String jobId) async {
    try {
      return await ApiService.getJob(jobId);
    } catch (e) {
      _setError('Failed to get job details: $e');
      return null;
    }
  }

  // Submit job application
  Future<bool> submitApplication({
    required String jobId,
    required String applicantId,
    required Map<String, dynamic> applicationData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final application = {
        'jobId': jobId,
        'applicantId': applicantId,
        ...applicationData,
      };
      
      final result = await ApiService.submitApplication(application);
      
      if (result['success'] == true) {
        // Optionally update local state or reload jobs
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to submit application');
        return false;
      }
    } catch (e) {
      _setError('Failed to submit application: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user's applications
  Future<void> loadMyApplications() async {
    _setLoading(true);
    _clearError();

    try {
      final applicationsData = await ApiService.getMyApplications();
      _applications = applicationsData;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load applications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear data
  void clear() {
    _jobs.clear();
    _applications.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}