// screens/create_reply_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../theme/theme_constants.dart'; // For styling

class CreateReplyScreen extends StatefulWidget {
  final String postId;
  final String? parentReplyId; // Optional ID of the reply being replied to
  final String? parentReplyContent; // Optional content for context

  const CreateReplyScreen({
    required this.postId,
    this.parentReplyId,
    this.parentReplyContent,
    Key? key
  }) : super(key: key);

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
        // Convert IDs to int for the API call
        final postIdInt = int.tryParse(widget.postId);
        final parentReplyIdInt = widget.parentReplyId != null ? int.tryParse(widget.parentReplyId!) : null;

        if (postIdInt == null) {
           throw Exception("Invalid Post ID format");
        }

        await apiService.createReply(
          postIdInt,
          _replyController.text,
          parentReplyIdInt, // Pass the parent ID (as int or null)
          authProvider.token!,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Reply created successfully!')));
        Navigator.pop(context); // Go back
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(widget.parentReplyId == null ? "Add Reply" : "Reply To...")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show parent reply content if replying to a specific reply
              if (widget.parentReplyContent != null) ...[
                 Text(
                   'Replying to:',
                   style: TextStyle(
                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                     fontWeight: FontWeight.bold
                   ),
                 ),
                 const SizedBox(height: 8),
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: isDark ? ThemeConstants.backgroundDarker : Colors.grey.shade100,
                     borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                     border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                   ),
                   child: Text(
                     widget.parentReplyContent!,
                     style: TextStyle(
                       fontStyle: FontStyle.italic,
                       color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                     ),
                     maxLines: 3,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(height: 20),
              ],

              TextFormField(
                controller: _replyController,
                decoration: const InputDecoration(labelText: 'Your Reply'),
                maxLines: 5, // Allow more lines for replies
                minLines: 3,
                autofocus: true, // Focus the field immediately
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your reply' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox( // Ensure button takes full width
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _createReply(apiService, authProvider, context),
                        child: const Text("Submit Reply"),
                      ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}