// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart'; // Import your existing SignupScreen
import 'screens/home_screen.dart';
import 'services/auth_provider.dart';
import 'services/api_service.dart';
import 'theme/theme_constants.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier() : _themeData = lightTheme();

  ThemeData getTheme() => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

    void toggleTheme() {
     _themeData = (_themeData == lightTheme()) ? darkTheme() : lightTheme();
      notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'FastAPI Flutter App',
          theme: themeNotifier.getTheme(),
          initialRoute: '/', // Set initial route
          routes: {
            '/': (context) => const LoginScreen(),  // Start with Login
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) =>  HomeScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
