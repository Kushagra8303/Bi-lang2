import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart';

class ChatController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get myUid => auth.currentUser!.uid;

  // ---------------------- CHAT ID ----------------------
  String getChatId(String a, String b) {
    return a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
  }


  // ---------------------- GET MESSAGES ----------------------
  Stream<QuerySnapshot> getMessages(String otherId) {
    String chatId = getChatId(myUid, otherId);

    return firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // ---------------------- CHAT LIST STREAM ----------------------
  Stream<QuerySnapshot> getMyChatsStream() {
    return firestore
        .collection("users")
        .doc(myUid)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // ---------------------- SEND MESSAGE ----------------------
  Future<void> sendMessage({
    required UserModel me,
    required UserModel other,
    required String message,
  }) async {
    String chatId = getChatId(me.id!, other.id!);

    await firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add({
      "senderId": me.id,
      "receiverId": other.id,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
      "seen": false,
      "translatedCache": {},
    });

    await saveChatListForBoth(
      me: me,
      other: other,
      lastMessage: message,
    );
  }

  // ---------------------- UPDATE CHAT LIST ----------------------
  Future<void> saveChatListForBoth({
    required UserModel me,
    required UserModel other,
    required String lastMessage,
  }) async {
    String chatId = getChatId(me.id!, other.id!);

    // For ME (sender)
    await firestore
        .collection("users")
        .doc(me.id!)
        .collection("chats")
        .doc(other.id!)
        .set({
      "uid": other.id,
      "name": other.name,
      "email": other.email,
      "profileImage": other.profileImage,
      "lastMessage": lastMessage,
      "timestamp": FieldValue.serverTimestamp(),
      "chatId": chatId,
      "unreadCount": 0,
    }, SetOptions(merge: true));

    // For OTHER (receiver)
    await firestore
        .collection("users")
        .doc(other.id!)
        .collection("chats")
        .doc(me.id!)
        .set({
      "uid": me.id,
      "name": me.name,
      "email": me.email,
      "profileImage": me.profileImage,
      "lastMessage": lastMessage,
      "timestamp": FieldValue.serverTimestamp(),
      "chatId": chatId,
      "unreadCount": FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // ---------------------- MARK SEEN ----------------------
  Future<void> markMessagesSeen(String chatId, String myUid) async {
    final unread = await firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .where("receiverId", isEqualTo: myUid)
        .where("seen", isEqualTo: false)
        .get();

    for (var m in unread.docs) {
      await m.reference.update({"seen": true});
    }

    // unreadCount reset
    final ids = chatId.split("_");
    final otherUid = ids[0] == myUid ? ids[1] : ids[0];

    await firestore
        .collection("users")
        .doc(myUid)
        .collection("chats")
        .doc(otherUid)
        .update({"unreadCount": 0});
  }
}
