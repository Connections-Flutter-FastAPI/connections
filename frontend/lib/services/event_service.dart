// lib/services/event_service.dart
import 'api_base.dart';
import '../models/event_model.dart'; // Need to parse into EventModel

class EventService {
  final ApiBase _apiBase;

  EventService(this._apiBase);

  // Note: createEvent is nested under communities in backend router
  Future<EventModel> createEvent(
      int communityId, String title, String? description, String location,
      DateTime eventTimestamp, int maxParticipants, String token, {String? imageUrl}) async {
    final path = '/communities/$communityId/events';
    print('EventService: Creating event in community $communityId: $title');
    try {
      final response = await _apiBase.makeRequest(
        path,
        method: 'POST',
        token: token,
        body: {
          'title': title,
          'description': description,
          'location': location,
          'event_timestamp': eventTimestamp.toUtc().toIso8601String(),
          'max_participants': maxParticipants,
          'image_url': imageUrl,
        },
      );
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data); // Parse response into model
      } else {
        throw Exception("Create event response was not a valid map.");
      }
    } catch (e) {
      print("EventService createEvent error: $e");
      throw Exception("Failed to create event: $e");
    }
  }

  // Note: fetchCommunityEvents is nested under communities in backend router
  Future<List<EventModel>> fetchCommunityEvents(int communityId, String? token) async {
    final path = '/communities/$communityId/events';
    print('EventService: Fetching events for community $communityId');
    try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is List) {
        // Parse list items into EventModel
        return data.map((eventJson) => EventModel.fromJson(eventJson as Map<String, dynamic>)).toList();
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return []; // Empty success
      } else {
        throw FormatException("Expected a list of events, but received: $data");
      }
    } catch (e) {
      print("EventService fetchCommunityEvents error: $e");
      throw Exception("Failed to load community events: $e");
    }
  }

  // Routes directly under /events
  Future<EventModel> fetchEventDetails(int eventId, String? token) async {
    final path = '/events/$eventId';
    print('EventService: Fetching details for event $eventId');
    try {
      final response = await _apiBase.makeRequest(path, token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data);
      } else {
        throw Exception("Fetch event details response was not a valid map.");
      }
    } catch (e) {
      print("EventService fetchEventDetails error: $e");
      throw Exception("Failed to fetch event details: $e");
    }
  }

  Future<EventModel> updateEvent(int eventId, Map<String, dynamic> updateData, String token) async {
    // Convert DateTime to ISO string if present
    if (updateData.containsKey('event_timestamp') && updateData['event_timestamp'] is DateTime) {
      updateData['event_timestamp'] = (updateData['event_timestamp'] as DateTime).toUtc().toIso8601String();
    }

    final path = '/events/$eventId';
    print('EventService: Updating event $eventId');
    try {
      // Filter out null values before sending if needed
      // updateData.removeWhere((key, value) => value == null);
      final response = await _apiBase.makeRequest(
        path,
        method: 'PUT',
        token: token,
        body: updateData,
      );
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data);
      } else {
        throw Exception("Update event response was not a valid map.");
      }
    } catch (e) {
      print("EventService updateEvent error: $e");
      throw Exception("Failed to update event: $e");
    }
  }

  Future<Map<String, dynamic>> deleteEvent(int eventId, String token) async {
    final path = '/events/$eventId';
    print('EventService: Deleting event $eventId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      if (response.statusCode == 204) {
        return {"message": "Event deleted successfully"};
      }
      final dynamic data = await _apiBase.handleResponse(response); // Handle error body
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Delete event failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("EventService deleteEvent error: $e");
      throw Exception("Failed to delete event: $e");
    }
  }

  Future<Map<String, dynamic>> joinEvent(String eventId, String token) async {
    final path = '/events/${int.tryParse(eventId) ?? 0}/join';
    print('EventService: Joining event $eventId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'POST', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return {"message": "Join event operation successful"};
      } else {
        throw Exception("Join event response was not valid.");
      }
    } catch (e) {
      print("EventService joinEvent error: $e");
      throw Exception("Failed to join event: $e");
    }
  }

  Future<Map<String, dynamic>> leaveEvent(String eventId, String token) async {
    final path = '/events/${int.tryParse(eventId) ?? 0}/leave';
    print('EventService: Leaving event $eventId');
    try {
      final response = await _apiBase.makeRequest(path, method: 'DELETE', token: token);
      final dynamic data = await _apiBase.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data; // Expects {"message": ...}
      } else if (data == null && response.statusCode >= 200 && response.statusCode < 300) {
        return {"message": "Leave event operation successful"};
      } else {
        throw Exception("Leave event response was not valid.");
      }
    } catch (e) {
      print("EventService leaveEvent error: $e");
      throw Exception("Failed to leave event: $e");
    }
  }
}
