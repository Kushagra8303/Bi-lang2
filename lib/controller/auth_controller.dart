import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../sharedPrefrenceMethods/SharedPrefrenceMethods.dart';
import '../models/UserModel.dart';

class AuthController {
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final SharedPreferenceMethods prefs = SharedPreferenceMethods();

  // ---------------- SIGNUP -----------------
  Future<String?> signup(
      BuildContext context,
      String name,
      String mobile,
      String email,
      String password,
      String language,
      ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;
      if (user == null) return "Something went wrong!";

      String uid = user.uid;
      await user.updateDisplayName(name);

      // Create UserModel with language
      UserModel userModel = UserModel(
        id: uid,
        name: name,
        email: email,
        profileImage: "",
        mobileNumber: mobile,
        language: language,
      );

      await firestore.collection("users").doc(uid).set(userModel.toJson());

      // Save in SharedPreferences
      await prefs.saveUserLogin(true);
      await prefs.saveUserUid(uid);
      await prefs.saveUserName(name);
      await prefs.saveUserEmail(email);
      await prefs.saveUserMobile(mobile);
      await prefs.saveUserLanguage(language);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Signup failed: $e")));
      }
      return "$e";
    }
  }

  // ---------------- LOGIN -----------------
  Future<String?> login(BuildContext context, String email, String password) async {
    try {
      print("Login started with $email");

      // Firebase Auth Login
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      String uid = userCredential.user!.uid;
      print("Firebase user logged in: $uid");

      // Fetch Firestore User
      DocumentSnapshot snapshot = await firestore.collection("users").doc(uid).get();
      if (!snapshot.exists) {
        // Create default user document if missing
        UserModel newUser = UserModel(
          id: uid,
          name: userCredential.user!.displayName ?? "Unknown",
          email: email,
          profileImage: "",
          mobileNumber: "",
          language: "en-US", // default language
        );

        await firestore.collection("users").doc(uid).set(newUser.toJson());
        snapshot = await firestore.collection("users").doc(uid).get();
        print("Firestore user created during login");
      }

      UserModel userModel = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      print("Firestore user loaded: ${userModel.name}");
      String savedLanguage="";
      // Save Local Storage including language
      await prefs.saveUserLogin(true);
      await prefs.saveUserUid(userModel.id ?? "");
      await prefs.saveUserName(userModel.name ?? "");
      await prefs.saveUserEmail(userModel.email ?? "");
      await prefs.saveUserMobile(userModel.mobileNumber ?? "");
      await prefs.saveUserLanguage(userModel.language ?? "en-US");
       savedLanguage = (await prefs.getUserLanguage())!;
      print("✅ Login Language saved in SharedPreferences: $savedLanguage");// ✅ Save language
      print("Login data saved to SharedPreferences");
      print(" ssssssss Login data saved to SharedPreferences  ${ prefs.getUserLanguage()}");

      // Navigate
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }

      return null;
    } catch (e) {
      print("Login Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
      return "$e";
    }
  }

  // ---------------- LOGOUT -----------------
  Future<void> logout(BuildContext context) async {
    try {
      await auth.signOut();
      await prefs.clearUserData();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    } catch (e) {
      print("Logout Error: $e");
    }
  }
}
