// lib/services/vote_service.dart
import 'api_base.dart';

class VoteService {
  final ApiBase _apiBase;

  VoteService(this._apiBase);

  Future<Map<String, dynamic>> vote(
      {int? postId, int? replyId, required bool voteType, required String token}) async {
    const path = '/votes';
    print('VoteService: Voting: post=$postId, reply=$replyId, type=$voteType');
    final Map<String, dynamic> body = {'vote_type': voteType};
    if (postId != null) body['post_id'] = postId;
    if (replyId != null) body['reply_id'] = replyId;

    try {
      final response = await _apiBase.makeRequest(path, method: 'POST', token: token, body: body);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ..., ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        // Should ideally return a map based on backend, but handle null just in case
         return {"message": "Vote operation successful (empty response)"};
      } else {
        throw Exception("Vote response was not a valid map.");
      }
    } catch (e) {
      print("VoteService vote error: $e");
      throw Exception("Vote failed: $e");
    }
  }

  // Optional: Add fetchVotes if needed, though often votes are embedded in post/reply fetches
  // Future<List<dynamic>> fetchVotes({int? postId, int? replyId, String? token}) async { ... }
}
