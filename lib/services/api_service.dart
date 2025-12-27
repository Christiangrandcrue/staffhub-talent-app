import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/user.dart';
import '../models/job.dart';
import '../models/application.dart';
import '../models/assignment.dart';
import '../models/document.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

class ApiService {
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (kDebugMode) {
      debugPrint('API Response [${response.statusCode}]: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
    }
    
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw ApiException('Invalid response format', statusCode: response.statusCode);
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    
    final error = body['error'] ?? body['message'] ?? 'Unknown error';
    throw ApiException(error, statusCode: response.statusCode);
  }

  // Auth endpoints
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    final data = await _handleResponse(response);
    if (data['success'] != true) {
      throw ApiException(data['error'] ?? 'Login failed');
    }
    
    final authResponse = AuthResponse.fromJson(data);
    _token = authResponse.token;
    return authResponse;
  }

  Future<String> refreshToken() async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/refresh'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    final newToken = data['data']['token'];
    _token = newToken;
    return newToken;
  }

  // Profile endpoints
  Future<TalentProfile> getProfile() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/talent/me'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    return TalentProfile.fromJson(data['data']);
  }

  // Jobs endpoints
  Future<JobsResponse> getJobs({String? city, int page = 1, int limit = 20}) async {
    if (_token == null) {
      throw ApiException('Not authenticated. Please login.', statusCode: 401);
    }
    
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (city != null && city.isNotEmpty && city != 'All') {
      queryParams['city'] = city;
    }
    
    final uri = Uri.parse('${AppConstants.baseUrl}/jobs')
        .replace(queryParameters: queryParams);
    
    if (kDebugMode) {
      debugPrint('GET Jobs: $uri');
      debugPrint('Headers: $_headers');
    }
    
    try {
      final response = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));
      final data = await _handleResponse(response);
      return JobsResponse.fromJson(data);
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    } on http.ClientException {
      throw ApiException('Ошибка соединения с сервером');
    }
  }

  Future<Job> getJobDetails(int jobId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/jobs/$jobId'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    return Job.fromJson(data['data']);
  }

  Future<int> applyForJob(int jobId, {String? coverMessage, int? expectedRate}) async {
    final body = <String, dynamic>{};
    if (coverMessage != null) body['cover_message'] = coverMessage;
    if (expectedRate != null) body['expected_rate'] = expectedRate;
    
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/jobs/$jobId/apply'),
      headers: _headers,
      body: jsonEncode(body),
    );
    
    final data = await _handleResponse(response);
    return data['data']['application_id'];
  }

  // Applications endpoints
  Future<List<Application>> getMyApplications() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/applications/my'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    final list = data['data'] as List? ?? [];
    return list.map((a) => Application.fromJson(a)).toList();
  }

  // Assignments endpoints
  Future<List<Assignment>> getMyAssignments() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/assignments/my'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    final list = data['data'] as List? ?? [];
    return list.map((a) => Assignment.fromJson(a)).toList();
  }

  // Documents endpoints
  Future<List<TalentDocument>> getDocuments() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/talent/documents'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    final list = data['data'] as List? ?? [];
    return list.map((d) => TalentDocument.fromJson(d)).toList();
  }

  // Ratings endpoint
  Future<Map<String, dynamic>> getMyRatings() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/ratings/my'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    return data['data'];
  }

  // FCM Device Registration endpoints
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceName,
  }) async {
    final body = {
      'fcm_token': fcmToken,
      'platform': platform,
    };
    if (deviceName != null) {
      body['device_name'] = deviceName;
    }
    
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/talent/device'),
      headers: _headers,
      body: jsonEncode(body),
    );
    
    await _handleResponse(response);
  }

  Future<void> unregisterDevice(String fcmToken) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/talent/device'),
      headers: _headers,
      body: jsonEncode({'fcm_token': fcmToken}),
    );
    
    await _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/talent/devices'),
      headers: _headers,
    );
    
    final data = await _handleResponse(response);
    return List<Map<String, dynamic>>.from(data['data'] ?? []);
  }
}
