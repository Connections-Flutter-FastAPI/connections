import 'package:flutter/material.dart';
import '/theme/theme_constants.dart'; // Adjust path if needed

// --- Import the ACTUAL sub-page files ---
import 'settings_feature/account/edit_profile.dart';
import 'settings_feature/account/change_password_page.dart';
import 'settings_feature/account/linked_accounts_page.dart';
import 'settings_feature/account/college_verification_page.dart';
import 'settings_feature/privacy/privacy_security_page.dart';
import 'settings_feature/privacy/blocked_users.dart';
import 'settings_feature/notifications/notification_settings_page.dart';
import 'settings_feature/preferences/preferences_page.dart';
import 'settings_feature/app/app_settings_page.dart';
import 'settings_feature/support/support_help_page.dart';
import 'settings_feature/legal/legal_policies_page.dart';
import 'settings_feature/auth/logout_delete_page.dart';
// --- End Imports ---

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Helper to navigate to a page
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: kHighlightYellow, fontWeight: FontWeight.bold)),
        backgroundColor: kDeepMidnightBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: kCyan),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
          color: kCyan,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Account Settings"),
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: "Edit Profile",
            // Navigate to the imported EditProfilePage
            onTap: () => _navigateTo(context, const EditProfilePage()),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.lock_outline,
            title: "Change Password",
            // Navigate to the imported ChangePasswordPage
            onTap: () => _navigateTo(context, const ChangePasswordPage()),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.link,
            title: "Linked Accounts",
            // Navigate to the imported LinkedAccountsPage
            onTap: () => _navigateTo(context, const LinkedAccountsPage()),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.school_outlined,
            title: "College Verification",
            // Navigate to the imported CollegeVerificationPage
            onTap: () => _navigateTo(context, const CollegeVerificationPage()),
          ),

          _buildSectionHeader("Privacy & Security"),
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Controls",
            // Navigate to the imported PrivacySecurityPage
            onTap: () => _navigateTo(context, const PrivacySecurityPage()),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.block,
            title: "Blocked Users",
            // Navigate to the imported BlockedUsersPage
            onTap: () => _navigateTo(context, const BlockedUsersPage()),
          ),

          _buildSectionHeader("Notification Settings"),
          _buildSettingsItem(
            context,
            icon: Icons.notifications_outlined,
            title: "Notifications",
            // Navigate to the imported NotificationSettingsPage
            onTap: () => _navigateTo(context, const NotificationSettingsPage()),
          ),

          _buildSectionHeader("Preferences"),
          _buildSettingsItem(
            context,
            icon: Icons.palette_outlined,
            title: "Appearance & Preferences",
            // Navigate to the imported PreferencesPage
            onTap: () => _navigateTo(context, const PreferencesPage()),
          ),

          _buildSectionHeader("App Settings"),
          _buildSettingsItem(
            context,
            icon: Icons.settings_applications_outlined,
            title: "App Settings",
            // Navigate to the imported AppSettingsPage
            onTap: () => _navigateTo(context, const AppSettingsPage()),
          ),

          _buildSectionHeader("Support & Help"),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: "Support & Help",
            // Navigate to the imported SupportHelpPage
            onTap: () => _navigateTo(context, const SupportHelpPage()),
          ),

          _buildSectionHeader("Legal & Policies"),
          _buildSettingsItem(
            context,
            icon: Icons.gavel_outlined,
            title: "Legal & Policies",
            // Navigate to the imported LegalPoliciesPage
            onTap: () => _navigateTo(context, const LegalPoliciesPage()),
          ),

          _buildSectionHeader("Account Actions"),
          _buildSettingsItem(
            context,
            icon: Icons.exit_to_app,
            title: "Logout / Delete Account",
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            // Navigate to the imported LogoutDeletePage
            onTap: () => _navigateTo(context, const LogoutDeletePage()),
          ),

          const SizedBox(height: 30), // Bottom padding
        ],
      ),
    );
  }

  // Helper widget for section headers (Keep as is)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 16.0, bottom: 8.0, right: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: kHighlightYellow, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Helper widget for individual settings items (Keep as is)
  Widget _buildSettingsItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color iconColor = kCyan,
        Color textColor = kLightText,
      }) {
    return Material(
      color: kDeepMidnightBlue,
      child: InkWell(
        onTap: onTap,
        splashColor: kCyan.withOpacity(0.2),
        highlightColor: kCyan.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 20),
              Expanded(
                child: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
              ),
              Icon(Icons.chevron_right, color: kSubtleGray.withOpacity(0.7), size: 20),
            ],
          ),
        ),
      ),
    );
  }

// --- REMOVED PLACEHOLDER CLASSES AND HELPER FUNCTION ---
}