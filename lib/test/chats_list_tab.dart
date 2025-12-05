import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/UserModel.dart';
import 'chatControler.dart';
import 'chat_screen.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final chatCtrl = ChatController();
    final String myUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: chatCtrl.getMyChatsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Chats Yet", style: TextStyle(color: Colors.white54)),
          );
        }

        var chatDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            var chatData = chatDocs[index].data() as Map<String, dynamic>;

            // 🔥 Debug Print
            print("ChatTile User => ID: ${chatData['uid']}  Name: ${chatData['name']}");

            UserModel otherUser = UserModel(
              id: chatData["uid"],
              name: chatData["name"],
              email: chatData["email"],
              profileImage: chatData["profileImage"],
            );

            return ListTile(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      currentUserId: myUid,                 // ✅ pass current user UID
                      otherUserId: otherUser.id ?? "", otherUserName: otherUser.name ??"",      // ✅ pass other user UID
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
