import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';
import 'chatControler.dart';
import 'chat_screen.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  Future<UserModel> _fetchCurrentUser(String uid) async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) {
      return UserModel(id: uid, name: "Unknown User");
    }

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Widget build(BuildContext context) {
    final chatCtrl = ChatController();
    final myUid = chatCtrl.myUid;

    return FutureBuilder<UserModel>(
      future: _fetchCurrentUser(myUid),
      builder: (context, meSnap) {
        if (!meSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final me = meSnap.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: chatCtrl.getMyChatsStream(),
          builder: (context, chatSnap) {
            if (!chatSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chatDocs = chatSnap.data!.docs;

            if (chatDocs.isEmpty) {
              return const Center(
                child: Text(
                    "No Chats Yet", style: TextStyle(color: Colors.white54)),
              );
            }

            return ListView.builder(
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                final data = chatDocs[index].data() as Map<String, dynamic>;

                final other = UserModel(
                  id: data["uid"],
                  name: data["name"],
                  email: data["email"],
                  profileImage: data["profileImage"],
                );

                return Padding(
                  padding: const EdgeInsets.only(left: 6,right:6,bottom: 3,),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3040),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (other.profileImage != null &&
                            other.profileImage!.isNotEmpty)
                            ? NetworkImage(other.profileImage!)
                            : null,
                        child: (other.profileImage == null ||
                            other.profileImage!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(other.name ?? "",
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        data["lastMessage"] ?? "",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: data["unreadCount"] != null &&
                          data["unreadCount"] > 0
                          ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          data["unreadCount"].toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatScreen(me: me, other: other),
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