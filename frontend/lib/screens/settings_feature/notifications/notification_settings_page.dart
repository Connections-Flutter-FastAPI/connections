// TODO Implement this library.
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // If using SharedPreferences

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // --- TODO: Load initial values from SharedPreferences or API ---
  bool _pushNewMessages = true;
  bool _pushEventReminders = true;
  bool _pushCommunityUpdates = false;
  bool _emailNewsletters = false;
  bool _soundsEnabled = true;
  // --- End TODO ---

   @override
  void initState() {
    super.initState();
    // _loadPreferences(); // Call method to load saved prefs
  }

  // Example saving preference
  Future<void> _updatePreference(String key, bool value) async {
    print('Updating notification $key to $value');
    // --- TODO: Save using SharedPreferences or API Call ---
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(key, value);
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate async
    // Optionally show feedback, but might be annoying for every toggle
    // ScaffoldMessenger.of(context).showSnackBar(
    //    SnackBar(content: Text('Notification setting updated'), duration: Duration(seconds: 1)),
    // );
    // --- End TODO ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Push Notifications"),
          _buildNotificationToggle(
            title: 'New Messages',
            subtitle: 'Chat messages & replies',
            value: _pushNewMessages,
            onChanged: (value) {
              setState(() => _pushNewMessages = value);
              _updatePreference('pushNewMessages', value);
            },
          ),
           _buildNotificationToggle(
            title: 'Event Reminders',
            subtitle: 'Upcoming events you joined',
            value: _pushEventReminders,
            onChanged: (value) {
               setState(() => _pushEventReminders = value);
               _updatePreference('pushEventReminders', value);
            },
          ),
          _buildNotificationToggle(
            title: 'Community Updates',
            subtitle: 'New posts in followed communities (can be noisy)',
            value: _pushCommunityUpdates,
            onChanged: (value) {
               setState(() => _pushCommunityUpdates = value);
               _updatePreference('pushCommunityUpdates', value);
            },
          ),

          _buildSectionHeader("Email Notifications"),
           _buildNotificationToggle(
            title: 'Newsletters & Updates',
            subtitle: 'Occasional emails about new features',
            value: _emailNewsletters,
            onChanged: (value) {
               setState(() => _emailNewsletters = value);
               _updatePreference('emailNewsletters', value);
            },
          ),
          // Add more email options if needed (e.g., weekly digest)

          _buildSectionHeader("Sounds"),
           _buildNotificationToggle(
            title: 'In-App Sounds',
            subtitle: 'Sound effects for actions like sending messages',
            value: _soundsEnabled,
            onChanged: (value) {
              setState(() => _soundsEnabled = value);
              _updatePreference('soundsEnabled', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
     return Padding(
       padding: const EdgeInsets.only(top: 20.0, left: 20.0, bottom: 8.0, right: 16.0),
       child: Text(
         title.toUpperCase(),
         style: const TextStyle(
           color: kHighlightYellow, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.7,
         ),
       ),
     );
   }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
     return SwitchListTile.adaptive(
            title: Text(title, style: const TextStyle(color: kLightText)),
            subtitle: Text(subtitle, style: const TextStyle(color: kSubtleGray, fontSize: 13)),
            value: value,
            onChanged: onChanged,
            activeColor: kHighlightYellow,
            activeTrackColor: kCyan.withOpacity(0.5),
            inactiveThumbColor: kSubtleGray,
            inactiveTrackColor: kSubtleGray.withOpacity(0.3),
            secondary: const Icon(Icons.notifications_active_outlined, color: kCyan, size: 20), // Use a consistent icon or vary
             contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0), // Reduced vertical padding
             dense: true,
          );
  }
}
