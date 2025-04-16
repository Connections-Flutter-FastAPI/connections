// lib/services/auth_service.dart
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http; // Use http alias
import 'api_base.dart'; // Import the base

class AuthService {
  final ApiBase _apiBase;

  AuthService(this._apiBase); // Inject ApiBase

  Future<Map<String, dynamic>> login(String email, String password) async {
    const path = '/login'; // Correct path for login
    print('AuthService: Attempting login for: $email');
    try {
      final response = await _apiBase.makeRequest(
        path,
        method: 'POST',
        body: {'email': email, 'password': password},
      );
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"token": ..., "user_id": ...}
      } else {
        throw Exception("Login response was not a valid map.");
      }
    } catch (e) {
      print("AuthService Login error: $e");
      throw Exception("Login failed: $e");
    }
  }

  Future<Map<String, dynamic>> signup(
      String name, String username, String email, String password, String gender,
      String currentLocation, String college, List<String> interests,
      Uint8List? imageBytes, String? imageFileName) async {

    const path = '/signup'; // Correct path for signup
    print('AuthService: Attempting signup for: $username');
    // Use MultipartRequest directly as ApiBase doesn't handle it yet
    var request = http.MultipartRequest('POST', Uri.parse('${_apiBase.baseUrl}$path'));

    // Add fields
    request.fields['name'] = name;
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['gender'] = gender;
    request.fields['current_location'] = currentLocation; // Ensure format like '(lon,lat)'
    request.fields['college'] = college;
    for (String interest in interests) {
      request.fields['interests'] = interest; // Correct way for List[str] = Form(...)
    }

    // Add file
    if (imageBytes != null && imageFileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', imageBytes, filename: imageFileName,
          contentType: MediaType('image', _getFileExtension(imageFileName)),
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      // Use handleResponse for status check and decoding
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"token": ..., "user_id": ...}
      } else {
        throw Exception("Signup response was not a valid map.");
      }
    } catch (e) {
      print("AuthService Signup error: $e");
      throw Exception("Signup request failed: $e");
    }
  }

  // Helper (can be private or moved to utils)
  String _getFileExtension(String fileName) {
     try {
        final parts = fileName.split('.');
        if (parts.length > 1) {
           return parts.last.toLowerCase();
        }
        return 'jpeg'; // Default if no extension
     } catch (e) { return 'jpeg'; }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String token) async {
    const path = '/me'; // Correct path for /me
    print('AuthService: Fetching user details...');
    try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects UserDisplay schema
      } else {
        throw Exception("Fetch user details response was not a valid map.");
      }
    } catch (e) {
      print("AuthService fetchUserDetails error: $e");
      throw Exception("Failed to fetch user details: $e");
    }
  }
}
