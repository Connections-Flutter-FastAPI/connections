// services/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;

  String? get token => _token;
  String? get userId => _userId;
  bool get isAuthenticated => _token != null;

  Future<void> setAuthToken(String? token) async {
    _token = token;
    notifyListeners();
  }

  Future<void> setUserId(String? userId) async {
    _userId = userId;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    notifyListeners();
  }
}
