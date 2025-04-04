// frontend/lib/screens/me_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart';
import '../app_constants.dart'; // For default avatar (though not used if initial is fetched)
import 'login_screen.dart';
import 'settings.dart'; // Import settings page
import 'settings_feature/account/edit_profile.dart'; // Import edit profile

class MeScreen extends StatefulWidget {
  const MeScreen({Key? key}) : super(key: key);

  @override
  _MeScreenState createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Mock user data - Keep for now as backend /me might not return all stats
  final Map<String, dynamic> _mockUserStats = {
    'joinedCommunities': 8,
    'eventsParticipated': 15,
    'posts': 27,
    'replies': 42,
  };

  // Mock recent events - Keep for now
  final List<Map<String, dynamic>> _mockRecentEvents = [
    {'name': 'Tech Conference 2023', 'date': '2 days ago', 'communityName': 'Tech Enthusiasts'},
    {'name': 'Book Club Discussion', 'date': '1 week ago', 'communityName': 'Book Club'},
    {'name': 'Morning Fitness Session', 'date': '2 weeks ago', 'communityName': 'Fitness Freaks'},
  ];

  // --- Helper Functions ---
  List<Color> _getAvatarGradient(String? seed) {
    if (seed == null || seed.isEmpty) {
      return [ThemeConstants.primaryColor, ThemeConstants.accentColor];
    }
    final seedValue = seed.toLowerCase().codeUnitAt(0);
    final random = math.Random(seedValue);
    final hue1 = random.nextDouble() * 360;
    final hue2 = (hue1 + 40 + random.nextDouble() * 40) % 360;
    return [
      HSLColor.fromAHSL(1, hue1, 0.7, 0.5).toColor(),
      HSLColor.fromAHSL(1, hue2, 0.8, 0.4).toColor(),
    ];
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    ).then((_) {
      // Refresh profile data after returning from edit screen
      if (mounted) {
        setState(() {}); // Trigger FutureBuilder rebuild
      }
    });
  }

  void _logout(AuthProvider authProvider) {
    // Show confirmation dialog maybe?
    authProvider.logout();
    // Navigate to login screen after logout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep state

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use Consumer for AuthProvider to react to login/logout state changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated || authProvider.token == null) {
          return _buildNotLoggedIn(isDark); // Show login prompt
        }

        // Use FutureBuilder to fetch user details only when logged in
        final apiService = Provider.of<ApiService>(context, listen: false);
        return FutureBuilder<Map<String, dynamic>>(
          // Key the FutureBuilder with the token to refetch if token changes (e.g., re-login)
          key: ValueKey(authProvider.token),
          future: apiService.fetchUserDetails(authProvider.token!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen(isDark);
            }

            if (snapshot.hasError) {
              print("Error fetching user details: ${snapshot.error}");
              // Handle specific errors, e.g., token expiry -> logout
              if (snapshot.error.toString().contains("Token expired")) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _logout(authProvider);
                });
                return _buildNotLoggedIn(isDark); // Show login prompt immediately
              }
              return _buildErrorScreen(snapshot.error.toString(), isDark);
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildErrorScreen("No user data received.", isDark); // Handle empty data case
            }

            final user = snapshot.data!;
            final avatarGradient = _getAvatarGradient(user['name']);
            final String? imagePath = user['image_path']; // Get image path from user data
            final String? avatarUrl = imagePath != null ? '${AppConstants.baseUrl}/$imagePath' : null; // Construct URL - Adjust if backend serves differently

            return Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  // Trigger a rebuild of the FutureBuilder by changing state
                  setState(() {});
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(ThemeConstants.largePadding),
                        decoration: BoxDecoration(
                          color: isDark ? ThemeConstants.backgroundDarker : Colors.white,
                          boxShadow: ThemeConstants.softShadow(),
                        ),
                        child: Column(
                          children: [
                            // Avatar with initial or image
                            Hero(
                              tag: 'profile_avatar',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300, // Fallback color
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null, // Load network image
                                // Fallback to gradient/initial if no image
                                child: avatarUrl == null
                                    ? Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: avatarGradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getInitial(user['name']),
                                      style: const TextStyle(
                                        color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                    : null, // Don't show initial if image is loading/present
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),
                            Text(
                              user['name'] ?? 'User Name',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user['username'] ?? 'username'}',
                              style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text( // Display College
                              user['college'] ?? 'College not specified',
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                            const SizedBox(height: ThemeConstants.mediumPadding),
                            OutlinedButton.icon(
                              onPressed: _navigateToEditProfile, // Navigate to edit
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Profile'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ThemeConstants.accentColor, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.buttonBorderRadius)),
                                padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding, vertical: ThemeConstants.smallPadding / 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stats Section (Using Mock Data For Now)
                      // TODO: Fetch actual stats from backend if available
                      Padding(
                        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius)),
                          child: Padding(
                            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                const SizedBox(height: ThemeConstants.mediumPadding),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2, childAspectRatio: 2.5, // Adjust aspect ratio
                                  crossAxisSpacing: ThemeConstants.smallPadding, mainAxisSpacing: ThemeConstants.smallPadding,
                                  children: [
                                    _buildStatCard('Communities', _mockUserStats['joinedCommunities'].toString(), Icons.people, ThemeConstants.accentColor, isDark),
                                    _buildStatCard('Events', _mockUserStats['eventsParticipated'].toString(), Icons.event, ThemeConstants.highlightColor, isDark),
                                    _buildStatCard('Posts', _mockUserStats['posts'].toString(), Icons.article, Colors.orangeAccent, isDark),
                                    _buildStatCard('Replies', _mockUserStats['replies'].toString(), Icons.chat_bubble, Colors.purpleAccent, isDark),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Recent Activity Section (Using Mock Data For Now)
                      // TODO: Fetch actual activity from backend if available
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius)),
                          child: Padding(
                            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                    TextButton(onPressed: () { /* Navigate to full activity */ }, child: const Text('View All')),
                                  ],
                                ),
                                const SizedBox(height: ThemeConstants.smallPadding),
                                ..._mockRecentEvents.map((event) => _buildActivityItem(event['name'], event['date'], event['communityName'], isDark)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Account Actions Card
                      Padding(
                        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: ThemeConstants.smallPadding), // Vertical padding for list items
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding( // Header padding
                                  padding: const EdgeInsets.only(left: ThemeConstants.mediumPadding, top: ThemeConstants.smallPadding, bottom: 4),
                                  child: Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                                ),
                                // Use ListTile for better alignment and tap area
                                _buildAccountActionTile('Settings', Icons.settings_outlined, ThemeConstants.accentColor, isDark, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
                                _buildAccountActionTile('Logout', Icons.exit_to_app, ThemeConstants.errorColor, isDark, onTap: () => _logout(authProvider)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // App version info
                      Padding(
                        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                        child: Text(
                          'Connections v${AppConstants.appVersion}', // Use constant
                          style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.largePadding), // Bottom padding
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper Build Methods --- (Keep _buildStatCard, _buildActivityItem, _buildNotLoggedIn, _buildLoadingScreen, _buildErrorScreen)

  // Updated Account Action builder using ListTile
  Widget _buildAccountActionTile(
      String title,
      IconData icon,
      Color color,
      bool isDark, {
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.grey.shade600),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: ThemeConstants.mediumPadding, vertical: 4),
      dense: true, // Make it slightly smaller vertically
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.smallPadding),
      decoration: BoxDecoration(
        color: isDark ? ThemeConstants.backgroundDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(ThemeConstants.borderRadius)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String date, String community, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.smallPadding),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: ThemeConstants.primaryColor.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.event_note, color: Colors.white, size: 20), // Changed icon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text('In $community • $date', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn(bool isDark) {
    return Scaffold( // Needs Scaffold parent
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade200),
                child: Icon(Icons.person_off_outlined, size: 60, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
              ),
              const SizedBox(height: ThemeConstants.largePadding),
              Text('You are not logged in', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: ThemeConstants.smallPadding),
              Text('Log in to view your profile and access all features', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.grey.shade700), textAlign: TextAlign.center),
              const SizedBox(height: ThemeConstants.largePadding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Use pushAndRemoveUntil to clear navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: ThemeConstants.mediumPadding)),
                  child: const Text('Log In / Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDark) {
    return Scaffold( // Needs Scaffold parent
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: ThemeConstants.accentColor),
            const SizedBox(height: ThemeConstants.mediumPadding),
            Text('Loading profile...', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error, bool isDark) {
    return Scaffold( // Needs Scaffold parent
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: ThemeConstants.errorColor),
              const SizedBox(height: ThemeConstants.mediumPadding),
              Text('Error loading profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: ThemeConstants.smallPadding),
              Text(error, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade700), textAlign: TextAlign.center),
              const SizedBox(height: ThemeConstants.largePadding),
              ElevatedButton.icon( // Added icon to retry button
                onPressed: () => setState(() {}), // Trigger rebuild
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}