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
  // Keep page state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  // Search query
  String _searchQuery = '';

  // Joined communities map
  final Map<String, bool> _joinedCommunities = {};

  // Selected category filter
  String? _selectedCategory;

  // Category tabs
  final List<Map<String, dynamic>> _categoryTabs = [
    {'id': 'all', 'label': 'All', 'icon': Icons.public},
    {'id': 'gaming', 'label': 'Gaming', 'icon': Icons.sports_esports},
    {'id': 'tech', 'label': 'Tech', 'icon': Icons.code},
    {'id': 'music', 'label': 'Music', 'icon': Icons.music_note},
    {'id': 'art', 'label': 'Art', 'icon': Icons.palette},
    {'id': 'science', 'label': 'Science', 'icon': Icons.science},
    {'id': 'sports', 'label': 'Sports', 'icon': Icons.sports_soccer},
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
  ];

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _navigateToCreateCommunity(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a community.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCommunityScreen()),
    ).then((_) {
      setState(() {}); // Refresh communities after returning
    });
  }

  Future<void> _toggleJoinCommunity(
      String communityId,
      bool isJoined,
      ApiService apiService,
      AuthProvider authProvider
      ) async {
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to join communities.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Optimistic UI update
    setState(() {
      _joinedCommunities[communityId] = !isJoined;
    });

    try {
      if (isJoined) {
        await apiService.leaveCommunity(communityId, authProvider.token!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You left the community'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await apiService.joinCommunity(communityId, authProvider.token!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You joined the community'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Revert UI if operation failed
      setState(() {
        _joinedCommunities[communityId] = isJoined;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ThemeConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of community colors
    final communityColors = ThemeConstants.communityColors;

    return Scaffold(
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Category tabs
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categoryTabs.length,
              padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.smallPadding),
              itemBuilder: (context, index) {
                final category = _categoryTabs[index];
                final isSelected = _selectedCategory == category['id'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = isSelected ? null : category['id'] as String;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        // Circle Avatar
                        AnimatedContainer(
                          duration: ThemeConstants.shortAnimation,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ThemeConstants.primaryColor
                                : (isDark ? ThemeConstants.backgroundDark : Colors.grey.shade200),
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: ThemeConstants.primaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                                : null,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Icon(
                            category['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
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
              onRefresh: () async {
                setState(() {});
              },
              child: FutureBuilder<List<dynamic>>(
                future: apiService.fetchCommunities(authProvider.token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingShimmer();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: CustomCard(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: ThemeConstants.errorColor,
                                size: 48,
                              ),
                              const SizedBox(height: ThemeConstants.smallPadding),
                              Text('Error: ${snapshot.error}'),
                              const SizedBox(height: ThemeConstants.mediumPadding),
                              CustomButton(
                                text: 'Retry',
                                icon: Icons.refresh,
                                onPressed: () => setState(() {}),
                                type: ButtonType.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Filter communities based on search query and selected category
                  var communities = snapshot.data!.where((comm) {
                    final name = comm['name'].toString().toLowerCase();
                    final description = (comm['description'] ?? '').toString().toLowerCase();
                    final matchesSearch = name.contains(_searchQuery) ||
                        description.contains(_searchQuery);

                    // Filter by category if one is selected
                    if (_selectedCategory != null && _selectedCategory != 'all') {
                      // Note: This is a simplified example, in a real app you would
                      // want to match against actual category data from the API
                      final categoryName = _selectedCategory!.toLowerCase();
                      final matchesCategory =
                          name.contains(categoryName) ||
                              description.contains(categoryName);

                      return matchesSearch && matchesCategory;
                    }

                    return matchesSearch;
                  }).toList();

                  if (communities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No communities found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Start by creating a new community!',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (_searchQuery.isEmpty)
                            CustomButton(
                              text: 'Create Community',
                              icon: Icons.add,
                              onPressed: () => _navigateToCreateCommunity(context),
                              type: ButtonType.primary,
                            ),
                        ],
                      ),
                    );
                  }

                  // Grid view for communities
                  return GridView.builder(
                    padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: ThemeConstants.mediumPadding,
                      mainAxisSpacing: ThemeConstants.mediumPadding,
                    ),
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      final community = communities[index];
                      final communityId = community['id'].toString();

                      // Get or default to not joined
                      final isJoined = _joinedCommunities[communityId] ??
                          (community['is_member'] as bool? ?? false);

                      // Get consistent color for community
                      final color = communityColors[index % communityColors.length];

                      return CommunityCard(
                        name: community['name'] ?? 'No Name',
                        description: community['description'] ?? 'No Description',
                        memberCount: community['members'] ?? 0,
                        onlineCount: community['online_members'] ?? 0,
                        backgroundColor: color,
                        location: community['primary_location'],
                        isJoined: isJoined,
                        onJoin: () => _toggleJoinCommunity(
                            communityId,
                            isJoined,
                            apiService,
                            authProvider
                        ),
                        onTap: () {
                          // Navigate to community detail screen
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

      // Create Community Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCommunity(context),
        child: const Icon(Icons.add),
        tooltip: "Create Community",
      ),
    );
  }

  Widget _buildLoadingShimmer() {
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
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
          ),
        ),
      ),
    );
  }
}
