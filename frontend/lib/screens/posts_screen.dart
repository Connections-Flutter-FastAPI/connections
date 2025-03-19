// screens/posts_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import 'create_post_screen.dart';
import 'replies_screen.dart';

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // Use a map to track voted status for each post.  This is more robust.
  final Map<String, bool?> _votedStatus = {}; // {postId: voteType}  null = no vote, true = upvote, false = downvote

  Future<void> _voteOnPost(ApiService apiService, AuthProvider authProvider, String postId, bool voteType) async {
    // Early return if not authenticated
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to vote.')));
      return;
    }

      // Optimistic UI update.  Assume the vote will succeed.
    final previousVote = _votedStatus[postId];
    setState(() {
      // If already voted the same way, remove the vote.  Otherwise, set the new vote.
      _votedStatus[postId] = (previousVote == voteType) ? null : voteType;
    });
    try {
      await apiService.vote(postId, null, voteType, authProvider.token!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vote recorded!")));
    } catch (e) {
      // If the vote failed, revert the UI.
      setState(() {
        _votedStatus[postId] = previousVote;
      });
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

    void _navigateToReplies(String postId, String? token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RepliesScreen(postId: postId)),
    );
  }


  void _navigateToCreatePost(BuildContext context) async {
    // Use context.read to get the services *without* listening for changes.
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('You must be logged in to create a post.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen()),
    ).then((_) {
      // Refresh posts after returning from CreatePostScreen
      setState(() {}); // Triggers a rebuild of PostsScreen
    });
  }

    Future<void> _deletePost(String postId, ApiService apiService, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to delete posts.')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deletePost(postId, authProvider.token!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted successfully.')));
        setState(() {}); // Refresh posts after deleting
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting post: ${e.toString()}')));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: RefreshIndicator( // Add RefreshIndicator
        onRefresh: () async {
          setState(() {}); // Just trigger a rebuild
        },
        child: Consumer<AuthProvider>( // Use a Consumer for AuthProvider
          builder: (context, auth, _) => FutureBuilder<List<dynamic>>(
            future: apiService.fetchPosts(auth.token),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final posts = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final postId = post['id'].toString();
                  final hasUpvoted = _votedStatus[postId] == true;
                  final hasDownvoted = _votedStatus[postId] == false;
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(post['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(post['content'] ?? 'No Content'),
                      ),
                       trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined, color: hasUpvoted? Colors.blue : Colors.grey),
                            onPressed: () => _voteOnPost(apiService, authProvider, postId, true),
                          ),
                          IconButton(
                            icon: Icon(hasDownvoted ? Icons.thumb_down : Icons.thumb_down_outlined, color: hasDownvoted ? Colors.red : Colors.grey),
                            onPressed: () => _voteOnPost(apiService, authProvider, postId, false),
                          ),
                           IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () => _navigateToReplies(postId, authProvider.token),
                          ),
                          if (authProvider.isAuthenticated && authProvider.userId == post['user_id'].toString())
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deletePost(postId, apiService, authProvider),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreatePost(context), // Pass context
        child: const Icon(Icons.add),
        tooltip: "Create Post",
      ),
    );
  }
}