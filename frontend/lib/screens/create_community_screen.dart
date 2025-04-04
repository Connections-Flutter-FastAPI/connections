// screens/create_community_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  _CreateCommunityScreenState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _interestController = TextEditingController(); // Added controller for interest
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _interestController.dispose(); // Dispose new controller
    super.dispose();
  }

  void _createCommunity(ApiService apiService, AuthProvider authProvider, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Ensure location is in POINT format for backend, e.g., '(lon,lat)'
        // You might need a map picker or separate lat/lon fields for better UX
        String formattedLocation = _locationController.text; // Assuming user inputs '(lon,lat)' for now
        if (!formattedLocation.startsWith('(') || !formattedLocation.endsWith(')')) {
           // Basic validation or formatting helper needed here
           formattedLocation = '(0,0)'; // Default if format is wrong
        }

        await apiService.createCommunity(
          _nameController.text,
          _descriptionController.text.isNotEmpty ? _descriptionController.text : null, // Send null if empty
          formattedLocation, // Send formatted location string
          _interestController.text.isNotEmpty ? _interestController.text : null, // Send interest or null
          authProvider.token!,
        );
        if (mounted) { // Check if mounted before showing SnackBar/popping
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Community created successfully!')));
          Navigator.pop(context);
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create community: ${e.toString()}')));
         }
      } finally {
         if (mounted) {
           setState(() => _isLoading = false);
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Use ListView for scrollability
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                 maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location *', hintText: 'e.g., (77.10, 28.70)'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location (lon,lat)' : null, // Add better validation later
              ),
              const SizedBox(height: 16),
               TextFormField( // Added field for interest
                 controller: _interestController,
                 decoration: const InputDecoration(labelText: 'Interest / Category'),
               ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _createCommunity(apiService, authProvider, context),
                      child: const Text('Create Community'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}