import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../controller/profileController.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthController authController = AuthController();
  ProfileController profileController = ProfileController();
  bool isLoading = true;

  final String name = "Nitish Kumar";
  final String about = "I am Groot";
  final String email = "Nitishr833@gmail.com";
  final String number = "+91 7033161175";

  @override
  void initState() {
    super.initState();
    profileController.getUserDetails().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }
  Widget build(BuildContext context) {
    final user = profileController.currentUser;
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
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[400],
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: CircleAvatar(
                    //     radius: 16,
                    //     backgroundColor: Colors.blue,
                    //     child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              buildInfoItem("Name", user?.name ?? "No Name",Icons.person,),
              buildInfoItem("About",about /*user?.about ?? "No About"*/,Icons.data_saver_off),
              buildInfoItem("Email", user?.email ?? "No Email",Icons.email, ),
              buildInfoItem("Number",  user?.mobileNumber ?? "No Mobile Number",Icons.phone, ),

              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, "/editprofile");
                  },
                  icon: const Icon(Icons.edit,size: 20,),
                  label: const Text("Edit",style: TextStyle(fontSize: 20),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B222C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(icon, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

}
