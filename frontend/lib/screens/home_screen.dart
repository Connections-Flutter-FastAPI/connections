import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../theme/theme_constants.dart';
import 'posts_screen.dart';
import 'communities_screen.dart';
import 'me_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _screens = <Widget>[
      const PostsScreen(),
      const CommunitiesScreen(),
      MeScreen(),
    ];

    _pageController = PageController(initialPage: _selectedIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: ThemeConstants.shortAnimation,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
      // Animate to the new page
      _pageController.animateToPage(
        index,
        duration: ThemeConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeNotifier.isDarkMode;

    // Define items for bottom navigation
    final navItems = [
      CustomBottomNavItem(
        label: 'Feed',
        icon: Icons.article_outlined,
        activeIcon: Icons.article,
        onTap: () => _onNavItemTapped(0),
      ),
      CustomBottomNavItem(
        label: 'Communities',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        onTap: () => _onNavItemTapped(1),
        showBadge: true,
        badgeCount: 2, // This would be dynamic in a real app
      ),
      CustomBottomNavItem(
        label: 'Profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        onTap: () => _onNavItemTapped(2),
      ),
    ];

    final String title;
    switch (_selectedIndex) {
      case 0:
        title = 'Feed';
        break;
      case 1:
        title = 'Communities';
        break;
      case 2:
        title = 'Profile';
        break;
      default:
        title = 'Connect';
        break;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: CustomAppBar(
          title: title,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: () => themeNotifier.toggleTheme(),
            ),

            // Notifications
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: ThemeConstants.errorColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: () {
                // Show notifications
              },
            ),

            // Search
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Show search
              },
            ),
          ],
        ),

        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _screens,
        ),

        bottomNavigationBar: CustomBottomNav(
          items: navItems,
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }
}
