import 'package:flutter/material.dart';
import 'package:test/controller/auth_controller.dart';

import '../controller/profileController.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileController profileController = ProfileController();
  bool isLoading = true;
  AuthController authController = AuthController();
  //ProfileController profileController = ProfileController();
  @override
  void initState() {
    super.initState();
    profileController.getUserDetails().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = profileController.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B3040),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? "No Name",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                   Text(
                   user?.email ?? "No Email" ,
                    //'Nitishr833@gmail.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Media section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Media',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '13',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  mediaItem('assets/image1.jpg'),
                  mediaItem('assets/image2.jpg'),
                  mediaItem('assets/image3.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2B3040),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'My name is Nitish Kumar. I am new here using Sampark app for communicating with my friends.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const Spacer(),

            // Encryption info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'End-to-end encrypted',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mediaItem(String imagePath) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[700],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
