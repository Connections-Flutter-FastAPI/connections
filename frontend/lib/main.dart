import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
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

  ThemeNotifier() : _themeData = darkTheme(); // Start with dark theme by default

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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: themeNotifier.getTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const MainNavigationScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final TabController _tabController;
  
  // List of screens
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
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: ThemeConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _tabController.animateTo(index);
          });
        },
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
          child: TabBar(
            controller: _tabController,
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
      icon: Stack(
        children: [
          AnimatedContainer(
            duration: ThemeConstants.shortAnimation,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected ? ThemeConstants.glowEffect(ThemeConstants.accentColor, radius: 12) : null,
            ),
            child: Icon(
              icon,
              size: isSelected ? 28 : 24,
            ),
          ),
          if (label == 'Chatroom' && index != _selectedIndex)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: ThemeConstants.errorColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      text: label,
      height: 60,
    );
  }
}