import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';

// Assume you have a ThemeProvider or similar state management for theme
// For this example, we'll use a simple StatefulWidget
// import 'package:provider/provider.dart';
// import 'your_theme_provider.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // Placeholder state - replace with your actual state management
  bool isDark = true; // Default based on our palette
  bool _locationVisible = true;
  List<String> _selectedInterests = ['Movies', 'Hackathons']; // Example

  // Example list of available interests
  final List<String> _availableInterests = [
    'Movies', 'Sports', 'Hackathons', 'Music', 'Gaming', 'Art', 'Travel', 'Food'
  ];

  void _toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
    // TODO: Call your ThemeProvider to actually change the theme
    // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    print('Dark Mode Toggled: $isDark');
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme changed (Simulated)'), backgroundColor: kCyan),
     );
  }

   void _toggleLocation(bool value) {
    setState(() {
      _locationVisible = value;
    });
    // TODO: Save location preference
    print('Location Visibility Toggled: $_locationVisible');
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location preference updated (Simulated)'), backgroundColor: kCyan),
     );
  }

  void _updateInterests() {
    // TODO: Show a dialog or navigate to a multi-select page for interests
    // For simplicity, just printing here
    print('Update Interests Tapped. Current: $_selectedInterests');
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interest selection placeholder'), backgroundColor: kCyan),
     );
    // Example: Navigate to a dedicated page
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditInterestsPage(initialInterests: _selectedInterests)))
    //      .then((updatedInterests) {
    //      if (updatedInterests != null) {
    //         setState(() { _selectedInterests = updatedInterests; });
    //         // TODO: Save updated interests
    //      }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider if using Provider
    // final themeProvider = Provider.of<ThemeProvider>(context);
    // isDark = themeProvider.isDark; // Sync state

    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Appearance & Preferences', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: [
          // --- Dark Mode ---
          _buildSectionHeader("Appearance"),
          SwitchListTile.adaptive( // adaptive looks native on iOS/Android
            title: const Text('Dark Mode', style: TextStyle(color: kLightText)),
            subtitle: const Text('Reduce eye strain in low light', style: TextStyle(color: kSubtleGray)),
            value: isDark,
            onChanged: _toggleTheme,
            activeColor: kHighlightYellow, // Thumb color when on
            activeTrackColor: kCyan.withOpacity(0.5),
            inactiveThumbColor: kSubtleGray,
            inactiveTrackColor: kSubtleGray.withOpacity(0.3),
            secondary: const Icon(Icons.dark_mode_outlined, color: kCyan),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          ),

          const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 20),

           // --- Interests ---
           _buildSectionHeader("Content"),
           _buildPreferenceItem(
             icon: Icons.interests_outlined,
             title: "Preferred Interests",
             subtitle: _selectedInterests.isNotEmpty
               ? 'Tap to update (${_selectedInterests.join(', ')})'
               : 'Tap to select interests',
             onTap: _updateInterests,
           ),

          const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 20),

          // --- Location ---
          _buildSectionHeader("Location"),
          SwitchListTile.adaptive(
            title: const Text('Location Suggestions', style: TextStyle(color: kLightText)),
            subtitle: const Text('Allow suggestions based on your general location', style: TextStyle(color: kSubtleGray)),
            value: _locationVisible,
            onChanged: _toggleLocation,
             activeColor: kHighlightYellow,
             activeTrackColor: kCyan.withOpacity(0.5),
             inactiveThumbColor: kSubtleGray,
             inactiveTrackColor: kSubtleGray.withOpacity(0.3),
            secondary: const Icon(Icons.location_on_outlined, color: kCyan),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          ),
        ],
      ),
    );
  }

   // Helper widget for section headers (similar to main settings page)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 20.0, bottom: 5.0, right: 20.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: kHighlightYellow,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

   // Helper for tappable preference items (like Interests)
   Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
   }) {
     return ListTile(
        leading: Icon(icon, color: kCyan),
        title: Text(title, style: const TextStyle(color: kLightText)),
        subtitle: Text(subtitle, style: const TextStyle(color: kSubtleGray)),
        trailing: Icon(Icons.chevron_right, color: kSubtleGray.withOpacity(0.7)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        splashColor: kCyan.withOpacity(0.1),
     );
   }
}