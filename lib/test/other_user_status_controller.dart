// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class UserStatusController {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   String get myUid => auth.currentUser!.uid;
//
//   /// USER ONLINE
//   Future<void> setUserOnline() async {
//     await firestore.collection("users").doc(myUid).update({
//       "status": "online",
//       "lastOnlineStatus": FieldValue.serverTimestamp(),  // FIX
//     });
//   }
//
//   /// USER OFFLINE + SAVE LAST SEEN TIMESTAMP
//   Future<void> setUserOffline() async {
//     await firestore.collection("users").doc(myUid).update({
//       "status": "offline",
//       "lastOnlineStatus": FieldValue.serverTimestamp(),  // FIX
//     });
//   }
//
//   /// LIVE USER STATUS STREAM
//   Stream<DocumentSnapshot> getUserStatusStream(String uid) {
//     return firestore.collection("users").doc(uid).snapshots();
//   }
// }










import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatusController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String get myUid => auth.currentUser!.uid;

  /// USER ONLINE
  Future<void> setUserOnline() async {
    await firestore.collection("users").doc(myUid).update({
      "status": "online",
      "lastOnlineStatus": FieldValue.serverTimestamp(), // ✔ Timestamp
    });
  }

  /// USER OFFLINE
  Future<void> setUserOffline() async {
    await firestore.collection("users").doc(myUid).update({
      "status": "offline",
      "lastOnlineStatus": FieldValue.serverTimestamp(), // ✔ Timestamp
    });
  }

  /// REAL-TIME STREAM
  Stream<DocumentSnapshot> getUserStatusStream(String uid) {
    return firestore.collection("users").doc(uid).snapshots();
  }
}

