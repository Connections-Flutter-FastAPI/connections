// screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'signup_form_screen.dart'; // Import the new form screen
import 'login_screen.dart';
import '../theme/theme_constants.dart'; // Import for theming


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  //color: Colors.black, // Remove hardcoded color
                ),
                textAlign: TextAlign.center,
              ),
              Image.asset(
                'assets/images/logoblack.png', // Replace with your actual logo
                height: 180,
              ),
              const SizedBox(height: ThemeConstants.largePadding),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Colors.blue, // Remove: Use theme
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignUpFormScreen()), // Navigate to the FORM
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18, /*color: Colors.white*/), // Remove color
                  ),
                ),
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              const Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue, // Use from theme if needed
                    //decoration: TextDecoration.underline,
                  ),
                ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child:  Text(
                  "Login now",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
