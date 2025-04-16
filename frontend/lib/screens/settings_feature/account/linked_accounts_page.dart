// TODO Implement this library.
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
import '/widgets/custom_button.dart'; // Assuming you have this

class LinkedAccountsPage extends StatefulWidget {
  const LinkedAccountsPage({super.key});

  @override
  State<LinkedAccountsPage> createState() => _LinkedAccountsPageState();
}

class _LinkedAccountsPageState extends State<LinkedAccountsPage> {
  // --- TODO: Replace with actual linked status from API/AuthProvider ---
  bool _isGoogleLinked = false;
  bool _isFacebookLinked = false;
  // --- End TODO ---

  Future<void> _linkAccount(String provider) async {
    print('Attempting to link $provider...');
    // --- TODO: Implement actual linking flow using relevant SDKs (google_sign_in, etc.) ---
    // This involves native platform code and handling callbacks/tokens.
    await Future.delayed(const Duration(seconds: 1)); // Simulate
     if (mounted) {
       setState(() {
         if (provider == 'Google') _isGoogleLinked = true;
         if (provider == 'Facebook') _isFacebookLinked = true;
       });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('$provider linked (Simulated)'), backgroundColor: kCyan),
        );
     }
    // --- End TODO ---
  }

  Future<void> _unlinkAccount(String provider) async {
    print('Attempting to unlink $provider...');
     // --- TODO: Implement actual unlinking flow via API call ---
     await Future.delayed(const Duration(seconds: 1)); // Simulate
      if (mounted) {
        setState(() {
          if (provider == 'Google') _isGoogleLinked = false;
          if (provider == 'Facebook') _isFacebookLinked = false;
        });
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$provider unlinked (Simulated)'), backgroundColor: kHighlightYellow),
         );
      }
     // --- End TODO ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Linked Accounts', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLinkedAccountTile(
            providerName: 'Google',
            icon: Icons.g_mobiledata, // Or a proper Google logo
            iconColor: Colors.redAccent,
            isLinked: _isGoogleLinked,
            onLink: () => _linkAccount('Google'),
            onUnlink: () => _unlinkAccount('Google'),
          ),
          const Divider(color: kSubtleGray, height: 1),
          _buildLinkedAccountTile(
            providerName: 'Facebook',
            icon: Icons.facebook,
            iconColor: Colors.blueAccent,
            isLinked: _isFacebookLinked,
            onLink: () => _linkAccount('Facebook'),
            onUnlink: () => _unlinkAccount('Facebook'),
          ),
          // Add more providers as needed (Apple, Twitter, etc.)
           const Divider(color: kSubtleGray, height: 1),
           const SizedBox(height: 20),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16.0),
             child: Text(
               'Linking accounts allows for quicker login and potential future integrations.',
               style: TextStyle(color: kSubtleGray, fontSize: 13),
               textAlign: TextAlign.center,
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildLinkedAccountTile({
    required String providerName,
    required IconData icon,
    required Color iconColor,
    required bool isLinked,
    required VoidCallback onLink,
    required VoidCallback onUnlink,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: Icon(icon, color: iconColor, size: 32),
      title: Text(providerName, style: const TextStyle(color: kLightText, fontWeight: FontWeight.w500)),
      trailing: CustomButton(
        text: isLinked ? 'Unlink' : 'Link',
        onPressed: isLinked ? onUnlink : onLink,
        type: isLinked ? ButtonType.outline : ButtonType.primary,
        size: ButtonSize.small,
        // foregroundColor: isLinked ? Colors.redAccent : kDeepMidnightBlue,
        // backgroundColor: isLinked ? Colors.transparent : kHighlightYellow,
        // borderColor: isLinked ? Colors.redAccent : null, // Add this for outline button
      ),
    );
  }
}

// Add these to CustomButton if they don't exist
// In CustomButton class:
// final Color? foregroundColor;
// final Color? backgroundColor;
// final Color? borderColor;

// In CustomButton constructor:
// this.foregroundColor,
// this.backgroundColor,
// this.borderColor,

// In _buildPrimaryButton, _buildOutlineButton etc.:
// Use backgroundColor, foregroundColor, borderColor where appropriate,
// falling back to theme defaults if null.
// Example for primary:
// backgroundColor: widget.backgroundColor ?? ThemeConstants.accentColor,
// foregroundColor: widget.foregroundColor ?? ThemeConstants.primaryColor,
// Example for outline:
// side: BorderSide(color: widget.borderColor ?? ThemeConstants.accentColor, width: 2),
// foregroundColor: widget.foregroundColor ?? ThemeConstants.accentColor,
