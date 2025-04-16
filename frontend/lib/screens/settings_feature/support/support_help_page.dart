import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class SupportHelpPage extends StatelessWidget {
  const SupportHelpPage({super.key});

  // --- TODO: Replace with your actual URLs ---
  final String faqUrl = 'https://yourdomain.com/faq';
  final String contactEmail = 'support@yourdomain.com';
  final String reportUrl = 'https://yourdomain.com/report';
  // --- End TODO ---

  // Helper to launch URL
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error: Could not launch URL
      print('Could not launch $urlString');
      // Optionally show a SnackBar to the user
    }
  }

  // Helper to launch email
   Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
       scheme: 'mailto',
       path: email,
       queryParameters: {'subject': 'Connections App Support Request'}, // Optional subject
    );
     if (!await launchUrl(emailLaunchUri)) {
       print('Could not launch email to $email');
     }
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Support & Help', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: [
          _buildSupportItem(
            context,
            icon: Icons.quiz_outlined,
            title: "FAQs",
            subtitle: "Find answers to common questions",
            onTap: () => _launchURL(faqUrl),
          ),
          const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
          _buildSupportItem(
            context,
            icon: Icons.email_outlined,
            title: "Contact Support",
            subtitle: "Get help via email",
            onTap: () => _launchEmail(contactEmail),
          ),
          const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
           _buildSupportItem(
            context,
            icon: Icons.report_problem_outlined,
            title: "Report a Problem",
            subtitle: "Report bugs or inappropriate content",
            onTap: () => _launchURL(reportUrl), // Link to a report form/page
          ),
           const Divider(color: kSubtleGray, indent: 20, endIndent: 20, height: 1),
        ],
      ),
    );
  }

   // Reusable ListTile for support items
   Widget _buildSupportItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
   }) {
     return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        leading: Icon(icon, color: kCyan, size: 24),
        title: Text(title, style: const TextStyle(color: kLightText, fontSize: 16)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: kSubtleGray, fontSize: 13)) : null,
        trailing: Icon(Icons.open_in_new, color: kSubtleGray.withOpacity(0.7), size: 20), // Indicate external link
        onTap: onTap,
        splashColor: kCyan.withOpacity(0.1),
     );
   }
}
// TODO Implement this library.
