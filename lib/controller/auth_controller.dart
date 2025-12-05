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

  // --------------------------------------------------------
  // 🔥 LAST SEEN FORMATTER
  // --------------------------------------------------------
  String getLastSeenTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}  "
        "${now.day}/${now.month}/${now.year}";
  }

  // --------------------------------------------------------
  // 🔵 USER ONLINE
  // --------------------------------------------------------
  Future<void> setUserOnline() async {
    if (auth.currentUser == null) return;

    await firestore.collection("users").doc(auth.currentUser!.uid).update({
      "status": "online",
      "lastOnlineStatus": "Online"
    });
  }

  // --------------------------------------------------------
  // 🔴 USER OFFLINE + LAST SEEN UPDATE
  // --------------------------------------------------------
  Future<void> setUserOffline() async {
    if (auth.currentUser == null) return;

    String lastSeen = getLastSeenTime();

    await firestore.collection("users").doc(auth.currentUser!.uid).update({
      "status": "offline",
      "lastOnlineStatus": "Last seen at $lastSeen"
    });
  }

  // --------------------------------------------------------
  // 🔐 SIGNUP
  // --------------------------------------------------------
  Future<String?> signup(
      BuildContext context,
      String name,
      String mobile,
      String email,
      String password,
      String language,
      ) async {
    try {
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;
      if (user == null) return "Something went wrong!";

      String uid = user.uid;
      await user.updateDisplayName(name);

      UserModel userModel = UserModel(
        id: uid,
        name: name,
        email: email,
        profileImage: "",
        mobileNumber: mobile,
        language: language,
        status: "online",
        lastOnlineStatus: "Online",
      );

      await firestore.collection("users").doc(uid).set(userModel.toJson());

      // LOCAL SAVE
      await prefs.saveUserLogin(true);
      await prefs.saveUserUid(uid);
      await prefs.saveUserName(name);
      await prefs.saveUserEmail(email);
      await prefs.saveUserMobile(mobile);
      await prefs.saveUserLanguage(language);

      // Mark Online
      await setUserOnline();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup failed: $e")));
      }
      return "$e";
    }
  }

  // --------------------------------------------------------
  // 🔐 LOGIN
  // --------------------------------------------------------
  Future<String?> login(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential =
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;

      DocumentSnapshot snapshot =
      await firestore.collection("users").doc(uid).get();

      // If user does not exist → create new profile
      if (!snapshot.exists) {
        UserModel newUser = UserModel(
          id: uid,
          name: userCredential.user!.displayName ?? "Unknown",
          email: email,
          profileImage: "",
          mobileNumber: "",
          language: "en-US",
          status: "online",
          lastOnlineStatus: "Online",
        );

        await firestore.collection("users").doc(uid).set(newUser.toJson());
        snapshot = await firestore.collection("users").doc(uid).get();
      }

      UserModel userModel =
      UserModel.fromJson(snapshot.data() as Map<String, dynamic>);

      // SAVE LOCAL
      await prefs.saveUserLogin(true);
      await prefs.saveUserUid(userModel.id ?? "");
      await prefs.saveUserName(userModel.name ?? "");
      await prefs.saveUserEmail(userModel.email ?? "");
      await prefs.saveUserMobile(userModel.mobileNumber ?? "");
      await prefs.saveUserLanguage(userModel.language ?? "en-US");

      // Mark Online
      await setUserOnline();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: $e")));
      }
      return "$e";
    }
  }

  // --------------------------------------------------------
  // 🔐 LOGOUT
  // --------------------------------------------------------
  Future<void> logout(BuildContext context) async {
    try {
      print("🔹 Logout started");

      // 1️⃣ Set offline + last seen
      if (auth.currentUser != null) {
        await setUserOffline();
        print("🔹 Set offline done");
      }

      // 2️⃣ Firebase sign out
      await auth.signOut();
      print("🔹 Firebase signOut done");

      // 3️⃣ Clear local prefs
      await prefs.clearUserData();
      print("🔹 Prefs cleared");

      // 4️⃣ Navigate safely
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
          print("🔹 Navigation to login done");
        }
      });
    } catch (e) {
      print("Logout Error: $e");
    }
  }




  // --------------------------------------------------------
  // 🟡 APP CLOSE/BACKGROUND  → AUTO LAST SEEN UPDATE
  // --------------------------------------------------------
  Future<void> handleAppLifecycle(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      await setUserOffline();
    }
  }
}
