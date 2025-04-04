// TODO Implement this library.
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
import '/widgets/custom_text_field.dart'; // Assuming you have this widget
import '/widgets/custom_button.dart'; // Assuming you have this widget

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      print('Attempting to change password...');
      print('Current: ${_currentPasswordController.text}');
      print('New: ${_newPasswordController.text}');

      // --- TODO: Replace with actual API call ---
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      bool success = true; // Simulate API success/failure
      // try {
      //   await apiService.changePassword(
      //     _currentPasswordController.text,
      //     _newPasswordController.text,
      //     // Pass auth token
      //   );
      //   success = true;
      // } catch (e) {
      //   success = false;
      //   print("Error changing password: $e");
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Failed to change password: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor),
      //   );
      // }
      // --- End TODO ---

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Password changed successfully!'), backgroundColor: kCyan),
           );
           Navigator.pop(context);
        }
        // Error message is shown inside the catch block if API call fails
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                obscureText: !_currentPasswordVisible,
                prefixIcon: const Icon(Icons.lock_outline, color: kCyan),
                suffixIcon: IconButton(
                  icon: Icon(_currentPasswordVisible ? Icons.visibility_off : Icons.visibility, color: kSubtleGray),
                  onPressed: () => setState(() => _currentPasswordVisible = !_currentPasswordVisible),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter current password' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _newPasswordController,
                labelText: 'New Password',
                obscureText: !_newPasswordVisible,
                 prefixIcon: const Icon(Icons.lock_outline, color: kCyan),
                 suffixIcon: IconButton(
                  icon: Icon(_newPasswordVisible ? Icons.visibility_off : Icons.visibility, color: kSubtleGray),
                  onPressed: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter new password';
                  if (value.length < 8) return 'Password must be at least 8 characters';
                  // Add more strength validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                obscureText: !_confirmPasswordVisible,
                prefixIcon: const Icon(Icons.lock_outline, color: kCyan),
                suffixIcon: IconButton(
                  icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility, color: kSubtleGray),
                  onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm new password';
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Save Changes',
                onPressed: _submitChangePassword,
                isLoading: _isLoading,
                isFullWidth: true,
                type: ButtonType.primary,
                // backgroundColor: kHighlightYellow, // Use theme colors
                // foregroundColor: kDeepMidnightBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
