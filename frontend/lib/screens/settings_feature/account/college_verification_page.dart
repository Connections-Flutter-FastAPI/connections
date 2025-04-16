// TODO Implement this library.
import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';
import '/widgets/custom_text_field.dart';
import '/widgets/custom_button.dart';

class CollegeVerificationPage extends StatefulWidget {
  const CollegeVerificationPage({super.key});

  @override
  State<CollegeVerificationPage> createState() => _CollegeVerificationPageState();
}

class _CollegeVerificationPageState extends State<CollegeVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _verificationSent = false; // Track if verification email was sent

  // TODO: Load initial state (e.g., if user is already verified or email sent)

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      print('Sending verification email to: ${_emailController.text}');

      // --- TODO: Replace with actual API call to send verification ---
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      bool success = true; // Simulate API success
      // try {
      //   await apiService.sendCollegeVerification(_emailController.text, token);
      //   success = true;
      // } catch (e) {
      //   print("Error sending verification: $e");
      //    ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Failed to send email: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor),
      //    );
      //   success = false;
      // }
      // --- End TODO ---

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (success) {
             _verificationSent = true; // Update UI state
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Verification email sent! Check your inbox.'), backgroundColor: kCyan),
             );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('College Verification', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
        iconTheme: const IconThemeData(color: kCyan),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                 'Verify your college email (.edu) to unlock exclusive communities and features.',
                 style: TextStyle(color: kSubtleGray, fontSize: 14),
               ),
               const SizedBox(height: 25),
              CustomTextField(
                controller: _emailController,
                labelText: 'College Email Address',
                hintText: 'e.g., your_id@college.edu',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.school_outlined, color: kCyan),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your college email';
                  // Simple .edu check (improve validation as needed)
                  if (!value.toLowerCase().endsWith('.edu')) return 'Must be a valid .edu email address';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: _verificationSent ? 'Resend Verification' : 'Send Verification Email',
                onPressed: _sendVerificationEmail,
                isLoading: _isLoading,
                isFullWidth: true,
                 type: ButtonType.primary,
                 // backgroundColor: kHighlightYellow,
                 // foregroundColor: kDeepMidnightBlue,
              ),
              const SizedBox(height: 20),
              if (_verificationSent)
                 Text(
                    'Check your college email inbox (and spam folder) for a verification link or code.',
                    style: TextStyle(color: kCyan.withOpacity(0.8), fontSize: 13),
                    textAlign: TextAlign.center,
                 ),
              // TODO: Add field for entering verification code if applicable
            ],
          ),
        ),
      ),
    );
  }
}
