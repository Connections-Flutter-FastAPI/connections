// lib/services/reply_service.dart
import 'api_base.dart';

class ReplyService {
  final ApiBase _apiBase;

  ReplyService(this._apiBase);

  Future<Map<String, dynamic>> createReply(
      int postId, String content, int? parentReplyId, String token) async {
    const path = '/replies';
    print('ReplyService: Creating reply for post $postId');
    try {
      final response = await _apiBase.makeRequest(
        path,
        method: 'POST',
        token: token,
        body: {
          'post_id': postId,
          'content': content,
          'parent_reply_id': parentReplyId, // null is handled by jsonEncode
        },
      );
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Returns ReplyDisplay schema
      } else {
        throw Exception("Create reply response was not a valid map.");
      }
    } catch (e) {
      print("ReplyService createReply error: $e");
      throw Exception("Failed to create reply: $e");
    }
  }

  Future<List<dynamic>> fetchReplies(String postId, String? token) async {
    final path = '/replies/${int.tryParse(postId) ?? 0}';
    print("ReplyService: Fetching replies for post $postId");
    try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is List) {
        return data; // Returns list of ReplyDisplay
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch replies response was not a valid list.");
      }
    } catch (e) {
      print("ReplyService fetchReplies error: $e");
      throw Exception("Failed to load replies for post $postId: $e");
    }
  }

  Future<Map<String, dynamic>> deleteReply(String replyId, String token) async {
    final path = '/replies/${int.tryParse(replyId) ?? 0}';
    print('ReplyService: Deleting reply ID: $replyId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      if (response.statusCode == 204) {
        return {"message": "Reply deleted successfully"};
      }
      final dynamic data = await _apiBase.handleResponse(response); // Handle error body
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Delete reply failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("ReplyService deleteReply error: $e");
      throw Exception("Failed to delete reply: $e");
    }
  }

  Future<Map<String, dynamic>> favoriteReply(String replyId, String token) async {
    final path = '/replies/${int.tryParse(replyId) ?? 0}/favorite';
    print('ReplyService: Favoriting reply ID: $replyId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'POST', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
         return {"message": "Favorite reply operation successful"};
      } else {
         throw Exception("Favorite reply response was not valid.");
      }
    } catch(e) {
       print("ReplyService favoriteReply error: $e");
       throw Exception("Failed to favorite reply: $e");
    }
  }

  Future<Map<String, dynamic>> unfavoriteReply(String replyId, String token) async {
    final path = '/replies/${int.tryParse(replyId) ?? 0}/unfavorite';
    print('ReplyService: Unfavoriting reply ID: $replyId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
       if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
         return {"message": "Unfavorite reply operation successful"};
      } else {
         throw Exception("Unfavorite reply response was not valid.");
      }
    } catch(e) {
       print("ReplyService unfavoriteReply error: $e");
       throw Exception("Failed to unfavorite reply: $e");
    }
  }
}
