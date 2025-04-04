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
  
  bool _isLoading = false;
  String? _selectedInterest; // Stores selected interest

  // List of allowed interests (from database)
  final List<String> _interests = [
    "Gaming",
    "Tech",
    "Science",
    "Music",
    "Sports",
    "College Event",
    "Activities",
    "Social",
    "Other"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _createCommunity(ApiService apiService, AuthProvider authProvider, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String formattedLocation = _locationController.text; // Ensure valid format
        if (!formattedLocation.startsWith('(') || !formattedLocation.endsWith(')')) {
           formattedLocation = '(0,0)'; // Default value
        }

        await apiService.createCommunity(
          _nameController.text,
          _descriptionController.text.isNotEmpty ? _descriptionController.text : null, 
          formattedLocation, 
          _selectedInterest ?? "Other", // Send selected interest or default to "Other"
          authProvider.token!,
        );
        if (mounted) {
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
          child: ListView(
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
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location (lon,lat)' : null,
              ),
              const SizedBox(height: 16),
              
              // Dropdown for Interests
              DropdownButtonFormField<String>(
                value: _selectedInterest,
                decoration: const InputDecoration(labelText: 'Interest / Category *'),
                items: _interests.map((String interest) {
                  return DropdownMenuItem<String>(
                    value: interest,
                    child: Text(interest),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedInterest = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select an interest' : null,
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