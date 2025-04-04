// frontend/lib/screens/replies_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../widgets/reply_card.dart';
import 'create_reply_screen.dart';
import '../theme/theme_constants.dart';
import 'package:intl/intl.dart'; // For date formatting

// Helper data structure for replies hierarchy
class ReplyNode {
  final Map<String, dynamic> data;
  final List<ReplyNode> children;
  bool isExpanded; // State for expanding/collapsing children

  ReplyNode(this.data, {this.children = const [], this.isExpanded = true}); // Default to expanded
}

class RepliesScreen extends StatefulWidget {
  final String postId;
  final String? postTitle;

  const RepliesScreen({
    required this.postId,
    this.postTitle,
    Key? key
  }) : super(key: key);

  @override
  _RepliesScreenState createState() => _RepliesScreenState();
}

class _RepliesScreenState extends State<RepliesScreen> {

  Future<List<ReplyNode>>? _loadRepliesFuture;
  // State map for vote status on replies: Key: replyId (String), Value: Map<String, dynamic>
  final Map<String, Map<String, dynamic>> _replyVoteData = {};

  @override
  void initState() {
    super.initState();
    _triggerLoadReplies();
  }

  void _triggerLoadReplies() {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _loadRepliesFuture = _fetchAndStructureReplies(apiService, authProvider.token);
    });
  }

  Future<List<ReplyNode>> _fetchAndStructureReplies(ApiService apiService, String? token) async {
    final flatReplies = await apiService.fetchReplies(widget.postId, token);

    // Initialize vote data for fetched replies
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bool needsUiUpdate = false;
        for (var reply in flatReplies) {
          final replyId = reply['id'].toString();
          if (!_replyVoteData.containsKey(replyId)) {
            _replyVoteData[replyId] = {
              'vote_type': null, // TODO: Fetch user's vote status for reply
              'upvotes': reply['upvotes'] ?? 0,
              'downvotes': reply['downvotes'] ?? 0,
            };
            needsUiUpdate = true;
          } else {
            // Update counts if they differ
            if (_replyVoteData[replyId]!['upvotes'] != (reply['upvotes'] ?? 0) ||
                _replyVoteData[replyId]!['downvotes'] != (reply['downvotes'] ?? 0)) {
              _replyVoteData[replyId]!['upvotes'] = reply['upvotes'] ?? 0;
              _replyVoteData[replyId]!['downvotes'] = reply['downvotes'] ?? 0;
              needsUiUpdate = true;
            }
          }
        }
        if (needsUiUpdate && mounted) {
          setState(() {});
        }
      });
    }


    final Map<int?, List<Map<String, dynamic>>> repliesByParentId = {};
    for (var reply in flatReplies) {
      final parentId = reply['parent_reply_id'] as int?;
      repliesByParentId.putIfAbsent(parentId, () => []).add(reply);
    }

    List<ReplyNode> buildTree(int? parentId) {
      if (!repliesByParentId.containsKey(parentId)) {
        return [];
      }
      // Sort replies by creation time before building the tree
      repliesByParentId[parentId]!.sort((a, b) {
        DateTime timeA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        DateTime timeB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return timeA.compareTo(timeB); // Ascending order
      });

      return repliesByParentId[parentId]!.map((replyData) {
        final children = buildTree(replyData['id'] as int?);
        return ReplyNode(replyData, children: children);
      }).toList();
    }

    return buildTree(null); // Start from top-level replies
  }


  void _navigateToAddReply(BuildContext context, {String? parentReplyId, String? parentContent}) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to reply.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateReplyScreen(
            postId: widget.postId,
            parentReplyId: parentReplyId,
            parentReplyContent: parentContent,
          )),
    ).then((_) => _triggerLoadReplies()); // Refresh replies after returning
  }

  Future<void> _deleteReply(String replyId) async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply?'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: ThemeConstants.errorColor))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deleteReply(replyId, authProvider.token!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply deleted'), duration: Duration(seconds: 1)));
        _triggerLoadReplies(); // Refresh replies
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting reply: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor));
      }
    }
  }

  Future<void> _voteOnReply(String replyId, bool voteType) async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to vote.')));
      return;
    }

    final currentVoteData = _replyVoteData[replyId] ?? {'vote_type': null, 'upvotes': 0, 'downvotes': 0};
    final previousVoteType = currentVoteData['vote_type'] as bool?;
    final currentUpvotes = currentVoteData['upvotes'] as int? ?? 0;
    final currentDownvotes = currentVoteData['downvotes'] as int? ?? 0;

    // Optimistic UI Update
    setState(() {
      final newData = Map<String, dynamic>.from(currentVoteData);
      int newUpvotes = currentUpvotes;
      int newDownvotes = currentDownvotes;

      if (previousVoteType == voteType) { // Undoing vote
        newData['vote_type'] = null;
        if (voteType == true) newUpvotes--; else newDownvotes--;
      } else { // Casting or switching vote
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
      _replyVoteData[replyId] = newData;
    });

    try {
      await apiService.vote(replyId: int.parse(replyId), voteType: voteType, token: authProvider.token!);
      // Optional: Update counts from API response for eventual consistency
      // _triggerLoadReplies(); // Simple refresh for now
    } catch (e) {
      if (!mounted) return;
      // Revert UI
      setState(() {
        final revertedData = Map<String, dynamic>.from(currentVoteData);
        revertedData['vote_type'] = previousVoteType;
        revertedData['upvotes'] = currentUpvotes;
        revertedData['downvotes'] = currentDownvotes;
        _replyVoteData[replyId] = revertedData;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vote failed: ${e.toString()}'), backgroundColor: ThemeConstants.errorColor));
    }
  }

  // Format DateTime string
  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) return '${difference.inSeconds}s';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m';
      if (difference.inHours < 24) return '${difference.inHours}h';
      if (difference.inDays < 7) return '${difference.inDays}d';
      return DateFormat('MMM d').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Listen for auth changes

    return Scaffold(
      appBar: AppBar(title: Text(widget.postTitle ?? "Replies")),
      body: RefreshIndicator(
        onRefresh: () async => _triggerLoadReplies(),
        child: FutureBuilder<List<ReplyNode>>(
          future: _loadRepliesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading replies: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Column( // Provide context and action
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.comment_outlined, size: 50, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No replies yet.'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _navigateToAddReply(context),
                        child: const Text('Be the first to reply!'),
                      ),
                    ],
                  )
              );
            }

            final structuredReplies = snapshot.data!;

            // Function to recursively build the list view items
            List<Widget> buildReplyWidgets(List<ReplyNode> nodes, int level) {
              List<Widget> widgets = [];
              for (var node in nodes) {
                final reply = node.data;
                final replyId = reply['id'].toString();
                final isOwner = authProvider.isAuthenticated &&
                    authProvider.userId != null &&
                    reply['user_id'].toString() == authProvider.userId;

                // Get vote data from state map
                final voteData = _replyVoteData[replyId] ?? {'vote_type': null, 'upvotes': reply['upvotes'] ?? 0, 'downvotes': reply['downvotes'] ?? 0};
                final bool hasUpvoted = voteData['vote_type'] == true;
                final bool hasDownvoted = voteData['vote_type'] == false;
                final int displayUpvotes = voteData['upvotes'];
                final int displayDownvotes = voteData['downvotes'];

                widgets.add(
                  Padding(
                    padding: EdgeInsets.only(bottom: level > 0 ? 2 : 8.0, top: level > 0 ? 2 : 0), // Compact vertical spacing for nested
                    child: ReplyCard(
                      content: reply['content'] ?? '...',
                      authorName: reply['author_name'] ?? 'Anonymous',
                      authorAvatar: reply['author_avatar'], // Pass avatar URL/path
                      timeAgo: _formatTimeAgo(reply['created_at']),
                      upvotes: displayUpvotes,
                      downvotes: displayDownvotes,
                      isOwner: isOwner,
                      hasUpvoted: hasUpvoted,
                      hasDownvoted: hasDownvoted,
                      indentLevel: level,
                      onReply: () => _navigateToAddReply(
                        context,
                        parentReplyId: replyId,
                        parentContent: reply['content'],
                      ),
                      onDelete: isOwner ? () => _deleteReply(replyId) : null,
                      onUpvote: () => _voteOnReply(replyId, true),
                      onDownvote: () => _voteOnReply(replyId, false),
                    ),
                  ),
                );
                // Recursively add children if the node is expanded (if expansion is implemented)
                // if (node.isExpanded) {
                widgets.addAll(buildReplyWidgets(node.children, level + 1));
                // }
              }
              return widgets;
            }

            return ListView(
              padding: const EdgeInsets.all(8),
              children: buildReplyWidgets(structuredReplies, 0), // Start rendering from level 0
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddReply(context), // Add top-level reply
        child: const Icon(Icons.add_comment),
        tooltip: "Add Reply",
        backgroundColor: ThemeConstants.accentColor,
        foregroundColor: ThemeConstants.primaryColor,
      ),
    );
  }
}