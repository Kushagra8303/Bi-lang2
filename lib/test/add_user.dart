import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUserController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Find user by email
  Future<UserModel?> findUserByEmail(String email) async {
    final query = await _db
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    // Use fromJson and map 'id'
    return UserModel.fromJson({...data, "id": query.docs.first.id});
  }

  // 🔹 Add user to my chat list
  Future<void> addUserToChatList(UserModel otherUser) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .collection("chats")
        .doc(otherUser.id)
        .set({
      "uid": otherUser.id,
      "name": otherUser.name,
      "email": otherUser.email,
      "profileImage": otherUser.profileImage,
      "lastMessage": "",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

}
