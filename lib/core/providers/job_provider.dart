import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/enhanced_api_service.dart';

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedDepartment;
  String? _selectedType;
  String? _selectedStatus;

  List<JobModel> get jobs => _filteredJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedDepartment => _selectedDepartment;
  String? get selectedType => _selectedType;
  String? get selectedStatus => _selectedStatus;

  List<String> get departments {
    final depts = _jobs.map((job) => job.department).toSet().toList();
    depts.sort();
    return depts;
  }

  List<String> get jobTypes {
    final types = _jobs.map((job) => job.type).toSet().toList();
    types.sort();
    return types;
  }

  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jobsData = await EnhancedApiService.getJobs();
      _jobs = jobsData.map((data) => JobModel.fromJson(data)).toList();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load jobs: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<JobModel?> createJob(Map<String, dynamic> jobData) async {
    try {
      final result = await EnhancedApiService.createJob(jobData);
      if (result != null) {
        final newJob = JobModel.fromJson(result);
        _jobs.insert(0, newJob);
        _applyFilters();
        notifyListeners();
        return newJob;
      }
    } catch (e) {
      _error = 'Failed to create job: ${e.toString()}';
      notifyListeners();
    }
    return null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setDepartmentFilter(String? department) {
    _selectedDepartment = department;
    _applyFilters();
    notifyListeners();
  }

  void setTypeFilter(String? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = null;
    _selectedType = null;
    _selectedStatus = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredJobs = _jobs.where((job) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = job.title.toLowerCase().contains(query);
        final matchesDescription = job.description.toLowerCase().contains(query);
        final matchesDepartment = job.department.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDescription && !matchesDepartment) {
          return false;
        }
      }

      // Department filter
      if (_selectedDepartment != null && job.department != _selectedDepartment) {
        return false;
      }

      // Type filter
      if (_selectedType != null && job.type != _selectedType) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && job.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();

    // Sort by creation date (newest first)
    _filteredJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  JobModel? getJobById(String id) {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  List<JobModel> getActiveJobs() {
    return _jobs.where((job) => job.status == 'active').toList();
  }

  List<JobModel> getJobsByDepartment(String department) {
    return _jobs.where((job) => job.department == department).toList();
  }

  int get totalJobs => _jobs.length;
  int get activeJobsCount => _jobs.where((job) => job.status == 'active').length;
  int get draftJobsCount => _jobs.where((job) => job.status == 'draft').length;
  int get closedJobsCount => _jobs.where((job) => job.status == 'closed').length;

  void refresh() {
    loadJobs();
  }
}