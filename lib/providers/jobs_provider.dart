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
  
  JobsProvider({required ApiService apiService}) : _apiService = apiService;
  
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
      
      // Update local state
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        // Mark as applied by reloading
        await loadJobs(refresh: true);
      }
      if (_selectedJob?.id == jobId) {
        await loadJobDetails(jobId);
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearSelectedJob() {
    _selectedJob = null;
    notifyListeners();
  }
}
