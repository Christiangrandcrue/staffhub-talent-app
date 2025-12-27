import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../main.dart' show pushService;

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  
  AuthState _state = AuthState.initial;
  User? _user;
  TalentProfile? _profile;
  String? _errorMessage;
  
  AuthProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;
  
  AuthState get state => _state;
  User? get user => _user;
  TalentProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  
  Future<void> init() async {
    await _storageService.init();
    
    final token = _storageService.getToken();
    if (token != null) {
      _apiService.setToken(token);
      _user = _storageService.getUser();
      _profile = _storageService.getProfile();
      _state = AuthState.authenticated;
      
      // Try to refresh profile in background
      _refreshProfile();
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
  
  Future<void> _refreshProfile() async {
    try {
      final newProfile = await _apiService.getProfile();
      _profile = newProfile;
      await _storageService.saveProfile(newProfile);
      notifyListeners();
    } catch (_) {
      // Silent fail - use cached profile
    }
  }
  
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(email, password);
      
      _user = response.user;
      _profile = response.profile;
      
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);
      await _storageService.saveProfile(response.profile);
      
      _state = AuthState.authenticated;
      notifyListeners();
      
      // Initialize push notifications after login
      await pushService.initialize();
      
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    // Unregister FCM token before logout
    await pushService.unregisterToken();
    
    _apiService.clearToken();
    await _storageService.clearAll();
    
    _user = null;
    _profile = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
  
  String _getErrorMessage(String error) {
    if (error.contains('Invalid email or password')) {
      return 'Неверный email или пароль';
    }
    if (error.contains('Token expired')) {
      return 'Сессия истекла, войдите снова';
    }
    return 'Ошибка авторизации. Попробуйте снова.';
  }
}
