import 'package:flutter/material.dart';
import 'package:test/screens/chatScreen.dart';
import 'package:test/screens/homeScreen.dart';
import 'package:test/screens/login_Screen.dart';
import 'package:test/screens/editProfileScreen.dart';
import 'package:test/screens/profileScreen.dart';
import 'package:test/screens/userprofileScreen.dart';
import 'package:test/screens/signUP_screen.dart';
import 'package:test/screens/splash_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test/test/add_user_ui_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// ✅ App wrapper to track user status
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserOnlineStatus(true); // App started
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setUserOnlineStatus(false); // App closed
    super.dispose();
  }

  // 🔹 Listen to app lifecycle to update status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_auth.currentUser == null) return;

    if (state == AppLifecycleState.resumed) {
      _setUserOnlineStatus(true); // App in foreground
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setUserOnlineStatus(false); // App in background/closed
    }
  }

  Future<void> _setUserOnlineStatus(bool isOnline) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection("users").doc(uid).set({
      "status": isOnline ? "online" : "offline",
      "lastOnlineStatus": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D141C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2B3040),
        ),
      ),
      routes: {
        "/": (context) => const SplashScreen(),
        "/home": (context) => const HomeScreen(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpScreen(),
        "/userprofile": (context) => const UserProfileScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/editprofile": (context) => const EditProfileScreen(),
        "/adduser": (context) => const AddUserScreen(),
      },
    );
  }
}
