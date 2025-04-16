import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
// Removed duplicate home_screen import if MainNavigationScreen is the target
// import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/communities_screen.dart';
import 'screens/chatroom_screen.dart';
import 'screens/me_screen.dart';
import 'services/auth_provider.dart';
import 'services/api_service.dart';
import 'theme/theme_constants.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';
import 'app_constants.dart';

void main() {
  // It's better to provide ApiService before AuthProvider if AuthProvider depends on it
  final apiService = ApiService(); // Create ApiService instance

  runApp(
    MultiProvider(
      providers: [
        // Provide ApiService first
        Provider<ApiService>.value(value: apiService),
        // Create AuthProvider, passing the ApiService instance
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      // Use AuthInitializer to handle auto-login before showing the main app
      child: AuthInitializer(),
    ),
  );
}

// Wrapper widget to handle async initialization of AuthProvider
class AuthInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Attempt auto-login ONCE when this widget builds
      future: Provider.of<AuthProvider>(context, listen: false).tryAutoLogin(),
      builder: (ctx, authSnapshot) {
        // While waiting for tryAutoLogin to complete, show a loading indicator
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp( // Use a simple MaterialApp for the splash
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // After tryAutoLogin completes, build the main app
        // Use Consumer to get the initialized AuthProvider state
        return Consumer<AuthProvider>(
          builder: (ctx, authProvider, _) => MyApp(), // Build MyApp after init
        );
      },
    );
  }
}


class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  ThemeNotifier() : _themeData = darkTheme();
  ThemeData getTheme() => _themeData;
  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
  void toggleTheme() {
    _themeData = (_themeData == lightTheme()) ? darkTheme() : lightTheme();
    notifyListeners();
  }
  bool get isDarkMode => _themeData == darkTheme();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider to decide initial route
    final authProvider = Provider.of<AuthProvider>(context);
    // Also listen to ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    print("MyApp build: isAuthenticated=${authProvider.isAuthenticated}");

    return MaterialApp(
      title: AppConstants.appName,
      theme: themeNotifier.getTheme(),
      // Determine initial route based on the *initialized* auth state
      initialRoute: authProvider.isAuthenticated ? '/home' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainNavigationScreen(), // Your main screen after login
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


// --- MainNavigationScreen and _MainNavigationScreenState remain the same ---
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final TabController _tabController;

  final List<Widget> _screens = const [
    ExploreScreen(),
    CommunitiesScreen(),
    ChatroomScreen(),
    MeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Prevent state update if listener fires after dispose
      if (mounted) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
        // Animate PageView when TabBar index changes
        if (_pageController.hasClients && _pageController.page?.round() != _tabController.index) {
          _pageController.animateToPage(
            _tabController.index,
            duration: ThemeConstants.shortAnimation, // Faster animation for tab clicks
            curve: Curves.easeInOut,
          );
        }
      }
    });
    // Listen to PageView changes to update TabBar
    _pageController.addListener(() {
      if (mounted) {
        int currentPage = _pageController.page?.round() ?? 0;
        if (_selectedIndex != currentPage) {
          setState(() {
            _selectedIndex = currentPage;
          });
          // Only animate TabController if it's not already there
          if (_tabController.index != currentPage) {
            _tabController.animateTo(currentPage);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // This function is now primarily for direct programmatic changes if needed,
  // but TabBar and PageView listeners handle most sync.
  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) return; // Avoid redundant actions
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
      // Animate both TabBar and PageView
      _tabController.animateTo(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: ThemeConstants.mediumAnimation,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: PageView( // Controlled by _pageController
        controller: _pageController,
        // onPageChanged handled by listener in initState now
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeConstants.backgroundDarker : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: TabBar( // Controlled by _tabController
            controller: _tabController,
            // onTap: _onNavItemTapped, // Let listeners handle sync
            tabs: [
              _buildNavItem(Icons.explore, 'Explore', 0),
              _buildNavItem(Icons.people, 'Communities', 1),
              _buildNavItem(Icons.chat_bubble, 'Chatroom', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: ThemeConstants.accentColor,
                width: 4,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 16),
            ),
            labelColor: ThemeConstants.accentColor,
            unselectedLabelColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Tab(
      height: 60, // Ensure consistent height
      iconMargin: const EdgeInsets.only(bottom: 4), // Space between icon and text
      icon: Icon(
        icon,
        size: isSelected ? 28 : 24, // Animate size
        color: isSelected ? ThemeConstants.accentColor : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade400), // Animate color via TabBar labelColor/unselectedLabelColor
      ),
      child: Text( // Use child instead of text for better control if needed
        label,
        style: TextStyle(
          // Style is now controlled by TabBar's labelStyle/unselectedLabelStyle
          // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: isSelected ? 12 : 10, // Example size animation via style
        ),
      ),
    );
  }
}