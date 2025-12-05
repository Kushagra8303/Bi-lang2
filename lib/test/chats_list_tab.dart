import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/UserModel.dart';
import 'chatControler.dart';
import 'chat_screen.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  // Current user ka UserModel fetch karein
  Future<UserModel> _fetchCurrentUser(String uid) async {
    print("lllllllll ChatsTab: Fetching current user doc for UID: $uid");
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) {
      print("lllllllll ChatsTab: Current user doc not found! Using basic model.");
      return UserModel(id: uid, name: "Unknown User");
    }

    print("lllllllll ChatsTab: Current user doc found.");
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final chatCtrl = ChatController();
    final String myUid = chatCtrl.myUid;

    print("lllllllll ChatsTab: Building tab for myUid: $myUid");

    // Current User ka UserModel fetch karein
    return FutureBuilder<UserModel>(
      future: _fetchCurrentUser(myUid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          print("lllllllll ChatsTab FutureBuilder: Waiting for Current User data.");
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          print("lllllllll ChatsTab FutureBuilder: Error or No data for Current User.");
          return const Center(
            child: Text("Error fetching user data.", style: TextStyle(color: Colors.red)),
          );
        }

        final UserModel me = userSnapshot.data!;
        print("lllllllll ChatsTab: Current User (ME) Model fetched. Name: ${me.name}");


        // Ab Chat List fetch karein
        return StreamBuilder<QuerySnapshot>(
          stream: chatCtrl.getMyChatsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              print("lllllllll ChatsTab StreamBuilder: Waiting for Chat List data.");
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              print("lllllllll ChatsTab StreamBuilder: No Chats Yet.");
              return const Center(
                child: Text("No Chats Yet", style: TextStyle(color: Colors.white54)),
              );
            }

            var chatDocs = snapshot.data!.docs;
            print("lllllllll ChatsTab StreamBuilder: Found ${chatDocs.length} chat entries.");

            return ListView.builder(
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                var chatData = chatDocs[index].data() as Map<String, dynamic>;

                print("lllllllll ChatsTab: Rendering Chat Entry ${index} for User ID: ${chatData['uid']}");

                // Other User ka UserModel
                UserModel otherUser = UserModel(
                  id: chatData["uid"],
                  name: chatData["name"],
                  email: chatData["email"],
                  profileImage: chatData["profileImage"],
                    status: chatData["status"],
                    lastOnlineStatus: chatData["lastOnlineStatus"]
                );

                return Padding(
                  padding:  EdgeInsets.symmetric(vertical: 8.0,horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF2B3040),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (otherUser.profileImage != null &&
                            otherUser.profileImage!.isNotEmpty)
                            ? NetworkImage(otherUser.profileImage!)
                            : null,
                        child: (otherUser.profileImage == null ||
                            otherUser.profileImage!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        otherUser.name ?? "",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      subtitle: Text(
                        chatData["lastMessage"] ?? "",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () {
                        print("lllllllll ChatsTab: Tapped on chat with ${otherUser.name}. Navigating to ChatScreen.");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              me: me,                 // Pass current user's full UserModel
                              other: otherUser,      // Pass other user's UserModel
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}