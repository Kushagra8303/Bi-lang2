import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/userModel.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initUser(String uid, String email, String name) async {
    UserModel user = UserModel(
      id: uid,
      name: name,
      email: email,
      profileImage: "",
      mobileNumber: "",
    );

    try {
      await _firestore.collection("users").doc(uid).set(user.toJson());
      print("User Created Successfully in Firestore");
    } catch (e) {
      print("❌ Firestore Error: $e");
    }
  }
}
