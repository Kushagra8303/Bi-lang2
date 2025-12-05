import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart';

class ChatController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get myUid {
    print("ccccccc ChatController: Getting myUid");
    return auth.currentUser!.uid;
  }

  // 🟢 Chat ID Generator (consistent logic)
  String getChatId(String a, String b) {
    String chatId = a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
    print("ccccccc ChatController: Generated Chat ID => $chatId");
    return chatId;
  }

  // 🟢 Fetch Messages Stream
  Stream<QuerySnapshot> getMessages(String otherId) {
    String chatId = getChatId(myUid, otherId);

    print("ccccccc ChatController: Fetching messages for ChatID => $chatId");

    return firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true) // descending: true (for ListView reverse: true)
        .snapshots();
  }

  // 🟢 Fetch My Chat List
  Stream<QuerySnapshot> getMyChatsStream() {
    print("ccccccc ChatController: Fetching Chat List for User => $myUid");

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

      print("ccccccc ChatController: Sending message to ChatID => $chatId");

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
        "translatedCache": {},
      });

      print("ccccccc ChatController: Message saved successfully in chats collection.");

      // 2️⃣ Save chat list entries
      await saveChatListForBoth(
        me: me,
        other: other,
        lastMessage: message,
      );

      print("ccccccc ChatController: Chat list update completed.");

    } catch (e) {
      print("ccccccc ChatController: ❌ Cannot send message error: $e");
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

    print("ccccccc ChatController: Updating chat list for ME: $myUid, OTHER: $otherUid");

    // My chat entry (for ME)
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

    print("ccccccc ChatController: ME's chat list updated.");

    // Other user's chat entry (for OTHER)
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

    print("ccccccc ChatController: OTHER's chat list updated.");
  }
}