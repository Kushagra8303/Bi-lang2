import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import 'add_user.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final AddUserController addCtrl = AddUserController();

  UserModel? searchedUser;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                hintText: "Enter email to search user",
                filled: true,
                fillColor: const Color(0xFF2B3040),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                  error = null;
                  searchedUser = null;
                });

                final result = await addCtrl.findUserByEmail(emailCtrl.text);

                setState(() {
                  loading = false;
                  searchedUser = result;
                  if (result == null) {
                    error = "No user found with this email";
                  }
                });
              },
              child: const Text("Search"),
            ),

            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),

            if (searchedUser != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: searchedUser!.profileImage!.isNotEmpty
                      ? NetworkImage(searchedUser!.profileImage!)
                      : null,
                  child: searchedUser!.profileImage!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(searchedUser!.name ?? ""),
                subtitle: Text(searchedUser!.email ?? ""),
                trailing: ElevatedButton(
                  onPressed: () async {
                    print("🔵 ADD BUTTON CLICKED");
                    await addCtrl.addUserToChatList(searchedUser!);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User added successfully")),
                    );

                    // 🔥 Navigate back to home
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/home",
                          (route) => false,
                    );
                  },
                  child: const Text("Add"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
