// lib/services/chat_service.dart
import 'api_base.dart';

class ChatService {
  final ApiBase _apiBase;

  ChatService(this._apiBase);

  Future<List<dynamic>> fetchChatMessages({
      int? communityId, int? eventId, int? beforeId, int limit = 50, String? token
  }) async {
    const path = '/chat/messages';
    final Map<String, String> queryParams = {'limit': limit.toString()};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (eventId != null) queryParams['event_id'] = eventId.toString();
    if (beforeId != null) queryParams['before_id'] = beforeId.toString();

    print("ChatService: Fetching chat messages (comm: $communityId, event: $eventId)");
    try {
      final response = await _apiBase.makeRequest(path, token: token, queryParams: queryParams);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is List) {
        return data; // Returns list of ChatMessageData
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch chat messages response was not a valid list.");
      }
    } catch (e) {
      print("ChatService fetchChatMessages error: $e");
      throw Exception("Failed to load chat messages: $e");
    }
  }

  Future<Map<String, dynamic>> sendChatMessageHttp(
      String content, int? communityId, int? eventId, String token
  ) async {
    const path = '/chat/messages';
    final Map<String, String> queryParams = {};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (eventId != null) queryParams['event_id'] = eventId.toString();

    print('ChatService: Sending HTTP chat message (comm: $communityId, event: $eventId)');
    try {
      final response = await _apiBase.makeRequest(
        path,
        method: 'POST',
        token: token,
        queryParams: queryParams, // Send IDs as query params
        body: {'content': content}, // Send content in body
      );
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Returns the created ChatMessageData map
      } else {
        throw Exception("Send chat message response was not a valid map.");
      }
    } catch (e) {
      print("ChatService sendChatMessageHttp error: $e");
      throw Exception("Failed to send chat message: $e");
    }
  }
}
