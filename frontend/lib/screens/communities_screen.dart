// frontend/lib/screens/communities_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../widgets/community_card.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../theme/theme_constants.dart';
import 'create_community_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({Key? key}) : super(key: key);

  @override
  _CommunitiesScreenState createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _searchQuery = '';
  // Store join status locally for optimistic UI. Key: communityId (String), Value: isJoined (bool)
  final Map<String, bool> _joinedStatus = {};
  String _selectedCategory = 'all'; // Default to 'all'
  Future<List<dynamic>>? _loadCommunitiesFuture;

  // Keep static category tabs
  final List<Map<String, dynamic>> _categoryTabs = [
    {'id': 'all', 'label': 'All', 'icon': Icons.public},
    {'id': 'trending', 'label': 'Trending', 'icon': Icons.trending_up},
    {'id': 'gaming', 'label': 'Gaming', 'icon': Icons.sports_esports},
    {'id': 'tech', 'label': 'Tech', 'icon': Icons.code},
    {'id': 'music', 'label': 'Music', 'icon': Icons.music_note},
    {'id': 'art', 'label': 'Art', 'icon': Icons.palette},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _triggerCommunityLoad();
        // TODO: Optionally fetch initial joined status for communities visible on first load
      }
    });
  }

  // --- Data Loading ---
  void _triggerCommunityLoad() {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      // Determine which API call to make based on the selected category
      if (_selectedCategory == 'trending') {
        _loadCommunitiesFuture = apiService.fetchTrendingCommunities(authProvider.token);
      } else {
        // 'all' or specific interest categories use the general fetch endpoint
        // Backend filtering by interest might be needed, or frontend filtering
        _loadCommunitiesFuture = apiService.fetchCommunities(authProvider.token);
      }
    });
  }

  // --- UI Actions ---
  void _updateSearchQuery(String query) {
    if (mounted) {
      setState(() { _searchQuery = query.toLowerCase(); });
      // No need to trigger API load here, filtering is done client-side in FutureBuilder
    }
  }

  void _selectCategory(String categoryId) {
    if (!mounted) return;
    if (_selectedCategory != categoryId) {
      setState(() {
        _selectedCategory = categoryId;
      });
      _triggerCommunityLoad(); // Reload data for the new category/filter
    }
  }

  void _navigateToCreateCommunity() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a community.')),
      );
      return;
    }
    // Navigate and wait for result (e.g., if creation was successful)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCommunityScreen()),
    );
    // Refresh list if navigation didn't pop automatically or if result indicates success
    if (mounted) {
      _triggerCommunityLoad();
    }
  }

  // Toggle join/leave status
  Future<void> _toggleJoinCommunity(String communityId, bool currentlyJoined) async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join communities.')),
      );
      return;
    }

    // Optimistic UI update
    setState(() {
      _joinedStatus[communityId] = !currentlyJoined;
    });

    try {
      if (currentlyJoined) {
        await apiService.leaveCommunity(communityId, authProvider.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You left the community'), duration: Duration(seconds: 1)));
      } else {
        await apiService.joinCommunity(communityId, authProvider.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You joined the community'), duration: Duration(seconds: 1)));
      }
      // Optionally trigger a reload to refresh member counts, but might be too slow
      // _triggerCommunityLoad();
    } catch (e) {
      if (!mounted) return;
      // Revert UI on error
      setState(() {
        _joinedStatus[communityId] = currentlyJoined;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor));
    }
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep state

    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Use listen: false in build for actions
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final communityColors = ThemeConstants.communityColors;

    return Scaffold(
      // Removed AppBar to match design of other main screens
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: "Search communities...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark
                    ? ThemeConstants.backgroundDarker
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),

          // Category tabs
          SizedBox(
            height: 100, // Keep height for avatars + labels
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categoryTabs.length,
              padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.smallPadding),
              itemBuilder: (context, index) {
                final category = _categoryTabs[index];
                final isSelected = _selectedCategory == category['id'];
                return GestureDetector(
                  onTap: () => _selectCategory(category['id'] as String), // Use helper
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center content
                      children: [
                        AnimatedContainer(
                          duration: ThemeConstants.shortAnimation,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ThemeConstants.primaryColor // Use primary for selected background
                                : (isDark ? ThemeConstants.backgroundDark : Colors.grey.shade200),
                            shape: BoxShape.circle,
                            boxShadow: isSelected ? ThemeConstants.glowEffect(ThemeConstants.primaryColor) : null,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Icon(
                            category['icon'] as IconData,
                            color: isSelected
                                ? ThemeConstants.accentColor // Highlight icon color
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? ThemeConstants.primaryColor
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Community grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _triggerCommunityLoad(),
              child: FutureBuilder<List<dynamic>>(
                future: _loadCommunitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show shimmer only on initial load or refresh
                    return _buildLoadingShimmer(context);
                  }
                  if (snapshot.hasError) {
                    print("Error in FutureBuilder: ${snapshot.error}");
                    return _buildErrorUI(snapshot.error);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyUI(isDark, isSearchOrFilterActive: _selectedCategory != 'all');
                  }

                  // Client-side filtering
                  var communities = snapshot.data!.where((comm) {
                    final name = (comm['name'] ?? '').toString().toLowerCase();
                    final description = (comm['description'] ?? '').toString().toLowerCase();
                    final interest = (comm['interest'] ?? '').toString().toLowerCase();
                    final matchesSearch = _searchQuery.isEmpty || name.contains(_searchQuery) || description.contains(_searchQuery);

                    // Filter by selected category IF it's not 'all' or 'trending'
                    if (_selectedCategory != 'all' && _selectedCategory != 'trending') {
                      final categoryName = _selectedCategory.toLowerCase();
                      // Match if interest exactly matches OR name contains category (basic matching)
                      final matchesCategory = interest == categoryName || name.contains(categoryName);
                      return matchesSearch && matchesCategory;
                    }
                    // If 'all' or 'trending', only apply search filter
                    return matchesSearch;
                  }).toList();

                  if (communities.isEmpty) {
                    return _buildEmptyUI(isDark, isSearchOrFilterActive: _searchQuery.isNotEmpty || (_selectedCategory != 'all'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8, // Adjust aspect ratio if needed
                      crossAxisSpacing: ThemeConstants.mediumPadding,
                      mainAxisSpacing: ThemeConstants.mediumPadding,
                    ),
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      final community = communities[index];
                      final communityId = community['id'].toString();
                      // Use local state for join status, default to false if not fetched/interacted with yet
                      final isJoined = _joinedStatus[communityId] ?? false;
                      // TODO: Fetch initial join status if important for first load

                      final color = communityColors[community['id'].hashCode % communityColors.length]; // Use ID hash for consistency
                      final onlineCount = community['online_count'] as int? ?? 0;
                      final memberCount = community['member_count'] as int? ?? 0;

                      return CommunityCard(
                        name: community['name'] ?? 'No Name',
                        description: community['description'] as String?,
                        memberCount: memberCount,
                        onlineCount: onlineCount,
                        backgroundColor: color,
                        // Location parsing might be needed if backend returns POINT object
                        location: community['primary_location']?.toString(), // Assuming backend returns string
                        isJoined: isJoined,
                        onJoin: () => _toggleJoinCommunity(communityId, isJoined),
                        onTap: () {
                          // TODO: Implement navigation to community detail screen
                          print("Tapped community: ${community['name']}");
                          // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityDetailScreen(communityId: communityId)));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCommunity,
        tooltip: "Create Community",
        child: const Icon(Icons.add),
        backgroundColor: ThemeConstants.accentColor, // Use theme color
        foregroundColor: ThemeConstants.primaryColor,
      ),
    );
  }

  // --- Helper Build Methods --- (Keep _buildLoadingShimmer, _buildEmptyUI, _buildErrorUI)
  Widget _buildLoadingShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: ThemeConstants.mediumPadding,
          mainAxisSpacing: ThemeConstants.mediumPadding,
        ),
        itemCount: 6, // Number of shimmer placeholders
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white, // Base color for shimmer
            borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyUI(bool isDark, {bool isSearchOrFilterActive = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No communities found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            isSearchOrFilterActive
                ? 'Try adjusting your search or filter.'
                : 'Why not create the first one?',
            style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!isSearchOrFilterActive)
            CustomButton(text: 'Create Community', icon: Icons.add, onPressed: _navigateToCreateCommunity, type: ButtonType.primary),
        ],
      ),
    );
  }

  Widget _buildErrorUI(Object? error) {
    return Center(
        child: Padding( // Add padding around the error card
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: CustomCard(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: ThemeConstants.errorColor, size: 48),
                  const SizedBox(height: ThemeConstants.smallPadding),
                  Text('Failed to load communities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: ThemeConstants.smallPadding),
                  Text(error.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: ThemeConstants.mediumPadding),
                  CustomButton(text: 'Retry', icon: Icons.refresh, onPressed: _triggerCommunityLoad, type: ButtonType.primary),
                ],
              ),
            ),
          ),
        )
    );
  }
}