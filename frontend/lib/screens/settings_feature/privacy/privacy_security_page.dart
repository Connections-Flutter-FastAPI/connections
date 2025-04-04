// TODO Implement this library.
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // If using SharedPreferences

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // --- TODO: Load initial values from SharedPreferences or API ---
  bool _profileVisibleToAll = true;
  bool _activityStatusVisible = true;
  bool _allowMessageRequests = true;
  bool _twoFactorEnabled = false; // Example, might require more complex flow
  // --- End TODO ---

  @override
  void initState() {
    super.initState();
    // _loadPreferences(); // Call method to load saved prefs
  }

  // Example loading preferences (if using SharedPreferences)
  // Future<void> _loadPreferences() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _profileVisibleToAll = prefs.getBool('profileVisibleToAll') ?? true;
  //     _activityStatusVisible = prefs.getBool('activityStatusVisible') ?? true;
  //     _allowMessageRequests = prefs.getBool('allowMessageRequests') ?? true;
  //     _twoFactorEnabled = prefs.getBool('twoFactorEnabled') ?? false;
  //   });
  // }

  // Example saving preference
  Future<void> _updatePreference(String key, bool value) async {
    print('Updating $key to $value');
    // --- TODO: Save using SharedPreferences or API Call ---
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(key, value);
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate async
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('$key updated (Simulated)'), duration: const Duration(seconds: 1), backgroundColor: kCyan),
    );
    // --- End TODO ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Privacy Controls', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Profile Visibility"),
          SwitchListTile.adaptive(
            title: const Text('Public Profile', style: TextStyle(color: kLightText)),
            subtitle: const Text('Allow anyone to view your profile', style: TextStyle(color: kSubtleGray)),
            value: _profileVisibleToAll,
            onChanged: (value) {
              setState(() => _profileVisibleToAll = value);
              _updatePreference('profileVisibleToAll', value);
            },
            activeColor: kHighlightYellow,
            activeTrackColor: kCyan.withOpacity(0.5),
            secondary: const Icon(Icons.visibility_outlined, color: kCyan),
             contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          ),

          _buildSectionHeader("Activity Status"),
          SwitchListTile.adaptive(
            title: const Text('Show Activity Status', style: TextStyle(color: kLightText)),
            subtitle: const Text('Allow others to see when you are online', style: TextStyle(color: kSubtleGray)),
            value: _activityStatusVisible,
            onChanged: (value) {
              setState(() => _activityStatusVisible = value);
               _updatePreference('activityStatusVisible', value);
            },
             activeColor: kHighlightYellow,
             activeTrackColor: kCyan.withOpacity(0.5),
            secondary: const Icon(Icons.online_prediction, color: kCyan),
             contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          ),

          _buildSectionHeader("Direct Messages"),
          SwitchListTile.adaptive(
            title: const Text('Allow Message Requests', style: TextStyle(color: kLightText)),
            subtitle: const Text('Allow users you don\'t follow to send requests', style: TextStyle(color: kSubtleGray)),
            value: _allowMessageRequests,
            onChanged: (value) {
              setState(() => _allowMessageRequests = value);
               _updatePreference('allowMessageRequests', value);
            },
             activeColor: kHighlightYellow,
             activeTrackColor: kCyan.withOpacity(0.5),
            secondary: const Icon(Icons.message_outlined, color: kCyan),
             contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          ),

           _buildSectionHeader("Security"),
           // Note: 2FA often requires a more complex setup flow (QR code, backup codes)
          SwitchListTile.adaptive(
            title: const Text('Two-Factor Authentication', style: TextStyle(color: kLightText)),
            subtitle: Text(_twoFactorEnabled ? 'Enabled' : 'Disabled - Adds an extra layer of security', style: TextStyle(color: kSubtleGray)),
            value: _twoFactorEnabled,
            onChanged: (value) {
              // --- TODO: Trigger 2FA setup/disable flow ---
              print('2FA Toggled - Requires dedicated flow');
              // For demo, just toggle the state
               setState(() => _twoFactorEnabled = value);
               _updatePreference('twoFactorEnabled', value);
              // --- End TODO ---
            },
             activeColor: kHighlightYellow,
             activeTrackColor: kCyan.withOpacity(0.5),
            secondary: const Icon(Icons.security_outlined, color: kCyan),
             contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
}
