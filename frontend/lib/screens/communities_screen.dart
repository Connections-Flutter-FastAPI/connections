// screens/communities_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import 'create_community_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  @override
  _CommunitiesScreenState createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {

  Future<void> _navigateToCreateCommunity(BuildContext context) async {
      final authProvider = context.read<AuthProvider>();
    if(!authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to create a community.')));
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateCommunityScreen()),
    ).then((_) {
      setState(() {}); // Refresh communities after returning
    });
  }
    Future<void> _deleteCommunity(String communityId, ApiService apiService, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to delete communities.')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this community?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await apiService.deleteCommunity(communityId, authProvider.token!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Community deleted successfully.')));
        setState(() {}); // Refresh communities after deleting
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting community: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Get AuthProvider

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
            setState(() {

            });
        },
        child: FutureBuilder<List<dynamic>>(
          future: apiService.fetchCommunities(authProvider.token), // Pass token
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final communities = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final comm = communities[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(comm['name'] ?? 'No Name',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(comm['description'] ?? 'No Description'),
                    ),
                    trailing: (authProvider.isAuthenticated && authProvider.userId == comm['created_by'].toString())
                    ? IconButton( // Add a trailing delete button
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCommunity(comm['id'].toString(), apiService, authProvider)
                      )
                    : null, // Don't show delete if not the creator
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCommunity(context),
        child: const Icon(Icons.add),
        tooltip: "Create Community",
      ),
    );
  }
}