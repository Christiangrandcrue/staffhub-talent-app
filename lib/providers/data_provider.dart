import 'package:flutter/foundation.dart';
import '../models/application.dart';
import '../models/assignment.dart';
import '../models/document.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Application> _applications = [];
  List<Assignment> _assignments = [];
  List<TalentDocument> _documents = [];
  Map<String, dynamic>? _ratings;
  
  bool _isLoadingApplications = false;
  bool _isLoadingAssignments = false;
  bool _isLoadingDocuments = false;
  bool _isLoadingRatings = false;
  
  String? _error;
  
  DataProvider({required ApiService apiService}) : _apiService = apiService;
  
  // Getters
  List<Application> get applications => _applications;
  List<Assignment> get assignments => _assignments;
  List<TalentDocument> get documents => _documents;
  Map<String, dynamic>? get ratings => _ratings;
  
  bool get isLoadingApplications => _isLoadingApplications;
  bool get isLoadingAssignments => _isLoadingAssignments;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isLoadingRatings => _isLoadingRatings;
  
  String? get error => _error;
  
  // Applications
  Future<void> loadApplications() async {
    if (_isLoadingApplications) return;
    
    _isLoadingApplications = true;
    _error = null;
    notifyListeners();
    
    try {
      _applications = await _apiService.getMyApplications();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoadingApplications = false;
    notifyListeners();
  }
  
  // Assignments
  Future<void> loadAssignments() async {
    if (_isLoadingAssignments) return;
    
    _isLoadingAssignments = true;
    _error = null;
    notifyListeners();
    
    try {
      _assignments = await _apiService.getMyAssignments();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoadingAssignments = false;
    notifyListeners();
  }
  
  List<Assignment> getAssignmentsForDate(DateTime date) {
    return _assignments.where((a) {
      try {
        final eventDate = DateTime.parse(a.eventDate);
        return eventDate.year == date.year &&
               eventDate.month == date.month &&
               eventDate.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }
  
  // Documents
  Future<void> loadDocuments() async {
    if (_isLoadingDocuments) return;
    
    _isLoadingDocuments = true;
    _error = null;
    notifyListeners();
    
    try {
      _documents = await _apiService.getDocuments();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoadingDocuments = false;
    notifyListeners();
  }
  
  int get validDocumentsCount => 
      _documents.where((d) => d.status == DocumentStatus.valid).length;
  
  int get expiringDocumentsCount => 
      _documents.where((d) => d.isExpiringSoon).length;
  
  int get expiredDocumentsCount => 
      _documents.where((d) => d.isExpired || d.status == DocumentStatus.expired).length;
  
  // Ratings
  Future<void> loadRatings() async {
    if (_isLoadingRatings) return;
    
    _isLoadingRatings = true;
    _error = null;
    notifyListeners();
    
    try {
      _ratings = await _apiService.getMyRatings();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoadingRatings = false;
    notifyListeners();
  }
  
  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadApplications(),
      loadAssignments(),
      loadDocuments(),
      loadRatings(),
    ]);
  }
  
  void clearAll() {
    _applications = [];
    _assignments = [];
    _documents = [];
    _ratings = null;
    _error = null;
    notifyListeners();
  }
}
