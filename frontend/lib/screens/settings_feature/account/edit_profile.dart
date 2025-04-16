import 'package:flutter/material.dart';
import '/theme/theme_constants.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  // TODO: Add logic for profile picture selection and loading initial data

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement profile saving logic (API call, local storage, etc.)
      print('Saving profile...');
      print('Name: ${_nameController.text}');
      print('Username: ${_usernameController.text}');
      print('Email: ${_emailController.text}');
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Profile Updated (Simulated)'), backgroundColor: kCyan),
      );
      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepMidnightBlue,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: kLightText)),
        backgroundColor: kDeepMidnightBlue,
         iconTheme: const IconThemeData(color: kCyan),
        elevation: 1, // Slight elevation for separation
         actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: kHighlightYellow),
            tooltip: 'Save Changes',
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView( // Allows scrolling if content overflows
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Profile Picture ---
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: kSubtleGray, // Placeholder background
                    // TODO: Load actual profile image here
                    child: Icon(Icons.person, size: 60, color: kDeepMidnightBlue),
                  ),
                  Material(
                    color: kHighlightYellow,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement image picker logic
                        print('Change profile picture tapped');
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image Picker Placeholder'), backgroundColor: kCyan),
                       );
                      },
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt, color: kDeepMidnightBlue, size: 20),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // --- Form Fields ---
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
               _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email, // Often used for usernames
                validator: (value) => value == null || value.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) { // Basic email validation
                     return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // Consider adding a "Save Changes" button here as well,
              // if you prefer it over the AppBar action.
               ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHighlightYellow,
                  foregroundColor: kDeepMidnightBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_alt),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent text field styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: kLightText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kSubtleGray),
        prefixIcon: Icon(icon, color: kCyan, size: 20),
        filled: true,
        fillColor: kDeepMidnightBlue.withOpacity(0.5), // Slightly different background for field
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: kSubtleGray.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: kCyan, width: 1.5),
        ),
         errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
         contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
    );
  }
}