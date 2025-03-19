// screens/create_reply_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class CreateReplyScreen extends StatefulWidget {
  final String postId;
  const CreateReplyScreen({required this.postId, Key? key}) : super(key: key);

  @override
  _CreateReplyScreenState createState() => _CreateReplyScreenState();
}

class _CreateReplyScreenState extends State<CreateReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _replyController = TextEditingController();
  bool _isLoading = false;

    @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _createReply(
      ApiService apiService, AuthProvider authProvider, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await apiService.createReply(
          widget.postId,
          _replyController.text,
          null, // parentReplyId is null for top-level replies
          authProvider.token!,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Reply created successfully!')));
        Navigator.pop(context); // Go back to the replies screen
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error creating reply: ${e.toString()}')));
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
      appBar: AppBar(title: const Text("Add Reply")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _replyController,
                decoration: const InputDecoration(labelText: 'Your Reply'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your reply' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _createReply(apiService, authProvider, context),
                      child: const Text("Submit Reply"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}