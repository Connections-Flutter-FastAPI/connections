// lib/services/post_service.dart
import 'api_base.dart';

class PostService {
  final ApiBase _apiBase;

  PostService(this._apiBase);

  Future<List<dynamic>> fetchPosts(String? token, {int? communityId, int? userId}) async {
    const path = '/posts';
    final Map<String, String> queryParams = {};
    if (communityId != null) queryParams['community_id'] = communityId.toString();
    if (userId != null) queryParams['user_id'] = userId.toString();

    print("PostService: Fetching posts (communityId: $communityId, userId: $userId)");
    try {
      final response = await _apiBase.makeRequest(path, token: token, queryParams: queryParams);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is List) {
        return data; // Backend returns list directly
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return []; // Empty success
      } else {
        throw Exception("Fetch posts response was not a valid list.");
      }
    } catch (e) {
      print("PostService fetchPosts error: $e");
      throw Exception("Failed to load posts: $e");
    }
  }

  Future<List<dynamic>> fetchTrendingPosts(String? token) async {
    const path = '/posts/trending';
    print("PostService: Fetching trending posts");
    try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is List) {
        return data; // Backend returns list directly
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return [];
      } else {
        throw Exception("Fetch trending posts response was not a valid list.");
      }
    } catch (e) {
      print("PostService fetchTrendingPosts error: $e");
      throw Exception("Failed to load trending posts: $e");
    }
  }

  Future<Map<String, dynamic>> createPost(
      String title, String content, int? communityId, String token) async {
    const path = '/posts';
    print('PostService: Creating post: $title');
    try {
      final response = await _apiBase.makeRequest(
        path,
        method: 'POST',
        token: token,
        body: {
          'title': title,
          'content': content,
          if (communityId != null) 'community_id': communityId,
        },
      );
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Returns PostDisplay schema
      } else {
        throw Exception("Create post response was not a valid map.");
      }
    } catch (e) {
      print("PostService createPost error: $e");
      throw Exception("Failed to create post: $e");
    }
  }

  Future<Map<String, dynamic>> deletePost(String postId, String token) async {
    final path = '/posts/${int.tryParse(postId) ?? 0}'; // Ensure ID is int for path
    print('PostService: Deleting post ID: $postId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      if (response.statusCode == 204) {
        return {"message": "Post deleted successfully"}; // Handle No Content
      }
      final dynamic data = await _apiBase.handleResponse(response); // Handle potential error body
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Delete post failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("PostService deletePost error: $e");
      throw Exception("Failed to delete post: $e");
    }
  }

   // Methods for favoriting/unfavoriting posts (assuming backend endpoints exist)
  Future<Map<String, dynamic>> favoritePost(String postId, String token) async {
    final path = '/posts/${int.tryParse(postId) ?? 0}/favorite'; // Assumed Path
    print('PostService: Favoriting post ID: $postId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'POST', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
         return {"message": "Favorite post operation successful"};
      } else {
         throw Exception("Favorite post response was not a valid map.");
      }
    } catch(e) {
       print("PostService favoritePost error: $e");
       throw Exception("Failed to favorite post: $e");
    }
  }

  Future<Map<String, dynamic>> unfavoritePost(String postId, String token) async {
    final path = '/posts/${int.tryParse(postId) ?? 0}/unfavorite'; // Assumed Path
    print('PostService: Unfavoriting post ID: $postId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
         return {"message": "Unfavorite post operation successful"};
      } else {
         throw Exception("Unfavorite post response was not a valid map.");
      }
    } catch(e) {
       print("PostService unfavoritePost error: $e");
       throw Exception("Failed to unfavorite post: $e");
    }
  }
}
