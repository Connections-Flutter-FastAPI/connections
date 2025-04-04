import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  // Animation controllers
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: ThemeConstants.mediumAnimation,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login(ApiService apiService, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final result = await apiService.login(_emailController.text, _passwordController.text);
        authProvider.setAuthToken(result['token']);
        authProvider.setUserId(result['user_id'].toString());

        // Navigate to home screen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: ThemeConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              ThemeConstants.backgroundDarkest,
              ThemeConstants.backgroundDark,
            ]
                : [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: size.width > 600 ? 500 : size.width,
                      decoration: BoxDecoration(
                        color: isDark
                            ? ThemeConstants.backgroundDark.withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(ThemeConstants.largePadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo and title
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                                width: 100,
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: ThemeConstants.headingText,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.smallPadding),
                            Text(
                              'Login to access your account',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.largePadding),

                            // Email field
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),

                            // Password field
                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              obscureText: _obscureText,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                            ),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: ThemeConstants.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),

                            // Login Button
                            CustomButton(
                              text: 'Login',
                              onPressed: () => _login(apiService, authProvider),
                              isLoading: _isLoading,
                              isFullWidth: true,
                              size: ButtonSize.large,
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),

                            // Divider with "OR"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: ThemeConstants.mediumPadding,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),

                            // Social login options
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: Icons.person,
                                  color: Colors.orange,
                                  onTap: () {
                                    // Guest login
                                  },
                                ),
                                const SizedBox(width: ThemeConstants.mediumPadding),
                                _buildSocialButton(
                                  icon: Icons.g_mobiledata,
                                  color: Colors.red,
                                  onTap: () {
                                    // Google login
                                  },
                                ),
                                const SizedBox(width: ThemeConstants.mediumPadding),
                                _buildSocialButton(
                                  icon: Icons.facebook,
                                  color: Colors.blue,
                                  onTap: () {
                                    // Facebook login
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: ThemeConstants.largePadding),

                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: ThemeConstants.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? ThemeConstants.backgroundDarker : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
