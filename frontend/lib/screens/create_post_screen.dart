// screens/create_post_screen.dart (Completed)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedCommunityId; // Store selected community ID
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createPost(
      ApiService apiService, AuthProvider authProvider, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await apiService.createPost(
          _titleController.text,
          _contentController.text,
          _selectedCommunityId, // Pass the selected community ID
          authProvider.token!,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Post created successfully!')));
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error creating post: ${e.toString()}')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter some content' : null,
              ),
              const SizedBox(height: 20),
              // Use FutureBuilder to fetch the community and show them in dropdown
              FutureBuilder<List<dynamic>>(
                future: apiService.fetchCommunities(authProvider.token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final communities = snapshot.data!;

                  return DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(labelText: 'Select Community (Optional)'),
                    value: _selectedCommunityId,
                    items: [
                      const DropdownMenuItem(
                        value: null, // Represents no community selected
                        child: Text('No Community'),
                      ),
                      ...communities.map((community) {
                        return DropdownMenuItem<int?>(
                          value: community['id'],
                          child: Text(community['name']),
                        );
                      }).toList(),
                    ],
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedCommunityId = newValue;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _createPost(apiService, authProvider, context),
                      child: const Text("Create Post"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}