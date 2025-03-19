// screens/replies_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import 'create_reply_screen.dart';

class RepliesScreen extends StatefulWidget {
  final String postId;
  const RepliesScreen({required this.postId, Key? key}) : super(key: key);

  @override
  _RepliesScreenState createState() => _RepliesScreenState();
}

class _RepliesScreenState extends State<RepliesScreen> {

  void _navigateToAddReply(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('You must be logged in to reply.')));
      return;
    }
      Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateReplyScreen(postId: widget.postId)),
    ).then((_) {
      setState(() {}); // Refresh replies after returning
    });
  }

  Future<void> _deleteReply(String replyId, ApiService apiService, AuthProvider authProvider) async {
      if (!authProvider.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to delete replies.')));
      return;
      }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await apiService.deleteReply(replyId, authProvider.token!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply deleted successfully.')));
        setState(() {}); // Refresh replies
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting reply: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Replies")),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchReplies(widget.postId, authProvider.token), // Pass token for consistency
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final replies = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: replies.length,
            itemBuilder: (context, index) {
              final reply = replies[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(reply['content'] ?? 'No Content'),
                  subtitle: Text('By User: ${reply['user_id']}'),
                  trailing: (authProvider.isAuthenticated && authProvider.userId == reply['user_id'].toString())
                  ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteReply(reply['id'].toString(), apiService, authProvider),
                   )
                  : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddReply(context),
        child: const Icon(Icons.add_comment),
        tooltip: "Add Reply",
      ),
    );
  }
}