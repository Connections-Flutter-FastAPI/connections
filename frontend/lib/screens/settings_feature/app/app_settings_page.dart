import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
import '/app_constants.dart'; // Use app constants for version
// import 'package:package_info_plus/package_info_plus.dart'; // Optional: For dynamic version

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  String _appVersion = AppConstants.appVersion; // Use constant initially
  bool _isLoadingVersion = false; // Loading state for dynamic version

  @override
  void initState() {
    super.initState();
    // _loadAppVersion(); // Uncomment if using package_info_plus
  }

  // --- Optional: Load version dynamically ---
  // Future<void> _loadAppVersion() async {
  //   setState(() => _isLoadingVersion = true);
  //   try {
  //     PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //     if (mounted) {
  //       setState(() {
  //         _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
  //         _isLoadingVersion = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error loading app version: $e");
  //     if (mounted) {
  //        setState(() => _isLoadingVersion = false);
  //        // Keep constant version as fallback
  //     }
  //   }
  // }
  // --- End Optional ---

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDeepMidnightBlue.withOpacity(0.9),
         titleTextStyle: const TextStyle(color: kHighlightYellow, fontSize: 18),
         contentTextStyle: const TextStyle(color: kLightText),
        title: const Text('Clear Cache?'),
        content: const Text('This will remove temporary files. You might need to log in again or re-download some data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: kCyan))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Cache', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      print('Clearing cache (Simulated)...');
      // --- TODO: Implement actual cache clearing logic ---
      // This depends on what you cache (images, http cache, etc.)
      // Example using flutter_cache_manager:
      // await DefaultCacheManager().emptyCache();
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate
      // --- End TODO ---
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Cache cleared (Simulated)'), backgroundColor: kCyan),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('App Settings', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
         padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.cleaning_services_outlined,
            title: "Clear Cache",
            subtitle: "Remove temporary data",
            onTap: _clearCache,
          ),
          const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
           _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: "App Version",
             // Show loading indicator or actual version
            subtitleWidget: _isLoadingVersion
              ? const SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 1))
              : Text(_appVersion, style: const TextStyle(color: kSubtleGray)),
            // onTap: _loadAppVersion, // Optional: Allow tapping to refresh version
          ),
            const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
          // Add more app settings if needed (e.g., Data Usage)
        ],
      ),
    );
  }

    // Helper widget for individual settings items (Adapted for subtitle widget)
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle, // Optional string subtitle
    Widget? subtitleWidget, // Optional widget subtitle (takes precedence)
    VoidCallback? onTap,
    Color iconColor = kCyan,
    Color textColor = kLightText,
  }) {
    return ListTile(
       contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
       leading: Icon(icon, color: iconColor, size: 24),
       title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
       subtitle: subtitleWidget ?? (subtitle != null ? Text(subtitle, style: const TextStyle(color: kSubtleGray, fontSize: 13)) : null),
       trailing: onTap != null ? Icon(Icons.chevron_right, color: kSubtleGray.withOpacity(0.7), size: 20) : null,
       onTap: onTap,
       splashColor: kCyan.withOpacity(0.1),
    );
  }
}
// TODO Implement this library.
