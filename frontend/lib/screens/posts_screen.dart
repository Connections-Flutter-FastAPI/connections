import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import '../theme/theme_constants.dart';
import 'create_post_screen.dart';
import 'replies_screen.dart';
import 'dart:math' as math; // For random colors

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with AutomaticKeepAliveClientMixin {
  // Keep page state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  // Map to track voted status for each post
  final Map<String, bool?> _votedStatus = {};

  // Selected filter
  String _selectedFilter = 'all';

  // Tabs for filtering posts
  final List<Map<String, dynamic>> _filterTabs = [
    {'id': 'all', 'label': 'All', 'icon': Icons.public},
    {'id': 'following', 'label': 'Following', 'icon': Icons.favorite},
    {'id': 'trending', 'label': 'Trending', 'icon': Icons.trending_up},
    {'id': 'latest', 'label': 'Latest', 'icon': Icons.new_releases},
  ];

  Future<void> _voteOnPost(ApiService apiService, AuthProvider authProvider, String postId, bool voteType) async {
    // Early return if not authenticated
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to vote.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Optimistic UI update
    final previousVote = _votedStatus[postId];
    setState(() {
      // If already voted the same way, remove the vote
      _votedStatus[postId] = (previousVote == voteType) ? null : voteType;
    });

    try {
      await apiService.vote(postId, null, voteType, authProvider.token!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vote recorded!"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Revert UI if operation failed
      setState(() {
        _votedStatus[postId] = previousVote;
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

  void _navigateToReplies(String postId, String? token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RepliesScreen(postId: postId)),
    );
  }

  void _navigateToCreatePost(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a post.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen()),
    ).then((_) {
      // Refresh posts after returning
      setState(() {});
    });
  }

  Future<void> _deletePost(String postId, ApiService apiService, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to delete posts.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: ThemeConstants.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deletePost(postId, authProvider.token!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {}); // Refresh posts after deleting
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ThemeConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of community colors for consistent assignment
    final communityColors = ThemeConstants.communityColors;

    // Generate a random time ago string (for UI demo only)
    final random = math.Random();
    String getRandomTimeAgo() {
      final options = ['Just now', '5m ago', '15m ago', '1h ago', '3h ago', 'Yesterday'];
      return options[random.nextInt(options.length)];
    }

    return Scaffold(
      body: Column(
        children: [
          // Filter tabs at the top
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterTabs.length,
              padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.smallPadding),
              itemBuilder: (context, index) {
                final filter = _filterTabs[index];
                final isSelected = _selectedFilter == filter['id'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter['id'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? ThemeConstants.primaryColor : ThemeConstants.primaryColor)
                          : (isDark ? ThemeConstants.backgroundDarkest : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: ThemeConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filter['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Posts list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) => FutureBuilder<List<dynamic>>(
                  future: apiService.fetchPosts(auth.token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show shimmer loading effect
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

                    final posts = snapshot.data!;

                    if (posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share something!',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Create Post',
                              icon: Icons.add,
                              onPressed: () => _navigateToCreatePost(context),
                              type: ButtonType.primary,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final postId = post['id'].toString();
                        final hasUpvoted = _votedStatus[postId] == true;
                        final hasDownvoted = _votedStatus[postId] == false;

                        // Get consistent color for community
                        final communityName = post['community_name'] as String?;
                        final communityColor = communityName != null
                            ? communityColors[communityName.hashCode % communityColors.length]
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
                          child: PostCard(
                            title: post['title'] ?? 'No Title',
                            content: post['content'] ?? 'No Content',
                            authorName: post['author_name'] ?? 'Anonymous',
                            authorAvatar: post['author_avatar'] ?? null,
                            timeAgo: getRandomTimeAgo(), // This would be from API in real app
                            upvotes: post['upvotes'] ?? 0,
                            downvotes: post['downvotes'] ?? 0,
                            replyCount: post['reply_count'] ?? 0,
                            hasUpvoted: hasUpvoted,
                            hasDownvoted: hasDownvoted,
                            isOwner: authProvider.isAuthenticated &&
                                authProvider.userId == post['user_id'].toString(),
                            communityName: communityName,
                            communityColor: communityColor,
                            onUpvote: () => _voteOnPost(
                                apiService,
                                authProvider,
                                postId,
                                true
                            ),
                            onDownvote: () => _voteOnPost(
                                apiService,
                                authProvider,
                                postId,
                                false
                            ),
                            onReply: () => _navigateToReplies(
                                postId,
                                authProvider.token
                            ),
                            onDelete: () => _deletePost(
                                postId,
                                apiService,
                                authProvider
                            ),
                            onTap: () => _navigateToReplies(
                                postId,
                                authProvider.token
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreatePost(context),
        child: const Icon(Icons.add),
        tooltip: "Create Post",
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
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
