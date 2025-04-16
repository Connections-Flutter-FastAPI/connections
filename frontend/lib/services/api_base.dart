// lib/services/api_base.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_constants.dart';

class ApiBase {
  final String baseUrl = AppConstants.baseUrl;

  // Handles response decoding and error checking
  Future<dynamic> handleResponse(http.Response response) async {
    // Always log status for debugging
    print("Response Status: ${response.statusCode}");
    // Conditionally log body based on need or environment
    // print("Response Body: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null; // Represent empty success (e.g., 204 No Content)
      }
      try {
        return jsonDecode(response.body); // Decode and return dynamic data
      } catch (e) {
        print('JSON Decode Error in handleResponse: $e');
        throw Exception('Failed to parse JSON response. Body: ${response.body}');
      }
    } else {
      // Handle HTTP errors
      String detail = 'Unknown error';
      try {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            detail = errorBody['detail'] ?? response.body;
          } else {
            detail = response.body; // Use raw body if not a map
          }
        } else {
          detail = response.reasonPhrase ?? 'Status code ${response.statusCode}';
        }
      } catch (e) {
        // If decoding error body fails, use raw body
        detail = response.body.isNotEmpty ? response.body : 'Status code ${response.statusCode}';
      }
      print('API Error: ${response.statusCode} - $detail');
      throw Exception('Request failed: $detail'); // Throw clear error
    }
  }

  // General method for making HTTP requests
  Future<http.Response> makeRequest(
      String path, {
        String method = 'GET',
        Map<String, String>? queryParams,
        Map<String, String>? headers,
        dynamic body,
        String? token,
      }) async {

    Uri url;
    if (queryParams != null && queryParams.isNotEmpty) {
       url = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    } else {
       url = Uri.parse('$baseUrl$path');
    }

    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json; charset=UTF-8', // Standard JSON content type
      ...?headers // Allow overriding or adding headers
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    print('$method Request to: $url');
    // If body is provided, log it (careful with sensitive data in production logs)
    // if (body != null) { print('Request Body: ${jsonEncode(body)}'); }

    try {
       switch (method.toUpperCase()) {
        case 'POST':
          return await http.post(url, headers: requestHeaders, body: body != null ? jsonEncode(body) : null);
        case 'PUT':
          return await http.put(url, headers: requestHeaders, body: body != null ? jsonEncode(body) : null);
        case 'DELETE':
          // Delete requests might or might not have a body depending on API design
          return await http.delete(url, headers: requestHeaders, body: body != null ? jsonEncode(body) : null);
        case 'GET':
        default:
          return await http.get(url, headers: requestHeaders);
       }
    } catch (e) {
       print('HTTP Request Error ($method $url): $e');
       // Re-throw a more specific exception or handle network errors
       throw Exception('Network request failed: $e');
    }
  }

  // You might add specific helpers here later if needed, e.g., for multipart requests
  // Future<http.Response> makeMultipartRequest(...) { ... }
}
