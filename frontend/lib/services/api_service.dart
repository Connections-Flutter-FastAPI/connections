import 'dart:convert';
import 'dart:async'; // For StreamController
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart'; // Import WebSocket
import 'package:web_socket_channel/status.dart' as status; // For close codes
import '../app_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
// Removed unused MessageModel import if not directly used here
// import '../models/message_model.dart';
import '../models/chat_message_data.dart';
import '../models/event_model.dart'; // Import EventModel

class ApiService {
  // Use ws:// or wss:// for WebSocket URL
  final String baseUrl = AppConstants.baseUrl.replaceFirst('http', 'http'); // Keep HTTP for API
  final String wsBaseUrl = AppConstants.baseUrl.replaceFirst('http', 'ws');

  WebSocketChannel? _channel;
  // Ensure StreamController uses the correct ChatMessageData model
  StreamController<ChatMessageData> _messageStreamController = StreamController.broadcast();

  Stream<ChatMessageData> get messages => _messageStreamController.stream;

  // --- WebSocket Methods ---
  void connectWebSocket(String roomType, int roomId, String? token) {
    disconnectWebSocket(); // Ensure previous connection is closed
    // Reinitialize StreamController if it was closed
    if (_messageStreamController.isClosed) {
      _messageStreamController = StreamController.broadcast();
    }

    final url = '$wsBaseUrl/ws/$roomType/$roomId';
    print('Attempting to connect WebSocket: $url');

    // Construct headers for WebSocket connection if needed (some servers require it)
    // final Map<String, dynamic> headers = token != null ? {'Authorization': 'Bearer $token'} : {};
    // _channel = WebSocketChannel.connect(Uri.parse(url), protocols: ['websocket'], headers: headers); // Example with headers

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url)); // Connect without specific headers for now
      _channel!.stream.listen(
            (message) {
          print('WebSocket Received: $message');
          try {
            final decoded = jsonDecode(message);
            // Check if the decoded message structure matches ChatMessageData
            if (decoded is Map<String, dynamic> && decoded.containsKey('message_id')) {
              final chatMessage = ChatMessageData.fromJson(decoded);
              if (!_messageStreamController.isClosed) {
                _messageStreamController.add(chatMessage);
              }
            } else {
              // Handle other types of messages or log unexpected format
              print("Received non-chat message or unexpected format via WebSocket: $decoded");
              // Example: Handle potential server status messages or errors
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
            // Signal stream closure or handle reconnection logic here
            // _messageStreamController.close(); // Close if no reconnection planned
          }
          _channel = null; // Clear channel reference
        },
        onError: (error) {
          print('WebSocket error: $error');
          if (!_messageStreamController.isClosed) {
            _messageStreamController.addError('WebSocket Error: $error');
          }
          _channel = null; // Clear channel reference on error too
        },
        cancelOnError: true, // Automatically unsubscribes on error
      );
      print('WebSocket connection established.');
    } catch (e) {
      print('WebSocket connection failed: $e');
      if (!_messageStreamController.isClosed) {
        _messageStreamController.addError('WebSocket Connection Failed: $e');
      }
      _channel = null; // Ensure channel is null on connection failure
    }
  }

  void disconnectWebSocket() {
    if (_channel != null) {
      print('Closing WebSocket connection...');
      _channel!.sink.close(status.goingAway);
      _channel = null; // Set to null immediately after initiating close
    }
    // Close the stream controller only if the ApiService itself is being disposed
    // Do not close it here if you intend to reconnect later.
    // if (!_messageStreamController.isClosed) {
    //   _messageStreamController.close();
    // }
  }

  void sendWebSocketMessage(String message) {
    if (_channel != null && _channel?.closeCode == null) {
      print('WebSocket Sending: $message');
      _channel!.sink.add(message);
    } else {
      print('WebSocket not connected, cannot send message.');
      // Optionally notify the UI or try to reconnect
      // throw Exception("WebSocket not connected.");
    }
  }

  // --- Helper for HTTP ---
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}"); // Log the raw body

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        // Handle cases like 204 No Content or other successful empty responses
        if (response.statusCode == 204) return {"message": "Operation successful (No Content)"};
        return {}; // Return empty map for other empty bodies like 200 OK with no body
      }
      try {
        // Check if the response is expected to be a list (e.g., fetchPosts, fetchCommunities)
        // If the root is a list, wrap it in a map. This adapts to endpoints
        // that might return a direct list instead of a map like {"posts": [...]}.
        // NOTE: This assumes endpoints like /posts directly return {"posts": [...]}. If they
        // return just [...], the calling function needs to handle that.
        // Let's assume the backend consistently returns maps for now.
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          // If the API directly returns a list, we might need to decide how to represent it.
          // For now, let's throw an error or wrap it. Wrapping might hide issues.
          print("Warning: API endpoint returned a list directly. Expected a map.");
          // Option 1: Wrap it (use with caution)
          // return {"data": decoded};
          // Option 2: Throw error (safer)
          throw FormatException("Expected a JSON map, but received a list.", response.body);
        }
        return decoded as Map<String, dynamic>; // Ensure it's a map

      } catch (e) {
        print('JSON Decode Error: $e');
        throw Exception('Failed to parse JSON response. Body: ${response.body}');
      }
    } else {
      String detail = 'Unknown error';
      try {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          // Check if errorBody is a Map before accessing 'detail'
          if (errorBody is Map<String, dynamic>) {
            detail = errorBody['detail'] ?? response.body;
          } else {
            detail = response.body; // Use raw body if not a map
          }
        } else {
          detail = response.reasonPhrase ?? 'Status code ${response.statusCode}';
        }
      } catch (e) {
        // If decoding the error body fails, use the raw body
        detail = response.body.isNotEmpty ? response.body : 'Status code ${response.statusCode}';
      }
      print('API Error: ${response.statusCode} - $detail');
      throw Exception('Request failed: $detail'); // Throw with detail
    }
  }

  // --- Auth ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/login';
    print('Attempting login for: $email');
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
      String currentLocation, // Expects POINT string like '(lon,lat)'
      String college,
      List<String> interests,
      Uint8List? imageBytes,
      String? imageFileName) async {
    final url = Uri.parse('$baseUrl/signup');
    print('Attempting signup for: $username');
    var request = http.MultipartRequest('POST', url);

    // Add form fields
    request.fields['name'] = name;
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['gender'] = gender;
    // Backend expects location string like '(lon,lat)', frontend might need to construct this
    request.fields['current_location'] = currentLocation; // Ensure format is correct
    request.fields['college'] = college;

    // Backend expects interests as multiple form fields 'interests=value1&interests=value2'
    interests.forEach((interest) {
      request.fields['interests'] = interest; // Add each interest with the same key
    });

    // Add image file if provided
    if (imageBytes != null && imageFileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name expected by FastAPI backend
          imageBytes,
          filename: imageFileName, // Filename for the backend
          contentType: MediaType('image', _getFileExtension(imageFileName)), // Guess content type
        ),
      );
      print('Adding image to signup request: $imageFileName');
    } else {
      print('No image provided for signup.');
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print("Error during signup request: $e");
      throw Exception("Signup request failed: $e");
    }
  }

  // Helper to get file extension
  String _getFileExtension(String fileName) {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
      return validExtensions.contains(ext) ? ext : 'jpeg'; // Default if unknown
    } catch (e) {
      return 'jpeg'; // Default on error
    }
  }

  // Fetch current user details
  Future<Map<String, dynamic>> fetchUserDetails(String token) async {
    final url = Uri.parse('$baseUrl/me');
    print('Fetching user details...');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response); // Use the handler
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
      final data = await _handleResponse(response);
      // Backend returns {'posts': [...]}, so extract the list
      return (data['posts'] as List<dynamic>?) ?? [];
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
      final data = await _handleResponse(response);
      return (data['posts'] as List<dynamic>?) ?? [];
    } catch (e) {
      print("Error fetching trending posts: $e");
      throw Exception("Failed to load trending posts: $e");
    }
  }

  Future<Map<String, dynamic>> createPost(
      String title, String content, int? communityId, String token) async {
    final url = '$baseUrl/posts';
    print('Creating post: $title');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'title': title,
        'content': content,
        // Only include community_id if it's not null
        if (communityId != null) 'community_id': communityId,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deletePost(String postId, String token) async {
    final url = '$baseUrl/posts/$postId';
    print('Deleting post ID: $postId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    // Delete returns 204 No Content on success typically
    if (response.statusCode == 204) {
      return {"message": "Post deleted successfully"};
    }
    // Otherwise, handle potential errors (like 404 or 403)
    return _handleResponse(response);
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
      final data = await _handleResponse(response);
      return (data['communities'] as List<dynamic>?) ?? [];
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
      final data = await _handleResponse(response);
      return (data['communities'] as List<dynamic>?) ?? [];
    } catch (e) {
      print("Error fetching trending communities: $e");
      throw Exception("Failed to load trending communities: $e");
    }
  }

  Future<Map<String, dynamic>> fetchCommunityDetails(String communityId, String? token) async {
    // Convert communityId to int if backend expects integer path parameter
    final url = Uri.parse('$baseUrl/communities/$communityId/details');
    print("Fetching community details from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createCommunity(
      String name, String? description, String primaryLocation, String? interest, String token) async {
    final url = '$baseUrl/communities';
    print('Creating community: $name');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'name': name,
        'description': description, // Backend handles null
        'primary_location': primaryLocation, // Ensure format '(lon,lat)'
        'interest': interest, // Backend handles null
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteCommunity(String communityId, String token) async {
    final url = '$baseUrl/communities/$communityId';
    print('Deleting community ID: $communityId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 204) {
      return {"message": "Community deleted successfully"};
    }
    return _handleResponse(response);
  }

  // --- Voting (Unified Endpoint Call) ---
  Future<Map<String, dynamic>> vote(
      {int? postId, int? replyId, required bool voteType, required String token}) async {
    final url = '$baseUrl/votes';
    print('Voting: post=$postId, reply=$replyId, type=$voteType');
    final Map<String, dynamic> body = {'vote_type': voteType};
    if (postId != null) body['post_id'] = postId;
    if (replyId != null) body['reply_id'] = replyId;

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // --- Replies ---
  Future<Map<String, dynamic>> createReply(
      int postId, String content, int? parentReplyId, String token) async {
    final url = '$baseUrl/replies';
    print('Creating reply for post $postId');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'post_id': postId,
        'content': content,
        'parent_reply_id': parentReplyId, // Backend handles null
      }),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> fetchReplies(String postId, String? token) async {
    // Ensure postId is treated as a string for the URL path
    final url = Uri.parse('$baseUrl/replies/$postId');
    print("Fetching replies for post $postId from URL: $url");
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await http.get(url, headers: headers);
      final data = await _handleResponse(response);
      return (data['replies'] as List<dynamic>?) ?? [];
    } catch (e) {
      print("Error fetching replies for post $postId: $e");
      throw Exception("Failed to load replies: $e");
    }
  }

  Future<Map<String, dynamic>> deleteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/$replyId';
    print('Deleting reply ID: $replyId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 204) {
      return {"message": "Reply deleted successfully"};
    }
    return _handleResponse(response);
  }

  // --- Membership, Favorites, Community Posts ---
  Future<Map<String, dynamic>> joinCommunity(String communityId, String token) async {
    final url = '$baseUrl/communities/$communityId/join';
    print('Joining community ID: $communityId');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> leaveCommunity(String communityId, String token) async {
    final url = '$baseUrl/communities/$communityId/leave';
    print('Leaving community ID: $communityId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> favoritePost(String postId, String token) async {
    final url = '$baseUrl/posts/$postId/favorite';
    print('Favoriting post ID: $postId');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> unfavoritePost(String postId, String token) async {
    final url = '$baseUrl/posts/$postId/unfavorite';
    print('Unfavoriting post ID: $postId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> favoriteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/$replyId/favorite';
    print('Favoriting reply ID: $replyId');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> unfavoriteReply(String replyId, String token) async {
    final url = '$baseUrl/replies/$replyId/unfavorite';
    print('Unfavoriting reply ID: $replyId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addPostToCommunity(
      String communityId, String postId, String token) async {
    final url = '$baseUrl/communities/$communityId/add_post/$postId';
    print('Adding post $postId to community $communityId');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> removePostFromCommunity(
      String communityId, String postId, String token) async {
    final url = '$baseUrl/communities/$communityId/remove_post/$postId';
    print('Removing post $postId from community $communityId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // --- Chat (HTTP Methods) ---
  Future<List<dynamic>> fetchChatMessages({int? communityId, int? eventId, int? beforeId, int limit = 50, String? token}) async {
    final Map<String, String> queryParams = {'limit': limit.toString()};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (eventId != null) queryParams['event_id'] = eventId.toString(); // Use event_id
    if (beforeId != null) queryParams['before_id'] = beforeId.toString();

    final url = Uri.parse('$baseUrl/chat/messages').replace(queryParameters: queryParams);
    print("Fetching chat messages from URL: $url");

    final Map<String, String> headers = {};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      final response = await http.get(url, headers: headers);
      final data = await _handleResponse(response);
      // Backend returns {"messages": [...]}, extract the list
      return (data['messages'] as List<dynamic>?) ?? [];
    } catch (e) {
      print("Error fetching chat messages: $e");
      throw Exception("Failed to load chat messages: $e");
    }
  }

  Future<Map<String, dynamic>> sendChatMessageHttp(String content, int? communityId, int? eventId, String token) async {
    final url = Uri.parse('$baseUrl/chat/messages');
    final Map<String, String> queryParams = {};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (eventId != null) queryParams['event_id'] = eventId.toString(); // Use event_id

    print('Sending HTTP chat message: comm=$communityId, event=$eventId, content=$content');

    final response = await http.post(
      url.replace(queryParameters: queryParams.isNotEmpty ? queryParams : null),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'content': content}),
    );
    return _handleResponse(response); // Returns the created ChatMessageData
  }

  // --- Events ---
  Future<EventModel> createEvent(
      int communityId, String title, String? description, String location,
      DateTime eventTimestamp, int maxParticipants, String token, {String? imageUrl}) async { // Added optional imageUrl
    final url = '$baseUrl/communities/$communityId/events';
    print('Creating event in community $communityId: $title');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'location': location,
        'event_timestamp': eventTimestamp.toUtc().toIso8601String(), // Send as UTC ISO string
        'max_participants': maxParticipants,
        'image_url': imageUrl, // Include image URL if provided
      }),
    );
    final data = await _handleResponse(response);
    // Backend returns the created event details including participant_count=1
    return EventModel.fromJson(data);
  }

  Future<List<EventModel>> fetchCommunityEvents(int communityId, String? token) async {
    final url = '$baseUrl/communities/$communityId/events';
    print('Fetching events for community $communityId');
    final Map<String, String> headers = {};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      // The backend returns a list directly for this endpoint
      final rawData = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (rawData is List) {
          return rawData.map((eventJson) => EventModel.fromJson(eventJson as Map<String, dynamic>)).toList();
        } else {
          throw FormatException("Expected a list of events, but received: $rawData");
        }
      } else {
        // Use _handleResponse logic for errors, adapting for list expectation
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
        throw Exception('Request failed: $detail');
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

    final response = await http.get(Uri.parse(url), headers: headers);
    final data = await _handleResponse(response);
    return EventModel.fromJson(data);
  }

  Future<EventModel> updateEvent(int eventId, Map<String, dynamic> updateData, String token) async {
    // Filter out null values from updateData if backend doesn't handle them
    // updateData.removeWhere((key, value) => value == null);

    // Convert DateTime to ISO string if present
    if (updateData.containsKey('event_timestamp') && updateData['event_timestamp'] is DateTime) {
      updateData['event_timestamp'] = (updateData['event_timestamp'] as DateTime).toUtc().toIso8601String();
    }

    final url = '$baseUrl/events/$eventId';
    print('Updating event $eventId');
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(updateData),
    );
    final data = await _handleResponse(response);
    return EventModel.fromJson(data);
  }

  Future<Map<String, dynamic>> deleteEvent(int eventId, String token) async {
    final url = '$baseUrl/events/$eventId';
    print('Deleting event $eventId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 204) {
      return {"message": "Event deleted successfully"};
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> joinEvent(String eventId, String token) async {
    // Assuming backend uses int ID in path
    final url = '$baseUrl/events/${int.parse(eventId)}/join';
    print('Joining event $eventId');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> leaveEvent(String eventId, String token) async {
    // Assuming backend uses int ID in path
    final url = '$baseUrl/events/${int.parse(eventId)}/leave';
    print('Leaving event $eventId');
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  // --- Cleanup ---
  void dispose() {
    print("Disposing ApiService...");
    disconnectWebSocket();
    if (!_messageStreamController.isClosed) { // Check before closing
      _messageStreamController.close();
      print("Message Stream Controller closed.");
    }
    print("ApiService disposed.");
  }
}