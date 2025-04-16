// frontend/lib/screens/posts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/custom_card.dart'; // Keep if used for error/empty states
import '../widgets/custom_button.dart'; // Keep if used for error/empty states
import '../theme/theme_constants.dart';
import 'create_post_screen.dart';
import 'replies_screen.dart';
import 'dart:math' as math; // For random colors/time ago
import 'package:intl/intl.dart'; // For date formatting

class PostsScreen extends StatefulWidget {
  final int? communityId; // Optional community ID to filter posts
  final String? communityName; // Optional name to display in AppBar

  const PostsScreen({
    Key? key,
    this.communityId,
    this.communityName
  }) : super(key: key);

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Map to track VOTE DATA for each post
  // Key: postId (String), Value: Map {'vote_type': bool?, 'upvotes': int, 'downvotes': int}
  final Map<String, Map<String, dynamic>> _postVoteData = {};

  String _selectedFilter = 'all'; // Default filter
  Future<List<dynamic>>? _loadPostsFuture;

  final List<Map<String, dynamic>> _filterTabs = [
    {'id': 'all', 'label': 'All', 'icon': Icons.public},
    {'id': 'trending', 'label': 'Trending', 'icon': Icons.trending_up},
    // {'id': 'following', 'label': 'Following', 'icon': Icons.favorite}, // Requires backend support
    {'id': 'latest', 'label': 'Latest', 'icon': Icons.new_releases}, // Handled by 'all' endpoint sorting
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _triggerPostLoad();
      }
    });
  }

  void _triggerPostLoad() {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      if (_selectedFilter == 'trending') {
        _loadPostsFuture = apiService.fetchTrendingPosts(authProvider.token);
        // Note: Trending endpoint might not support communityId filtering. Adjust if needed.
      } else {
        // 'all' and 'latest' use the default fetchPosts endpoint
        _loadPostsFuture = apiService.fetchPosts(authProvider.token, communityId: widget.communityId);
      }
    });
  }

  // --- Actions ---
  Future<void> _voteOnPost(String postId, bool voteType) async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to vote.')),
      );
      return;
    }

    final currentVoteData = _postVoteData[postId] ?? {'vote_type': null, 'upvotes': 0, 'downvotes': 0};
    final previousVoteType = currentVoteData['vote_type'] as bool?; // Explicit cast
    final currentUpvotes = currentVoteData['upvotes'] as int? ?? 0;
    final currentDownvotes = currentVoteData['downvotes'] as int? ?? 0;

    // Optimistic UI update
    setState(() {
      final newData = Map<String, dynamic>.from(currentVoteData);
      int newUpvotes = currentUpvotes;
      int newDownvotes = currentDownvotes;

      if (previousVoteType == voteType) { // Undoing vote
        newData['vote_type'] = null;
        if (voteType == true) newUpvotes--;
        else newDownvotes--;
      } else { // Casting new vote or switching vote
        newData['vote_type'] = voteType;
        if (voteType == true) { // Upvoting
          newUpvotes++;
          if (previousVoteType == false) newDownvotes--;
        } else { // Downvoting
          newDownvotes++;
          if (previousVoteType == true) newUpvotes--;
        }
      }
      newData['upvotes'] = newUpvotes < 0 ? 0 : newUpvotes;
      newData['downvotes'] = newDownvotes < 0 ? 0 : newDownvotes;
      _postVoteData[postId] = newData;
    });

    try {
      // API call uses int for postId
      await apiService.vote(postId: int.parse(postId), voteType: voteType, token: authProvider.token!);
      // Optional: Re-fetch posts or update counts from API response if needed for consistency
      // _triggerPostLoad(); // Simple refresh (can be slow)
    } catch (e) {
      if (!mounted) return;
      // Revert UI on error
      setState(() {
        final revertedData = Map<String, dynamic>.from(currentVoteData);
        revertedData['vote_type'] = previousVoteType;
        revertedData['upvotes'] = currentUpvotes;
        revertedData['downvotes'] = currentDownvotes;
        _postVoteData[postId] = revertedData;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote failed: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor));
    }
  }

  void _navigateToReplies(String postId, String? postTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RepliesScreen(postId: postId, postTitle: postTitle)),
    );
  }

  void _navigateToCreatePost() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create posts.')),
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen()),
    );
    // Refresh list if a post might have been created
    if (mounted) {
      _triggerPostLoad();
    }
  }

  Future<void> _deletePost(String postId) async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: ThemeConstants.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deletePost(postId, authProvider.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully'), duration: Duration(seconds: 1)));
        _triggerPostLoad(); // Refresh list
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting post: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor));
      }
    }
  }

  // Format DateTime string
  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return DateFormat('MMM d, yyyy').format(dateTime); // Older than a week
    } catch (e) {
      return ''; // Return empty string on parsing error
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep state

    final authProvider = Provider.of<AuthProvider>(context); // Use listener for auth state changes
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final communityColors = ThemeConstants.communityColors;

    return Scaffold(
      // Add AppBar only if it's a detail screen (e.g., showing posts for a specific community)
      appBar: widget.communityId != null ? AppBar(title: Text(widget.communityName ?? 'Community Posts')) : null,
      body: Column(
        children: [
          // Filter tabs (Only show if not already filtered by communityId)
          if (widget.communityId == null)
            Container(
              height: 50,
              color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterTabs.length,
                padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.smallPadding, vertical: 8),
                itemBuilder: (context, index) {
                  final filter = _filterTabs[index];
                  final isSelected = _selectedFilter == filter['id'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(filter['label']),
                      avatar: Icon(filter['icon'], size: 16, color: isSelected ? ThemeConstants.primaryColor : (isDark ? Colors.white70 : Colors.black54)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected && _selectedFilter != filter['id']) {
                          setState(() { _selectedFilter = filter['id'] as String; });
                          _triggerPostLoad();
                        }
                      },
                      selectedColor: ThemeConstants.accentColor,
                      backgroundColor: isDark ? ThemeConstants.backgroundDark : Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? ThemeConstants.primaryColor : (isDark ? Colors.white : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  );
                },
              ),
            ),

          // Posts list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _triggerPostLoad(),
              child: FutureBuilder<List<dynamic>>(
                future: _loadPostsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ) {
                    return _buildLoadingShimmer();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorUI(snapshot.error, isDark);
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyUI(isDark, filter: _selectedFilter, communityName: widget.communityName);
                  }

                  final posts = snapshot.data!;

                  // Initialize/Update vote data after fetch completes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    bool needsUiUpdate = false;
                    for (var post in posts) {
                      final postId = post['id'].toString();
                      final fetchedUpvotes = post['upvotes'] ?? 0;
                      final fetchedDownvotes = post['downvotes'] ?? 0;

                      if (!_postVoteData.containsKey(postId)) {
                        _postVoteData[postId] = {
                          'vote_type': null, // TODO: Fetch actual user vote status if possible
                          'upvotes': fetchedUpvotes,
                          'downvotes': fetchedDownvotes,
                        };
                        needsUiUpdate = true;
                      } else {
                        // Update counts if they differ from fetched data (e.g., after refresh)
                        if (_postVoteData[postId]!['upvotes'] != fetchedUpvotes ||
                            _postVoteData[postId]!['downvotes'] != fetchedDownvotes) {
                          // Only update counts, preserve user's vote_type state
                          _postVoteData[postId]!['upvotes'] = fetchedUpvotes;
                          _postVoteData[postId]!['downvotes'] = fetchedDownvotes;
                          needsUiUpdate = true;
                        }
                      }
                    }
                    // Trigger rebuild only if data was actually updated
                    if (needsUiUpdate && mounted) {
                      setState(() {});
                    }
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final postId = post['id'].toString();

                      // Get vote data safely from the state map
                      final voteData = _postVoteData[postId] ?? {'vote_type': null, 'upvotes': post['upvotes'] ?? 0, 'downvotes': post['downvotes'] ?? 0};
                      final bool hasUpvoted = voteData['vote_type'] == true;
                      final bool hasDownvoted = voteData['vote_type'] == false;
                      final int displayUpvotes = voteData['upvotes'];
                      final int displayDownvotes = voteData['downvotes'];

                      final communityName = post['community_name'] as String?;
                      final Color? communityColor = communityName != null
                          ? communityColors[post['community_id'].hashCode % communityColors.length]
                          : null;

                      final bool isPostOwner = authProvider.isAuthenticated &&
                          authProvider.userId != null &&
                          post['user_id'].toString() == authProvider.userId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
                        child: PostCard(
                          title: post['title'] ?? 'No Title',
                          content: post['content'] ?? 'No Content',
                          authorName: post['author_name'] ?? 'Anonymous',
                          // Construct full image URL if backend only provides path
                          // Example: Assume image_path is relative path like "user_images/username_uuid.jpg"
                          // authorAvatar: post['author_avatar'] != null ? '${AppConstants.baseUrl}/${post['author_avatar']}' : null,
                          authorAvatar: post['author_avatar'], // Use as is if backend gives full URL or null
                          timeAgo: _formatTimeAgo(post['created_at']),
                          upvotes: displayUpvotes,
                          downvotes: displayDownvotes,
                          replyCount: post['reply_count'] ?? 0,
                          hasUpvoted: hasUpvoted,
                          hasDownvoted: hasDownvoted,
                          isOwner: isPostOwner,
                          communityName: communityName,
                          communityColor: communityColor,
                          onUpvote: () => _voteOnPost(postId, true),
                          onDownvote: () => _voteOnPost(postId, false),
                          onReply: () => _navigateToReplies(postId, post['title']),
                          onDelete: isPostOwner ? () => _deletePost(postId) : null,
                          onTap: () => _navigateToReplies(postId, post['title']),
                        ),
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
        onPressed: _navigateToCreatePost,
        child: const Icon(Icons.add),
        tooltip: "Create Post",
        backgroundColor: ThemeConstants.accentColor,
        foregroundColor: ThemeConstants.primaryColor,
      ),
    );
  }

  // --- Helper Build Methods ---
  Widget _buildLoadingShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        itemCount: 5, // Number of shimmer placeholders
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
          child: Container(
            height: 180, // Adjust height to match PostCard estimate
            decoration: BoxDecoration(
              color: Colors.white, // Base color for shimmer effect
              borderRadius: BorderRadius.circular(ThemeConstants.cardBorderRadius),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyUI(bool isDark, {String? filter, String? communityName}) {
    String message = communityName != null
        ? 'No posts found in "$communityName".'
        : 'No posts found for "$filter".';
    String suggestion = communityName != null
        ? 'Be the first to post here!'
        : 'Try changing the filter or create a new post!';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            suggestion,
            style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(text: 'Create Post', icon: Icons.add, onPressed: _navigateToCreatePost, type: ButtonType.primary),
        ],
      ),
    );
  }

  Widget _buildErrorUI(Object? error, bool isDark) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: CustomCard( // Use CustomCard for consistent styling
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: ThemeConstants.errorColor, size: 48),
                  const SizedBox(height: ThemeConstants.smallPadding),
                  Text('Failed to load posts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: ThemeConstants.smallPadding),
                  Text(error.toString(), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
                  const SizedBox(height: ThemeConstants.mediumPadding),
                  CustomButton(text: 'Retry', icon: Icons.refresh, onPressed: _triggerPostLoad, type: ButtonType.primary),
                ],
              ),
            ),
          ),
        )
    );
  }
}