import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart';

class ChatController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get myUid => auth.currentUser!.uid;

  // 🟢 Chat ID Generator (same for both users)
  String getChatId(String a, String b) {
    return a.hashCode <= b.hashCode ? '${a}_$b' : '${b}_$a';
  }

  // 🟢 Fetch Messages Stream (FIXED)
  Stream<QuerySnapshot> getMessages(String otherId) {
    String chatId = getChatId(myUid, otherId);

    print("📌 Fetching messages for ChatID => $chatId");

    return firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // 🟢 Fetch My Chat List
  Stream<QuerySnapshot> getMyChatsStream() {
    print("📌 Fetching Chat List for User => $myUid");

    return firestore
        .collection("users")
        .doc(myUid)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // 🟢 Send Message
  Future<void> sendMessage({
    required UserModel me,
    required UserModel other,
    required String message,
  }) async {
    try {
      String chatId = getChatId(me.id!, other.id!);

      print("📩 Sending message to ChatID => $chatId");

      // 1️⃣ Save message
      await firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .add({
        "senderId": me.id,
        "receiverId": other.id,
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Message saved successfully");

      // 2️⃣ Save chat list entries
      await saveChatListForBoth(
        me: me,
        other: other,
        lastMessage: message,
      );

      print("✅ Chat list updated for both users");

    } catch (e) {
      print("❌ Cannot send message: $e");
    }
  }

  // 🟢 Save Chat List For Both Users
  Future<void> saveChatListForBoth({
    required UserModel me,
    required UserModel other,
    required String lastMessage,
  }) async {

    String myUid = me.id!;
    String otherUid = other.id!;

    print("📌 Updating chat list => me: $myUid, other: $otherUid");

    // My chat entry
    await firestore
        .collection("users")
        .doc(myUid)
        .collection("chats")
        .doc(otherUid)
        .set({
      "uid": otherUid,
      "name": other.name,
      "email": other.email,
      "profileImage": other.profileImage,
      "lastMessage": lastMessage,
      "timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Other user's chat entry
    await firestore
        .collection("users")
        .doc(otherUid)
        .collection("chats")
        .doc(myUid)
        .set({
      "uid": myUid,
      "name": me.name,
      "email": me.email,
      "profileImage": me.profileImage,
      "lastMessage": lastMessage,
      "timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
