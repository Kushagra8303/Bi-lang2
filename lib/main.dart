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
import 'package:test/test/chat_screen.dart';

import 'firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0D141C),
      appBarTheme:  AppBarTheme(
        backgroundColor: Color(0xFF2B3040),
      ),
    ),
    routes: {
      "/": (context) => const SplashScreen(),
      "/home": (context) => const HomeScreen(),
      "/login": (context) => const LoginScreen(),
      //"/chat": (context) => const ChatScreen(),
       "/signup": (context) => const SignUpScreen(), // Uncomment if using separate files"
      "/userprofile": (context) => const UserProfileScreen(), // Uncomment if using separate files"
      "/profile": (context) => const ProfileScreen(), // Uncomment if using separate files"
      "/editprofile": (context) => const EditProfileScreen(),
      // Uncomment if using separate files"
      "/adduser": (context) => const AddUserScreen(), // Uncomment if using separate files"
    },
  ));
}
