// lib/screens/me_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
// import '../config.dart'; // Import config (for baseUrl, if you use Approach 1)
import 'login_screen.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class MeScreen extends StatefulWidget {
  @override
  _MeScreenState createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  String? _localImagePath; // Variable to store the constructed local path

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("You are not logged in."),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text("Go to Login"),
                ),
              ],
            ),
          );
        }

        final apiService = Provider.of<ApiService>(context, listen: false);
        return FutureBuilder<Map<String, dynamic>>(
          future: apiService.fetchUserDetails(authProvider.token!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final user = snapshot.data!;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display image using FutureBuilder and _getLocalImagePath
                    if (user['image_path'] != null)
                      FutureBuilder<String>(
                        future: _getLocalImagePath(user['image_path']),
                        builder: (context, pathSnapshot) {
                          if (pathSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          }
                          if (pathSnapshot.hasError) {
                            return Text('Error loading image path: ${pathSnapshot.error}');
                          }

                          final localImagePath = pathSnapshot.data;

                          if (localImagePath != null) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(File(localImagePath)),
                            );
                          } else {
                            return const CircleAvatar( // No image available or path error
                              radius: 50,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.image_not_supported, size: 40, color: Colors.white),
                            );
                          }
                        },
                      )
                    else
                      const CircleAvatar( // No image path provided by API
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 40, color: Colors.black54),
                      ),

                    const SizedBox(height: 8),
                    Text("Name: ${user['name']}", style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),
                    Text("Username: ${user['username']}",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Email: ${user['email']}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        authProvider.logout();
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper function to construct the full local image path
  Future<String> _getLocalImagePath(String relativePath) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/connections/backend/$relativePath';
  }
}