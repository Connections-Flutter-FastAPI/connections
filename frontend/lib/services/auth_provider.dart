import 'package:flutter/foundation.dart'; // For ChangeNotifier and Uint8List
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'dart:typed_data'; // <--- IMPORT THIS

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  String? _token;
  String? _userId;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  AuthProvider(this._apiService);

  // --- Getters ---
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // --- Core Methods ---

  // Internal helper to manage state and storage
  Future<void> _updateAuthState(String? token, String? userId) async {
    final wasAuthenticated = _isAuthenticated; // Track previous state
    _token = token;
    _userId = userId;
    _isAuthenticated = token != null && userId != null;

    if (_isAuthenticated) {
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'userId', value: _userId);
      print("AuthProvider: State updated and stored (Token: ${_token?.substring(0, 10)}..., UserID: $_userId)");
    } else {
      // Only delete if state actually changed to logged out
      if (wasAuthenticated) {
        await _storage.deleteAll();
        print("AuthProvider: State cleared and storage wiped.");
      } else {
        print("AuthProvider: State remains logged out.");
      }
    }

    // Only notify if the authentication status actually changed
    if (wasAuthenticated != _isAuthenticated) {
      notifyListeners();
    }
  }

  // --- Methods Called by UI ---

  Future<void> login(String email, String password) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      print("AuthProvider: Attempting login for $email");
      // ApiService.login now returns the Map directly
      final response = await _apiService.login(email, password);

      final String? responseToken = response['token'] as String?;
      // Backend login returns 'user_id' as int, handle safely
      final dynamic responseUserIdDynamic = response['user_id'];
      final String? responseUserId = responseUserIdDynamic?.toString();

      if (responseToken != null && responseUserId != null) {
        print("AuthProvider: Login successful.");
        await _updateAuthState(responseToken, responseUserId);
      } else {
        print("AuthProvider: Login API success but token/userId missing in response.");
        throw Exception('Login failed: Invalid response from server.');
      }
    } catch (e) {
      print("AuthProvider: Login error - $e");
      await _updateAuthState(null, null); // Clear state on error
      rethrow;
    } finally {
      _isLoading = false;
      // Notify even if loading just finished without auth state change
      notifyListeners();
    }
  }

  Future<void> signup(
      String name, String username, String email, String password, String gender,
      String currentLocation, String college, List<String> interests,
      Uint8List? imageBytes, String? imageFileName) async {

    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      print("AuthProvider: Attempting signup for $username");
      final response = await _apiService.signup(
          name, username, email, password, gender, currentLocation, college, interests, imageBytes, imageFileName);

      final String? responseToken = response['token'] as String?;
      // Backend signup returns 'user_id' as int, handle safely
      final dynamic responseUserIdDynamic = response['user_id'];
      final String? responseUserId = responseUserIdDynamic?.toString();


      if (responseToken != null && responseUserId != null) {
        print("AuthProvider: Signup successful.");
        await _updateAuthState(responseToken, responseUserId);
      } else {
        print("AuthProvider: Signup API success but token/userId missing in response.");
        throw Exception('Signup failed: Invalid response from server.');
      }
    } catch (e) {
      print("AuthProvider: Signup error - $e");
      await _updateAuthState(null, null); // Clear state on error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    print("AuthProvider: Logging out.");
    await _updateAuthState(null, null);
    // NOTE: Consider clearing other app state here if needed
  }

  Future<void> tryAutoLogin() async {
    if (_isInitialized) {
      print("AuthProvider: Auto-login already attempted.");
      return;
    }

    print("AuthProvider: Attempting auto-login...");
    final storedToken = await _storage.read(key: 'token');
    final storedUserId = await _storage.read(key: 'userId');

    // Update state based *only* on stored values
    // No need to call _updateAuthState here as we aren't changing storage
    _token = storedToken;
    _userId = storedUserId;
    _isAuthenticated = storedToken != null && storedUserId != null;

    if (_isAuthenticated) {
      print("AuthProvider: Found stored token/userId. Restored authenticated state.");
      // Optional: Validate token here if needed
    } else {
      print("AuthProvider: No stored token/userId found.");
    }

    _isInitialized = true;
    notifyListeners(); // Notify about the initial state once determined
    print("AuthProvider: Auto-login finished. isAuthenticated: $_isAuthenticated");
  }

// --- Keep original methods if needed by UI (discouraged) ---
// It's better to refactor the UI to rely on the login/signup methods
// which handle the API call AND state update together.
// However, if absolutely necessary for a quick fix:
/*
  @Deprecated('Prefer updating state via login/signup/logout methods.')
  Future<void> setAuthToken(String? token) async {
    // This bypasses secure storage writing unless combined with _updateAuthState
    print("AuthProvider [Deprecated]: Setting token directly.");
    _token = token;
    _isAuthenticated = _token != null && _userId != null;
    notifyListeners();
    // Consider calling _updateAuthState if you want storage updated too
    // await _updateAuthState(_token, _userId);
  }

  @Deprecated('Prefer updating state via login/signup/logout methods.')
  Future<void> setUserId(String? userId) async {
    // This bypasses secure storage writing unless combined with _updateAuthState
     print("AuthProvider [Deprecated]: Setting userId directly.");
    _userId = userId;
     _isAuthenticated = _token != null && _userId != null;
    notifyListeners();
    // Consider calling _updateAuthState if you want storage updated too
    // await _updateAuthState(_token, _userId);
  }
  */
}