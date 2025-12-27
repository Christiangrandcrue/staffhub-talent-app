import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/api_service.dart';

class JobsProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Job> _jobs = [];
  Job? _selectedJob;
  bool _isLoading = false;
  String? _error;
  String _cityFilter = 'All';
  int _currentPage = 1;
  int _totalPages = 1;
  
  // Local cache of applied job IDs (workaround for backend bug)
  final Set<int> _appliedJobIds = {};
  
  JobsProvider({required ApiService apiService}) : _apiService = apiService;
  
  // Check if job is applied (from cache or API)
  bool isJobApplied(int jobId) => _appliedJobIds.contains(jobId);
  
  List<Job> get jobs => _jobs;
  Job? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get cityFilter => _cityFilter;
  bool get hasMore => _currentPage < _totalPages;
  
  void setCityFilter(String city) {
    if (_cityFilter != city) {
      _cityFilter = city;
      loadJobs(refresh: true);
    }
  }
  
  Future<void> loadJobs({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 1;
      _jobs = [];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getJobs(
        city: _cityFilter == 'All' ? null : _cityFilter,
        page: _currentPage,
      );
      
      if (refresh) {
        _jobs = response.jobs;
      } else {
        _jobs.addAll(response.jobs);
      }
      _totalPages = response.totalPages;
      _currentPage++;
      _error = null;
      
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('401') || errorStr.contains('authenticated')) {
        _error = 'Сессия истекла. Перезайдите в приложение.';
      } else if (errorStr.contains('интернет') || errorStr.contains('connection')) {
        _error = 'Нет подключения к интернету';
      } else if (errorStr.contains('timeout')) {
        _error = 'Сервер не отвечает. Попробуйте позже.';
      } else {
        _error = 'Ошибка загрузки: $errorStr';
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadJobDetails(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedJob = await _apiService.getJobDetails(jobId);
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> applyForJob(int jobId, {String? coverMessage}) async {
    try {
      await _apiService.applyForJob(jobId, coverMessage: coverMessage);
      
      // Mark as applied locally
      _appliedJobIds.add(jobId);
      
      // Update local state
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        // Mark as applied by reloading
        await loadJobs(refresh: true);
      }
      if (_selectedJob?.id == jobId) {
        await loadJobDetails(jobId);
      }
      
      _error = null;
      return true;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      
      // Handle "Already applied" - mark locally and show friendly message
      if (errorStr.contains('already applied') || errorStr.contains('already_applied')) {
        _appliedJobIds.add(jobId);
        _error = 'Вы уже откликнулись на эту вакансию';
      } else if (errorStr.contains('409')) {
        _appliedJobIds.add(jobId);
        _error = 'Вы уже откликнулись на эту вакансию';
      } else if (errorStr.contains('emirates')) {
        _error = 'Для этой вакансии нужен Emirates ID';
      } else if (errorStr.contains('no slots') || errorStr.contains('slots')) {
        _error = 'Все места заняты';
      } else {
        _error = 'Ошибка отклика: $e';
      }
      
      notifyListeners();
      return false;
    }
  }
  
  // Load user's applications to sync applied status
  Future<void> syncAppliedJobs() async {
    try {
      final applications = await _apiService.getMyApplications();
      _appliedJobIds.clear();
      for (final app in applications) {
        _appliedJobIds.add(app.jobPostId);
      }
      notifyListeners();
    } catch (_) {
      // Silent fail - use existing cache
    }
  }
  
  void clearSelectedJob() {
    _selectedJob = null;
    notifyListeners();
  }
}
