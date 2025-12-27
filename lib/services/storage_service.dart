import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _profileKey = 'profile_data';
  
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Token
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }
  
  String? getToken() {
    return _prefs?.getString(_tokenKey);
  }
  
  Future<void> clearToken() async {
    await _prefs?.remove(_tokenKey);
  }
  
  // User
  Future<void> saveUser(User user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  User? getUser() {
    final data = _prefs?.getString(_userKey);
    if (data == null) return null;
    return User.fromJson(jsonDecode(data));
  }
  
  // Profile
  Future<void> saveProfile(TalentProfile profile) async {
    await _prefs?.setString(_profileKey, jsonEncode(profile.toJson()));
  }
  
  TalentProfile? getProfile() {
    final data = _prefs?.getString(_profileKey);
    if (data == null) return null;
    return TalentProfile.fromJson(jsonDecode(data));
  }
  
  // Clear all
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
  
  // Check if logged in
  bool get isLoggedIn => getToken() != null;
}
