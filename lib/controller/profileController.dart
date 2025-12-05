import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/UserModel.dart'; // adjust path if needed

class ProfileController with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  UserModel? currentUser;

  // ---------------- FETCH USER DETAILS ----------------
  Future<void> getUserDetails() async {
    try {
      final doc = await db.collection("users").doc(auth.currentUser!.uid).get();

      if (doc.exists) {
        currentUser = UserModel.fromJson(doc.data()!);
        notifyListeners(); // update UI
        print("🔥 User loaded: ${currentUser?.name}");
      } else {
        print("❌ User document not found");
      }
    } catch (e) {
      print("🔥 Error fetching user: $e");
    }
  }
}
