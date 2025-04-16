// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '/theme/theme_constants.dart';
import '/widgets/custom_button.dart';
import '/services/auth_provider.dart'; // Import AuthProvider
import '/screens/login_screen.dart'; // Import LoginScreen for navigation

class LogoutDeletePage extends StatelessWidget {
  const LogoutDeletePage({super.key});

  // --- Logout Action ---
  Future<void> _logout(BuildContext context) async {
     // Optional: Show confirmation dialog
     final confirmed = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
          backgroundColor: kDeepMidnightBlue.withOpacity(0.9),
          titleTextStyle: const TextStyle(color: kHighlightYellow, fontSize: 18),
          contentTextStyle: const TextStyle(color: kLightText),
         title: const Text('Confirm Logout'),
         content: const Text('Are you sure you want to log out?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: kCyan))),
           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
         ],
       ),
     );

     if (confirmed == true && context.mounted) { // Check context.mounted
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout(); // Clear token etc.
         // Navigate to login screen and remove all previous routes
         Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
         );
     }
  }

  // --- Delete Account Action ---
  Future<void> _confirmDeleteAccount(BuildContext context) async {
     final confirmed = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: Colors.red[900]?.withOpacity(0.9), // Warning background
          titleTextStyle: const TextStyle(color: kHighlightYellow, fontSize: 18),
          contentTextStyle: const TextStyle(color: kLightText),
         title: const Text('Delete Account?'),
         content: const Text('WARNING: This action is permanent and cannot be undone. All your data, posts, and communities will be deleted. Are you absolutely sure?'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: kHighlightYellow))),
           TextButton(
             onPressed: () => Navigator.pop(context, true),
             child: const Text('DELETE ACCOUNT', style: TextStyle(color: kHighlightYellow, fontWeight: FontWeight.bold)),
           ),
         ],
       ),
     );

     if (confirmed == true && context.mounted) {
        _performDeleteAccount(context);
     }
  }

  Future<void> _performDeleteAccount(BuildContext context) async {
      print('Attempting to delete account...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // final apiService = Provider.of<ApiService>(context, listen: false);

      // --- TODO: Replace with actual API call to delete account ---
       // try {
       //    await apiService.deleteAccount(authProvider.token!);
       //    print('Account deletion API call successful.');
       // } catch (e) {
       //    print('Error deleting account via API: $e');
       //     ScaffoldMessenger.of(context).showSnackBar(
       //        SnackBar(content: Text('Failed to delete account: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor),
       //     );
       //     return; // Stop if API fails
       // }
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      // --- End TODO ---

      // Logout locally after successful API call (or simulation)
      print('Account deleted (Simulated). Logging out.');
       await authProvider.logout();
       // Navigate to login screen
       Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
       );
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Account deleted successfully.'), backgroundColor: kCyan),
       );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Account Actions', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align top
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
          children: [
            // --- Logout Section ---
            const Text(
              'Logout',
              style: TextStyle(color: kHighlightYellow, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will be logged out of your account on this device.',
              style: TextStyle(color: kSubtleGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Logout',
              onPressed: () => _logout(context),
              type: ButtonType.primary,
              // backgroundColor: kCyan.withOpacity(0.8),
              // foregroundColor: kDeepMidnightBlue,
            ),

            const SizedBox(height: 40),
            const Divider(color: kSubtleGray),
            const SizedBox(height: 20),

            // --- Delete Account Section ---
             const Text(
              'Delete Account',
              style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
             const SizedBox(height: 8),
             const Text(
              'Permanently delete your account and all associated data. This action cannot be undone.',
              style: TextStyle(color: kSubtleGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
             CustomButton(
              text: 'Delete My Account',
              onPressed: () => _confirmDeleteAccount(context),
              type: ButtonType.primary,
              // backgroundColor: Colors.redAccent.withOpacity(0.8),
              // foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
