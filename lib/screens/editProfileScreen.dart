import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
  TextEditingController();
  final TextEditingController _aboutController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController( );
  final TextEditingController _numberController =
  TextEditingController();

  File? _imageFile; // Selected image
  final ImagePicker _picker = ImagePicker();

  // Show bottom sheet to choose image source
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from the given source
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
    await _picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B3040),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2B3040),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[400],
                        backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? const Icon(Icons.person,
                            size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name
              const Text("Name", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1B222C),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  suffixIcon: Icon(Icons.edit, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // About
              const Text("About", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: _aboutController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1B222C),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  suffixIcon: Icon(Icons.edit, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              const Text("Email", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1B222C),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  suffixIcon: Icon(Icons.edit, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Number
              const Text("Number", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              TextField(
                controller: _numberController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1B222C),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  suffixIcon: Icon(Icons.edit, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Save logic here
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("SAVE"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
