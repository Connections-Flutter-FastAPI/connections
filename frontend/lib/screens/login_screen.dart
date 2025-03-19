// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart'; // Import SignupScreen
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // For form validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // Added for password visibility toggle


  void _login(ApiService apiService, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final result = await apiService.login(_emailController.text, _passwordController.text);
        authProvider.setAuthToken(result['token']);
        authProvider.setUserId(result['user_id'].toString());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: ThemeConstants.errorColor,));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

    @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              Image.asset(
                'assets/images/logoblack.png', //  Add your logo here
                height: 120,
              ),
              const SizedBox(height: ThemeConstants.largePadding),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) { // Simple email validation
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: ThemeConstants.smallPadding),
              TextFormField(
                controller: _passwordController,
                decoration:  InputDecoration(
                  labelText: 'Password',
                    suffixIcon: IconButton( // Password visibility toggle
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _login(apiService, authProvider),
                      child: const Text('Login'),
                    ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              TextButton(
                onPressed: () {
                  // Navigate to your NEW signup screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
                child: const Text('Sign Up'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
