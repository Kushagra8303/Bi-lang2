import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceMethods {
  // SAVE LOGIN STATUS
  Future<void> saveUserLogin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", value);
  }

  Future<bool> getUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  // SAVE NAME
  Future<void> saveUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", name);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName");
  }

  // SAVE MOBILE
  Future<void> saveUserMobile(String mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userMobile", mobile);
  }

  Future<String?> getUserMobile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userMobile");
  }

  // SAVE EMAIL
  Future<void> saveUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userEmail", email);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }

  // SAVE UID
  Future<void> saveUserUid(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userUid", uid);
  }

  Future<String?> getUserUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userUid");
  }

  // CLEAR ALL DATA + LOGOUT
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool("isLoggedIn", false); // ✅ Set login false
    print("User logged out, isLoggedIn = false");

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // CLEAR ALL DATA (optional)
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

// 🔹 Add language save/load
  Future<void> saveUserLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userLanguage", lang);
  }

  Future<String?> getUserLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userLanguage");
  }




}
