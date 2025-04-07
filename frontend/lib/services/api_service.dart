import 'dart:convert';
import 'dart:async'; // For StreamController
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart'; // Import WebSocket
import 'package:web_socket_channel/status.dart' as status; // For close codes
import '../app_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import '../models/chat_message_data.dart';
import '../models/event_model.dart'; // Import EventModel

class ApiService {
  final String baseUrl = AppConstants.baseUrl; // Keep HTTP for API
  final String wsBaseUrl = AppConstants.baseUrl.replaceFirst('http', 'ws');

  WebSocketChannel? _channel;
  StreamController<ChatMessageData> _messageStreamController = StreamController.broadcast();

  Stream<ChatMessageData> get messages => _messageStreamController.stream;

  // --- WebSocket Methods ---
  void connectWebSocket(String roomType, int roomId, String? token) {
    disconnectWebSocket();
    if (_messageStreamController.isClosed) {
      _messageStreamController = StreamController.broadcast();
    }

    // Construct URL, potentially adding token as query parameter if backend expects it
    final wsUrl = '$wsBaseUrl/ws/$roomType/$roomId${token != null ? '?token=$token' : ''}';
    print('Attempting to connect WebSocket: $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
            (message) {
          print('WebSocket Received: $message');
          try {
            final decoded = jsonDecode(message);
            if (decoded is Map<String, dynamic> && decoded.containsKey('message_id')) {
              final chatMessage = ChatMessageData.fromJson(decoded);
              if (!_messageStreamController.isClosed) {
                _messageStreamController.add(chatMessage);
              }
            } else {
              print("Received non-chat message or unexpected format via WebSocket: $decoded");
              if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
                if (!_messageStreamController.isClosed) {
                  _messageStreamController.addError("WebSocket Error: ${decoded['error']}");
                }
              }
            }
          } catch (e) {
            print('Error decoding/handling WebSocket message: $e');
            if (!_messageStreamController.isClosed) {
              _messageStreamController.addError('Failed to process message: $e');
            }
          }
        },
        onDone: () {
          print('WebSocket connection closed.');
          if (!_messageStreamController.isClosed) {
            // Add reconnection logic trigger here if desired
          }
          _channel = null;
        },
        onError: (error) {
          print('WebSocket error: $error');
          if (!_messageStreamController.isClosed) {
            _messageStreamController.addError('WebSocket Error: $error');
          }
          _channel = null;
        },
        cancelOnError: true,
      );
      print('WebSocket connection established.');
    } catch (e) {
      print('WebSocket connection failed: $e');
      if (!_messageStreamController.isClosed) {
        _messageStreamController.addError('WebSocket Connection Failed: $e');
      }
      _channel = null;
    }
  }

  void disconnectWebSocket() {
    if (_channel != null) {
      print('Closing WebSocket connection...');
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }

  void sendWebSocketMessage(String message) {
    if (_channel != null && _channel?.closeCode == null) {
      print('WebSocket Sending: $message');
      _channel!.sink.add(message);
    } else {
      print('WebSocket not connected, cannot send message.');
      throw Exception("WebSocket not connected."); // Throw error to signal failure
    }
  }

  // --- Helper for HTTP ---
  // Returns Future<dynamic> to handle different response types (Map, List, null)
  Future<dynamic> _handleResponse(http.Response response) async {
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}"); // Uncomment for deep debugging

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        // Handle 204 No Content or other empty successes by returning null
        return null;
      }
      try {
        final decoded = jsonDecode(response.body);
        return decoded; // Return the decoded data (could be Map or List)
      } catch (e) {
        print('JSON Decode Error in _handleResponse: $e');
        throw Exception('Failed to parse JSON response. Body: ${response.body}');
      }
    } else {
      // Error handling: Try to parse detail, fallback to body/status code
      String detail = 'Unknown error';
      try {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            detail = errorBody['detail'] ?? response.body;
          } else {
            detail = response.body;
          }
        } else {
          detail = response.reasonPhrase ?? 'Status code ${response.statusCode}';
        }
      } catch (e) {
        detail = response.body.isNotEmpty ? response.body : 'Status code ${response.statusCode}';
      }
      print('API Error: ${response.statusCode} - $detail');
      throw Exception('Request failed: $detail');
    }
  }

  // --- General Request Helper (Optional but Recommended) ---
  // Example: You might consolidate header logic etc. here
  Future<http.Response> _makeRequest(String path, {String method = 'GET', Map<String, String>? headers, dynamic body, String? token}) async {
    final url = Uri.parse('$baseUrl$path');
    final Map<String, String> requestHeaders = {'Content-Type': 'application/json', ...?headers};
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(url, headers: requestHeaders, body: body != null ? jsonEncode(body) : null);
      case 'PUT':
        return await http.put(url, headers: requestHeaders, body: body != null ? jsonEncode(body) : null);
      case 'DELETE':
        return await http.delete(url, headers: requestHeaders, body: body != null ? jsonEncode(body) : null);
      case 'GET':
      default:
        return await http.get(url, headers: requestHeaders);
    }
  }


  // --- Auth ---
  // Line ~174
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/login'; // Backend router prefix is empty for auth
    print('Attempting login for: $email');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        // Should not happen for successful login based on backend code
        throw Exception("Login response was not a valid map.");
      }
    } catch (e) {
      print("Error during login: $e");
      throw Exception("Login failed: $e");
    }
  }

  // Line ~225
  Future<Map<String, dynamic>> signup(
      String name,
      String username,
      String email,
      String password,
      String gender,
      String currentLocation, // Expects POINT string like '(lon,lat)'
      String college,
      List<String> interests,
      Uint8List? imageBytes,
      String? imageFileName) async {
    final url = Uri.parse('$baseUrl/signup'); // Backend router prefix is empty for auth
    print('Attempting signup for: $username');
    var request = http.MultipartRequest('POST', url);

    request.fields['name'] = name;
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['gender'] = gender;
    request.fields['current_location'] = currentLocation; // Ensure format like '(lon,lat)'
    request.fields['college'] = college;

    // Send interests correctly for FastAPI Form(List[str])
    for (String interest in interests) {
      request.fields['interests'] = interest;
    }

    if (imageBytes != null && imageFileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name expected by backend
          imageBytes,
          filename: imageFileName,
          contentType: MediaType('image', _getFileExtension(imageFileName)),
        ),
      );
      print('Adding image to signup request: $imageFileName');
    } else {
      print('No image provided for signup.');
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Returns token + user_id on success
      } else {
        throw Exception("Signup response was not a valid map.");
      }
    } catch (e) {
      print("Error during signup request: $e");
      throw Exception("Signup request failed: $e");
    }
  }

  String _getFileExtension(String fileName) {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
      return validExtensions.contains(ext) ? ext : 'jpeg';
    } catch (e) {
      return 'jpeg';
    }
  }

  // Line ~251 -> Corrected path
  Future<Map<String, dynamic>> fetchUserDetails(String token) async {
    final url = Uri.parse('$baseUrl/me'); // Correct endpoint from backend/routers/auth.py
    print('Fetching user details...');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Backend returns UserDisplay schema
      } else {
        throw Exception("Fetch user details response was not a valid map.");
      }
    } catch(e) {
      print("Error fetching user details: $e");
      throw Exception("Failed to fetch user details: $e");
    }
  }

  // --- Posts ---
  Future<List<dynamic>> fetchPosts(String? token, {int? communityId, int? userId}) async {
    final Map<String, String> queryParams = {};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (userId != null) queryParams['user_id'] = userId.toString();

    final url = Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    print("Fetching posts from URL: $url");

    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns a List directly for this endpoint based on routers/posts.py
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return []; // Handle empty success
      } else {
        throw Exception("Fetch posts response was not a valid list.");
      }
    } catch (e) {
      print("Error fetching posts: $e");
      throw Exception("Failed to load posts: $e");
    }
  }

  Future<List<dynamic>> fetchTrendingPosts(String? token) async {
    final url = Uri.parse('$baseUrl/posts/trending');
    print("Fetching trending posts from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns a List directly
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch trending posts response was not a valid list.");
      }
    } catch (e) {
      print("Error fetching trending posts: $e");
      throw Exception("Failed to load trending posts: $e");
    }
  }

  // Line ~311
  Future<Map<String, dynamic>> createPost(
      String title, String content, int? communityId, String token) async {
    final url = '$baseUrl/posts';
    print('Creating post: $title');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'title': title,
          'content': content,
          if (communityId != null) 'community_id': communityId,
        }),
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns PostDisplay schema (Map)
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Create post response was not a valid map.");
      }
    } catch(e) {
      print("Error creating post: $e");
      throw Exception("Failed to create post: $e");
    }
  }

  // Line ~326
  Future<Map<String, dynamic>> deletePost(String postId, String token) async {
    // Backend expects int ID in path
    final url = '$baseUrl/posts/${int.tryParse(postId) ?? 0}';
    print('Deleting post ID: $postId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      // Check for 204 No Content specifically
      if (response.statusCode == 204) {
        return {"message": "Post deleted successfully"};
      }
      // If not 204, handle potential error response body
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Return error details if available
      } else {
        // This case handles if _handleResponse returned null unexpectedly on error
        throw Exception("Delete post failed with status ${response.statusCode}");
      }
    } catch(e) {
      print("Error deleting post: $e");
      throw Exception("Failed to delete post: $e");
    }
  }

  // --- Communities ---
  Future<List<dynamic>> fetchCommunities(String? token) async {
    final url = Uri.parse('$baseUrl/communities');
    print("Fetching communities from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns List directly based on routers/communities.py
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch communities response was not a valid list.");
      }
    } catch (e) {
      print("Error fetching communities: $e");
      throw Exception("Failed to load communities: $e");
    }
  }

  Future<List<dynamic>> fetchTrendingCommunities(String? token) async {
    final url = Uri.parse('$baseUrl/communities/trending');
    print("Fetching trending communities from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns List directly
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch trending communities response was not a valid list.");
      }
    } catch (e) {
      print("Error fetching trending communities: $e");
      throw Exception("Failed to load trending communities: $e");
    }
  }

  // Line ~373
  Future<Map<String, dynamic>> fetchCommunityDetails(String communityId, String? token) async {
    // Backend expects int ID in path
    final url = Uri.parse('$baseUrl/communities/${int.tryParse(communityId) ?? 0}/details');
    print("Fetching community details from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns CommunityDisplay schema (Map)
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Fetch community details response was not a valid map.");
      }
    } catch(e) {
      print("Error fetching community details: $e");
      throw Exception("Failed to fetch community details: $e");
    }
  }

  // Line ~390
  Future<Map<String, dynamic>> createCommunity(
      String name, String? description, String primaryLocation, String? interest, String token) async {
    final url = '$baseUrl/communities';
    print('Creating community: $name');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'primary_location': primaryLocation, // Ensure format '(lon,lat)'
          'interest': interest,
        }),
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns CommunityDisplay schema (Map)
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Create community response was not a valid map.");
      }
    } catch(e) {
      print("Error creating community: $e");
      throw Exception("Failed to create community: $e");
    }
  }

  // Line ~403
  Future<Map<String, dynamic>> deleteCommunity(String communityId, String token) async {
    // Backend expects int ID in path
    final url = '$baseUrl/communities/${int.tryParse(communityId) ?? 0}';
    print('Deleting community ID: $communityId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 204) {
        return {"message": "Community deleted successfully"};
      }
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Return error details
      } else {
        throw Exception("Delete community failed with status ${response.statusCode}");
      }
    } catch(e) {
      print("Error deleting community: $e");
      throw Exception("Failed to delete community: $e");
    }
  }

  // --- Voting ---
  // Line ~420
  Future<Map<String, dynamic>> vote(
      {int? postId, int? replyId, required bool voteType, required String token}) async {
    final url = '$baseUrl/votes';
    print('Voting: post=$postId, reply=$replyId, type=$voteType');
    final Map<String, dynamic> body = {'vote_type': voteType};
    if (postId != null) body['post_id'] = postId;
    if (replyId != null) body['reply_id'] = replyId;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns a message map like {"message": "Vote updated", ...}
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        // Handle cases where a successful vote might return an empty body (though unlikely based on backend)
        return {"message": "Vote operation successful (empty response)"};
      }
      else {
        throw Exception("Vote response was not a valid map.");
      }
    } catch(e) {
      print("Error during vote: $e");
      throw Exception("Vote failed: $e");
    }
  }

  // --- Replies ---
  // Line ~437
  Future<Map<String, dynamic>> createReply(
      int postId, String content, int? parentReplyId, String token) async {
    final url = '$baseUrl/replies';
    print('Creating reply for post $postId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'post_id': postId,
          'content': content,
          'parent_reply_id': parentReplyId,
        }),
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns ReplyDisplay schema (Map)
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Create reply response was not a valid map.");
      }
    } catch(e) {
      print("Error creating reply: $e");
      throw Exception("Failed to create reply: $e");
    }
  }

  Future<List<dynamic>> fetchReplies(String postId, String? token) async {
    // Backend expects int ID in path
    final url = Uri.parse('$baseUrl/replies/${int.tryParse(postId) ?? 0}');
    print("Fetching replies for post $postId from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns a List directly
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch replies response was not a valid list.");
      }
    } catch (e) {
      print("Error fetching replies for post $postId: $e");
      throw Exception("Failed to load replies: $e");
    }
  }

  // Line ~468
  Future<Map<String, dynamic>> deleteReply(String replyId, String token) async {
    // Backend expects int ID in path
    final url = '$baseUrl/replies/${int.tryParse(replyId) ?? 0}';
    print('Deleting reply ID: $replyId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 204) {
        return {"message": "Reply deleted successfully"};
      }
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Return error details
      } else {
        throw Exception("Delete reply failed with status ${response.statusCode}");
      }
    } catch(e) {
      print("Error deleting reply: $e");
      throw Exception("Failed to delete reply: $e");
    }
  }

  // --- Membership, Favorites, Community Posts ---
  // Line ~479
  Future<Map<String, dynamic>> joinCommunity(String communityId, String token) async {
    // Backend expects int ID in path
    final url = '$baseUrl/communities/${int.tryParse(communityId) ?? 0}/join';
    print('Joining community ID: $communityId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns message map
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Join operation successful (empty response)"};
      } else {
        throw Exception("Join community response was not a valid map.");
      }
    } catch(e) {
      print("Error joining community: $e");
      throw Exception("Failed to join community: $e");
    }
  }

  // Line ~489
  Future<Map<String, dynamic>> leaveCommunity(String communityId, String token) async {
    // Backend expects int ID in path
    final url = '$baseUrl/communities/${int.tryParse(communityId) ?? 0}/leave';
    print('Leaving community ID: $communityId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns message map
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Leave operation successful (empty response)"};
      } else {
        throw Exception("Leave community response was not a valid map.");
      }
    } catch(e) {
      print("Error leaving community: $e");
      throw Exception("Failed to leave community: $e");
    }
  }

  // Line ~499
  Future<Map<String, dynamic>> favoritePost(String postId, String token) async {
    // NOTE: Backend doesn't seem to have /favorite endpoints in routers/posts.py
    // Assuming it should exist:
    final url = '$baseUrl/posts/${int.tryParse(postId) ?? 0}/favorite'; // Assumed Path
    print('Favoriting post ID: $postId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Favorite post operation successful"};
      } else {
        throw Exception("Favorite post response was not a valid map.");
      }
    } catch(e) {
      print("Error favoriting post: $e");
      throw Exception("Failed to favorite post: $e");
    }
  }

  // Line ~509
  Future<Map<String, dynamic>> unfavoritePost(String postId, String token) async {
    // NOTE: Backend doesn't seem to have /unfavorite endpoints in routers/posts.py
    // Assuming it should exist:
    final url = '$baseUrl/posts/${int.tryParse(postId) ?? 0}/unfavorite'; // Assumed Path
    print('Unfavoriting post ID: $postId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Unfavorite post operation successful"};
      } else {
        throw Exception("Unfavorite post response was not a valid map.");
      }
    } catch(e) {
      print("Error unfavoriting post: $e");
      throw Exception("Failed to unfavorite post: $e");
    }
  }

  // Line ~519
  Future<Map<String, dynamic>> favoriteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/${int.tryParse(replyId) ?? 0}/favorite';
    print('Favoriting reply ID: $replyId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Favorite reply operation successful"};
      } else {
        throw Exception("Favorite reply response was not a valid map.");
      }
    } catch(e) {
      print("Error favoriting reply: $e");
      throw Exception("Failed to favorite reply: $e");
    }
  }

  // Line ~529
  Future<Map<String, dynamic>> unfavoriteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/${int.tryParse(replyId) ?? 0}/unfavorite';
    print('Unfavoriting reply ID: $replyId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Unfavorite reply operation successful"};
      } else {
        throw Exception("Unfavorite reply response was not a valid map.");
      }
    } catch(e) {
      print("Error unfavoriting reply: $e");
      throw Exception("Failed to unfavorite reply: $e");
    }
  }

  // Line ~540
  Future<Map<String, dynamic>> addPostToCommunity(
      String communityId, String postId, String token) async {
    final url = '$baseUrl/communities/${int.tryParse(communityId) ?? 0}/add_post/${int.tryParse(postId) ?? 0}';
    print('Adding post $postId to community $communityId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Add post to community successful"};
      } else {
        throw Exception("Add post to community response was not a valid map.");
      }
    } catch(e) {
      print("Error adding post to community: $e");
      throw Exception("Failed to add post to community: $e");
    }
  }

  // Line ~551
  Future<Map<String, dynamic>> removePostFromCommunity(
      String communityId, String postId, String token) async {
    final url = '$baseUrl/communities/${int.tryParse(communityId) ?? 0}/remove_post/${int.tryParse(postId) ?? 0}';
    print('Removing post $postId from community $communityId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Remove post from community successful"};
      } else {
        throw Exception("Remove post from community response was not a valid map.");
      }
    } catch(e) {
      print("Error removing post from community: $e");
      throw Exception("Failed to remove post from community: $e");
    }
  }

  // --- Chat (HTTP Methods) ---
  Future<List<dynamic>> fetchChatMessages({int? communityId, int? eventId, int? beforeId, int limit = 50, String? token}) async {
    final Map<String, String> queryParams = {'limit': limit.toString()};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (eventId != null) queryParams['event_id'] = eventId.toString();
    if (beforeId != null) queryParams['before_id'] = beforeId.toString();

    final url = Uri.parse('$baseUrl/chat/messages').replace(queryParameters: queryParams);
    print("Fetching chat messages from URL: $url");

    final Map<String, String> headers = {};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      final response = await http.get(url, headers: headers);
      final dynamic data = await _handleResponse(response);
      // Backend returns a List directly based on routers/chat.py
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch chat messages response was not a valid list.");
      }
    } catch (e) {
      print("Error fetching chat messages: $e");
      throw Exception("Failed to load chat messages: $e");
    }
  }

  // Line ~591
  Future<Map<String, dynamic>> sendChatMessageHttp(String content, int? communityId, int? eventId, String token) async {
    final url = Uri.parse('$baseUrl/chat/messages');
    final Map<String, String> queryParams = {};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (eventId != null) queryParams['event_id'] = eventId.toString();

    print('Sending HTTP chat message: comm=$communityId, event=$eventId, content=$content');

    try {
      final response = await http.post(
        url.replace(queryParameters: queryParams.isNotEmpty ? queryParams : null),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'content': content}),
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns the created ChatMessageData (Map)
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Send chat message response was not a valid map.");
      }
    } catch(e) {
      print("Error sending chat message: $e");
      throw Exception("Failed to send chat message: $e");
    }
  }

  // --- Events ---
  Future<EventModel> createEvent(
      int communityId, String title, String? description, String location,
      DateTime eventTimestamp, int maxParticipants, String token, {String? imageUrl}) async {
    final url = '$baseUrl/communities/$communityId/events';
    print('Creating event in community $communityId: $title');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'location': location,
          'event_timestamp': eventTimestamp.toUtc().toIso8601String(),
          'max_participants': maxParticipants,
          'image_url': imageUrl,
        }),
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        // Parse the Map into an EventModel before returning
        return EventModel.fromJson(data);
      } else {
        throw Exception("Create event response was not a valid map.");
      }
    } catch(e) {
      print("Error creating event: $e");
      throw Exception("Failed to create event: $e");
    }
  }

  Future<List<EventModel>> fetchCommunityEvents(int communityId, String? token) async {
    final url = '$baseUrl/communities/$communityId/events';
    print('Fetching events for community $communityId');
    final Map<String, String> headers = {};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      // This specific endpoint returns a list directly from the backend router
      final dynamic data = await _handleResponse(response);
      if (data is List) {
        // Parse each item in the list into an EventModel
        return data.map((eventJson) => EventModel.fromJson(eventJson as Map<String, dynamic>)).toList();
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return []; // Return empty list on success with no content
      } else {
        throw FormatException("Expected a list of events, but received: $data");
      }
    } catch (e) {
      print("Error fetching community events: $e");
      throw Exception("Failed to load community events: $e");
    }
  }

  Future<EventModel> fetchEventDetails(int eventId, String? token) async {
    final url = '$baseUrl/events/$eventId';
    print('Fetching details for event $eventId');
    final Map<String, String> headers = {};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data);
      } else {
        throw Exception("Fetch event details response was not a valid map.");
      }
    } catch(e) {
      print("Error fetching event details: $e");
      throw Exception("Failed to fetch event details: $e");
    }
  }

  Future<EventModel> updateEvent(int eventId, Map<String, dynamic> updateData, String token) async {
    if (updateData.containsKey('event_timestamp') && updateData['event_timestamp'] is DateTime) {
      updateData['event_timestamp'] = (updateData['event_timestamp'] as DateTime).toUtc().toIso8601String();
    }

    final url = '$baseUrl/events/$eventId';
    print('Updating event $eventId');
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(updateData),
      );
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data);
      } else {
        throw Exception("Update event response was not a valid map.");
      }
    } catch(e) {
      print("Error updating event: $e");
      throw Exception("Failed to update event: $e");
    }
  }

  // Line ~721
  Future<Map<String, dynamic>> deleteEvent(int eventId, String token) async {
    final url = '$baseUrl/events/$eventId';
    print('Deleting event $eventId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 204) {
        return {"message": "Event deleted successfully"};
      }
      final dynamic data = await _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Return error details
      } else {
        throw Exception("Delete event failed with status ${response.statusCode}");
      }
    } catch(e) {
      print("Error deleting event: $e");
      throw Exception("Failed to delete event: $e");
    }
  }

  Future<Map<String, dynamic>> joinEvent(String eventId, String token) async {
    // Assuming backend uses int ID in path
    final url = '$baseUrl/events/${int.tryParse(eventId) ?? 0}/join';
    print('Joining event $eventId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns message map
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Join event operation successful"};
      } else {
        throw Exception("Join event response was not a valid map.");
      }
    } catch(e) {
      print("Error joining event: $e");
      throw Exception("Failed to join event: $e");
    }
  }

  Future<Map<String, dynamic>> leaveEvent(String eventId, String token) async {
    // Assuming backend uses int ID in path
    final url = '$baseUrl/events/${int.tryParse(eventId) ?? 0}/leave';
    print('Leaving event $eventId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final dynamic data = await _handleResponse(response);
      // Backend returns message map
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
        return {"message": "Leave event operation successful"};
      } else {
        throw Exception("Leave event response was not a valid map.");
      }
    } catch(e) {
      print("Error leaving event: $e");
      throw Exception("Failed to leave event: $e");
    }
  }

  // --- Cleanup ---
  void dispose() {
    print("Disposing ApiService...");
    disconnectWebSocket();
    if (!_messageStreamController.isClosed) {
      _messageStreamController.close();
      print("Message Stream Controller closed.");
    }
    print("ApiService disposed.");
  }
}