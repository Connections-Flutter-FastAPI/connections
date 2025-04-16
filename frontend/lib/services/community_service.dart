// lib/services/community_service.dart
import 'api_base.dart'; // Import the base

class CommunityService {
  final ApiBase _apiBase;

  CommunityService(this._apiBase); // Inject ApiBase

  Future<List<dynamic>> fetchCommunities(String? token) async {
    const path = '/communities';
    print("CommunityService: Fetching communities");
    try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is List) {
        return data;
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return []; // Empty success
      } else {
        throw Exception("Fetch communities response was not a valid list.");
      }
    } catch (e) {
      print("CommunityService fetchCommunities error: $e");
      throw Exception("Failed to load communities: $e");
    }
  }

  Future<List<dynamic>> fetchTrendingCommunities(String? token) async {
     const path = '/communities/trending';
     print("CommunityService: Fetching trending communities");
     try {
       final response = await _apiBase.makeRequest(path, token: token);
       final dynamic data = await _apiBase.handleResponse(response);
       if (data is List) {
         return data;
       } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
         return [];
       } else {
         throw Exception("Fetch trending communities response was not a valid list.");
       }
     } catch (e) {
       print("CommunityService fetchTrendingCommunities error: $e");
       throw Exception("Failed to load trending communities: $e");
     }
  }

   Future<Map<String, dynamic>> fetchCommunityDetails(String communityId, String? token) async {
    final path = '/communities/${int.tryParse(communityId) ?? 0}/details';
    print("CommunityService: Fetching details for $communityId");
     try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Fetch community details response was not a valid map.");
      }
    } catch (e) {
      print("CommunityService fetchCommunityDetails error: $e");
      throw Exception("Failed to fetch community details for $communityId: $e");
    }
  }

  Future<Map<String, dynamic>> createCommunity(
      String name, String? description, String primaryLocation, String? interest, String token) async {
     const path = '/communities';
     print('CommunityService: Creating community: $name');
     try {
       final response = await _apiBase.makeRequest(
         path,
         method: 'POST',
         token: token,
         body: {
           'name': name,
           'description': description,
           'primary_location': primaryLocation, // Ensure format '(lon,lat)'
           'interest': interest,
         },
       );
       final dynamic data = await _apiBase.handleResponse(response);
       if (data is Map<String, dynamic>) {
         return data; // Returns CommunityDisplay schema
       } else {
         throw Exception("Create community response was not a valid map.");
       }
     } catch(e) {
        print("CommunityService createCommunity error: $e");
        throw Exception("Failed to create community: $e");
     }
  }

  Future<Map<String, dynamic>> deleteCommunity(String communityId, String token) async {
    final path = '/communities/${int.tryParse(communityId) ?? 0}';
    print('CommunityService: Deleting community ID: $communityId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      if (response.statusCode == 204) {
        return {"message": "Community deleted successfully"};
      }
      final dynamic data = await _apiBase.handleResponse(response); // Handle error body
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Delete community failed with status ${response.statusCode}");
      }
    } catch(e) {
       print("CommunityService deleteCommunity error: $e");
       throw Exception("Failed to delete community: $e");
    }
  }

  Future<Map<String, dynamic>> joinCommunity(String communityId, String token) async {
     final path = '/communities/${int.tryParse(communityId) ?? 0}/join';
     print('CommunityService: Joining community ID: $communityId');
     try {
       final response = await _apiBase.makeRequest(path, method: 'POST', token: token);
       final dynamic data = await _apiBase.handleResponse(response);
       if (data is Map<String, dynamic>) {
         return data; // Expects {"message": ...}
       } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
          return {"message": "Join operation successful"}; // Assume success on null/2xx
       } else {
          throw Exception("Join community response was not a valid map or null on success.");
       }
     } catch(e) {
        print("CommunityService joinCommunity error: $e");
        throw Exception("Failed to join community: $e");
     }
  }

   Future<Map<String, dynamic>> leaveCommunity(String communityId, String token) async {
     final path = '/communities/${int.tryParse(communityId) ?? 0}/leave';
     print('CommunityService: Leaving community ID: $communityId');
     try {
       final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
       final dynamic data = await _apiBase.handleResponse(response);
       if (data is Map<String, dynamic>) {
         return data; // Expects {"message": ...}
       } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
          return {"message": "Leave operation successful"};
       } else {
          throw Exception("Leave community response was not a valid map or null on success.");
       }
     } catch(e) {
        print("CommunityService leaveCommunity error: $e");
        throw Exception("Failed to leave community: $e");
     }
   }

  Future<Map<String, dynamic>> addPostToCommunity(String communityId, String postId, String token) async {
    final path = '/communities/${int.tryParse(communityId) ?? 0}/add_post/${int.tryParse(postId) ?? 0}';
    print('CommunityService: Adding post $postId to community $communityId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'POST', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
         return {"message": "Add post to community successful"};
      } else {
         throw Exception("Add post to community response was not valid.");
      }
    } catch(e) {
       print("CommunityService addPostToCommunity error: $e");
       throw Exception("Failed to add post to community: $e");
    }
  }

  Future<Map<String, dynamic>> removePostFromCommunity(String communityId, String postId, String token) async {
    final path = '/communities/${int.tryParse(communityId) ?? 0}/remove_post/${int.tryParse(postId) ?? 0}';
    print('CommunityService: Removing post $postId from community $communityId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300){
         return {"message": "Remove post from community successful"};
      } else {
         throw Exception("Remove post from community response was not valid.");
      }
    } catch(e) {
       print("CommunityService removePostFromCommunity error: $e");
       throw Exception("Failed to remove post from community: $e");
    }
  }
}
