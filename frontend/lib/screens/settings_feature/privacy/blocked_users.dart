// lib/settings/settings_feature/privacy/blocked_users_page.dart
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Blocked Users', style: TextStyle(color: kLightText)),
         backgroundColor: kDeepMidnightBlue,
         iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: Center( // Replace with ListView.builder to show actual blocked users
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
             Icon(Icons.block, color: kSubtleGray, size: 50),
             SizedBox(height: 10),
             Text(
              'Blocked Users List Here',
              style: TextStyle(color: kSubtleGray, fontSize: 16),
             ),
             // TODO: Implement list view and unblock functionality
          ],
        ),
      ),
    );
  }
}