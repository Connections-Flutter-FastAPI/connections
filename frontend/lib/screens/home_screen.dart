import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart';
import 'explore_screen.dart';
import 'communities_screen.dart';
import 'chatroom_screen.dart';
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
      const ExploreScreen(),
      const CommunitiesScreen(),
      const ChatroomScreen(),
      const MeScreen(),
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
    final isDark = themeNotifier.isDarkMode;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? ThemeConstants.backgroundDarker : Colors.white,
        selectedItemColor: ThemeConstants.accentColor,
        unselectedItemColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        showUnselectedLabels: true,
        items: [
          _buildNavItem(Icons.explore_outlined, Icons.explore, 'Explore', 0),
          _buildNavItem(Icons.people_outline, Icons.people, 'Communities', 2),
          _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 3),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 0),
        ],
        elevation: 8,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int badgeCount,
  ) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(
            _selectedIndex == _screens.indexWhere((screen) => screen.toString().contains(label))
              ? activeIcon
              : icon,
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: ThemeConstants.errorColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
