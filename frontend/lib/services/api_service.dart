// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_constants.dart';
import 'package:http_parser/http_parser.dart'; // IMPORTANT: Add this import
import 'dart:typed_data';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  // Helper function to handle responses (now an instance method)
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Failed to parse JSON or invalid JSON format: $e');
      }
    } else {
      // Attempt to decode the error message from the response body
      try {
        final errorBody = jsonDecode(response.body);
        final detail =
            errorBody['detail'] ?? 'Unknown error'; // Use default if 'detail' is missing
        throw Exception('Request failed with status: ${response.statusCode}, detail: $detail');
      } catch (e) {
        throw Exception('Request failed with status: ${response.statusCode}, body: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

Future<Map<String, dynamic>> signup(
    String name,
    String username,
    String email,
    String password,
    String gender,
    String currentLocation,
    String college,
    List<String> interests,
    Uint8List? imageBytes, // Correct type
    String? imageFileName, // Correct type
  ) async {
    final url = Uri.parse('$baseUrl/signup');

    var request = http.MultipartRequest('POST', url);

    request.fields['name'] = name;
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['gender'] = gender;
    request.fields['current_location'] = currentLocation;
    request.fields['college'] = college;
    request.fields['interests'] = jsonEncode(interests);

    if (imageBytes != null && imageFileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName,  // Correct: Use the parameter
          contentType: MediaType('image', _getFileExtension(imageFileName)), // Correct
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

    String _getFileExtension(String fileName) {
    try {
      return fileName.split('.').last.toLowerCase();
    } catch (e) {
      return 'jpeg'; // Default to jpeg if extraction fails
    }
  }


  Future<List<dynamic>> fetchPosts(String? token) async {
    final url = '$baseUrl/posts';
    final Map<String, String> headers = {}; // Explicitly define as Map<String, String>
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = await _handleResponse(response);
    return (data['posts'] as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> fetchCommunities(String? token) async {
    final url = '$baseUrl/communities';
    final Map<String, String> headers = {}; // Explicit type
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = await _handleResponse(response);
    return (data['communities'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> vote(
      String? postId, String? replyId, bool voteType, String token) async {
    final url = '$baseUrl/votes';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'post_id': postId,
        'reply_id': replyId,
        'vote_type': voteType,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> fetchUserDetails(String token) async {
    final url = Uri.parse('$baseUrl/me'); // Use Uri.parse
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createCommunity(
      String name, String description, String primaryLocation, String token) async {
    final url = '$baseUrl/communities';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'primary_location': primaryLocation
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createPost(
      String title, String content, int? communityId, String token) async {
    final url = '$baseUrl/posts';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'community_id': communityId, // Send as null if not provided
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deletePost(String postId, String token) async {
    final url = '$baseUrl/posts/$postId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteCommunity(String communityId, String token) async {
    final url = '$baseUrl/communities/$communityId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createReply(
      String postId, String content, String? parentReplyId, String token) async {
    final url = '$baseUrl/replies';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'post_id': postId,
        'content': content,
        'parent_reply_id': parentReplyId, // Can be null
      }),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> fetchReplies(String postId, String? token) async {
    final url = '$baseUrl/replies/$postId';
    final Map<String, String> headers = {}; // Explicit type
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = await _handleResponse(response);
    return (data['replies'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> deleteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/$replyId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // Removed 'static' from all the following methods
  Future<Map<String, dynamic>> joinCommunity(String communityId, String token) async {
    final url = '$baseUrl/communities/$communityId/join';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> leaveCommunity(String communityId, String token) async {
    final url = '$baseUrl/communities/$communityId/leave';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> favoritePost(String postId, String token) async {
    final url = '$baseUrl/posts/$postId/favorite';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> unfavoritePost(String postId, String token) async {
    final url = '$baseUrl/posts/$postId/unfavorite';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> favoriteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/$replyId/favorite';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> unfavoriteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/$replyId/unfavorite';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // Community Post Management
  Future<Map<String, dynamic>> addPostToCommunity(
      String communityId, String postId, String token) async {
    final url = '$baseUrl/communities/$communityId/add_post/$postId';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> removePostFromCommunity(
      String communityId, String postId, String token) async {
    final url = '$baseUrl/communities/$communityId/remove_post/$postId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }
}