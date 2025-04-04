// TODO Implement this library.
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class LegalPoliciesPage extends StatelessWidget {
  const LegalPoliciesPage({super.key});

  // --- TODO: Replace with your actual URLs ---
  final String termsUrl = 'https://yourdomain.com/terms';
  final String privacyUrl = 'https://yourdomain.com/privacy';
  final String guidelinesUrl = 'https://yourdomain.com/guidelines';
  // --- End TODO ---

  // Helper to launch URL (same as in SupportHelpPage)
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Legal & Policies', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: [
          _buildLegalItem(
            context,
            icon: Icons.description_outlined,
            title: "Terms of Service",
            onTap: () => _launchURL(termsUrl),
          ),
           const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
          _buildLegalItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () => _launchURL(privacyUrl),
          ),
           const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
          _buildLegalItem(
            context,
            icon: Icons.rule_outlined,
            title: "Community Guidelines",
            onTap: () => _launchURL(guidelinesUrl),
          ),
          const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
          // Add more legal links if needed (e.g., Cookie Policy, Licenses)
        ],
      ),
    );
  }

  // Reusable ListTile for legal items
  Widget _buildLegalItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
     return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        leading: Icon(icon, color: kCyan, size: 24),
        title: Text(title, style: const TextStyle(color: kLightText, fontSize: 16)),
        trailing: Icon(Icons.open_in_new, color: kSubtleGray.withOpacity(0.7), size: 20),
        onTap: onTap,
        splashColor: kCyan.withOpacity(0.1),
     );
   }
}
