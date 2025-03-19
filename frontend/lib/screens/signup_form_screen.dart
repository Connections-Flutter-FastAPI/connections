// lib/screens/signup_form_screen.dart (No changes needed here from the previous correct version)
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';
import '../theme/theme_constants.dart';

class SignUpFormScreen extends StatefulWidget {
  const SignUpFormScreen({super.key});

  @override
  _SignUpFormScreenState createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>(); // Add form key

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController(); //For the user's location.

  String _selectedGender = "";
  String _selectedCollege = "";
  final List<String> _selectedInterests = [];
  Uint8List? _profileImage;  // Keep this as Uint8List
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _password = "";

  bool _isLoading = false; // Loading state

  final List<String> colleges = [
    "VIT Vellore",
    "IIT Delhi",
    "IIM Bangalore",
    "BITS Pilani",
    "SRM Chennai",
    "MIT Manipal",
    "NSUT",
    "RVCE"
  ];
    // Use your interest list from the provided code
  final List<Map<String, dynamic>> interests = [
    {"name": "Sports", "icon": Icons.sports_soccer},
    {"name": "Video Games", "icon": Icons.videogame_asset},
    {"name": "Gymming", "icon": Icons.fitness_center},
    {"name": "Movies", "icon": Icons.movie},
    {"name": "Music", "icon": Icons.music_note},
    {"name": "Photography", "icon": Icons.camera_alt},
    {"name": "Travel", "icon": Icons.flight},
    {"name": "Cooking", "icon": Icons.restaurant},
    {"name": "Reading", "icon": Icons.menu_book},
    {"name": "Dancing", "icon": Icons.ballot},
    {"name": "Coding", "icon": Icons.code},
    {"name": "Painting", "icon": Icons.brush},
    {"name": "Hiking", "icon": Icons.terrain},
    {"name": "Yoga", "icon": Icons.self_improvement},
    {"name": "Cycling", "icon": Icons.directions_bike},
    {"name": "Board Games", "icon": Icons.extension},
    {"name": "Fishing", "icon": Icons.pool},
    {"name": "Gardening", "icon": Icons.local_florist},
    {"name": "Camping", "icon": Icons.nightlight_round},
    {"name": "Writing", "icon": Icons.edit},
    {"name": "Singing", "icon": Icons.mic},
    {"name": "Fashion", "icon": Icons.checkroom},
    {"name": "Skateboarding", "icon": Icons.skateboarding},
    {"name": "Astronomy", "icon": Icons.nights_stay},
    {"name": "Surfing", "icon": Icons.surfing},
    {"name": "Archery", "icon": Icons.architecture},
    {"name": "Chess", "icon": Icons.games},
    {"name": "Robotics", "icon": Icons.smart_toy},
    {"name": "Meditation", "icon": Icons.spa},
    {"name": "Stand-up Comedy", "icon": Icons.theater_comedy},
    {"name": "Calligraphy", "icon": Icons.create},
    {"name": "Art", "icon": Icons.art_track},
    {"name": "Podcasting", "icon": Icons.podcasts},
    {"name": "Karaoke", "icon": Icons.queue_music},
    {"name": "DJing", "icon": Icons.music_note},
    {"name": "Origami", "icon": Icons.description},
    {"name": "Baking", "icon": Icons.cake},
    {"name": "Lego Building", "icon": Icons.toys},
    {"name": "Bartending", "icon": Icons.local_bar},
    {"name": "Woodworking", "icon": Icons.handyman},
    {"name": "Parkour", "icon": Icons.run_circle},
    {"name": "Scuba Diving", "icon": Icons.scuba_diving},
    {"name": "Magic Tricks", "icon": Icons.visibility},
  ];

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

    Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path).readAsBytesSync();
      });
    }
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength / 5.0;
  }

  IconData _getLockIcon(double strength) {
    if (strength == 0.0) return Icons.lock_open;
    if (strength < 0.4) return Icons.lock_outline;
    if (strength < 0.7) return Icons.lock;
    return Icons.lock_rounded;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        child: Form( // Wrap with Form
          key: _formKey,
          child: Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),

              // Step Content
              Expanded(child: _buildStepContent()),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      child: const Text("Back"),
                    ),
                  ElevatedButton(
                   onPressed: () async {
                      if (_currentStep < 3) {
                        // Validate current step before proceeding
                        if (_formKey.currentState!.validate()) {
                          setState(() => _currentStep++);
                        }
                      } else {
                        // Last Step: Submit Form
                        if (_formKey.currentState!.validate()) {
                          _signUp(); // Call signup function
                        }
                      }
                    },
                    child: Text(_currentStep == 3 ? "Finish" : "Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
    // Step Content
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return Container();
    }
  }

  // Step 1: Name, Username, Email, Gender, and Profile Image
  Widget _buildStep1() {
      return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.black54)
                      : null,
                ),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: ThemeConstants.smallPadding),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a username' : null,
          ),
          const SizedBox(height: ThemeConstants.smallPadding),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
           const SizedBox(height: ThemeConstants.smallPadding),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your location' : null,
          ),
          const SizedBox(height: ThemeConstants.mediumPadding),
          const Text("Select Gender",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: ThemeConstants.smallPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["Male", "Female", "Others"].map((gender) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.smallPadding),
                child: ChoiceChip(
                  label: Text(gender),
                  selected: _selectedGender == gender,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedGender = selected ? gender : "";
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step 2: Password & Confirm Password
  Widget _buildStep2() {
   double strength = _calculatePasswordStrength(_password);
    return Column(
      children: [
        const Text("Set Your Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          controller: _passwordController, // Use controller
            onChanged: (value) {
            setState(() {
              _password = value;
            });
          },
          decoration: InputDecoration(
            labelText: "Enter Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          obscureText: !_isPasswordVisible,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a password' : null,
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strength > 0.7 ? Colors.green : Colors.orange),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Password Strength: ${(strength * 100).toInt()}%"),
            Icon(_getLockIcon(strength), color: strength > 0.7 ? Colors.green : Colors.orange),
          ],
        ),
        const SizedBox(height: ThemeConstants.smallPadding),
        TextFormField(
          controller: _confirmPasswordController, // Use controller
          decoration:  InputDecoration(
            labelText: "Confirm Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
          obscureText: !_isConfirmPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Step 3: Select College
   Widget _buildStep3() {
    return Column(
      children: [
        const Text("Select Your College", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colleges.map((college) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCollege = college;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 100,
                decoration: BoxDecoration(
                  color: _selectedCollege == college ? Theme.of(context).primaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  college,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedCollege == college ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Other College Option
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedCollege = "Other";
            });
          },
          child: Text(
            "Other College",
            style: TextStyle(
              fontSize: 16,
              color: _selectedCollege == "Other" ? Theme.of(context).primaryColor : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Select Interests
  Widget _buildStep4() {
     return Column(
      children: [
        const Text("Select Your Interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: interests.length,
            itemBuilder: (context, index) {
              String interestName = interests[index]["name"];
              IconData interestIcon = interests[index]["icon"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedInterests.contains(interestName)) {
                      _selectedInterests.remove(interestName);
                    } else {
                      _selectedInterests.add(interestName);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedInterests.contains(interestName) ? Theme.of(context).primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(interestIcon, size: 30, color: Theme.of(context).iconTheme.color),
                      Text(interestName, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

 // Updated Signup function (connects to ApiService)
 void _signUp() async {
    setState(() => _isLoading = true);
    final apiService = context.read<ApiService>();
    final authProvider = context.read<AuthProvider>();  // Not used in this example, but good practice to keep

    try {
      String? imageFileName;
        if (_profileImage != null) {
          // Get original file name from picked file (if available).
          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            imageFileName = pickedFile.name;  // Get the file NAME
          }
        }

      // Call your ApiService signup method with imageBytes and fileName
      final result = await apiService.signup(
        _nameController.text,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _selectedGender,
        _locationController.text,
        _selectedCollege,
        _selectedInterests,
        _profileImage, // Pass the image bytes
        imageFileName, // Pass the filename
      );

      // If signup is successful, show a success message and navigate to home.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful!'), backgroundColor: ThemeConstants.successColor),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

    } catch (e) {
      // Handle errors (e.g., display an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e'), backgroundColor: ThemeConstants.errorColor),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}