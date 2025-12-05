import 'package:flutter/material.dart';
import 'package:test/sharedPrefrenceMethods/SharedPrefrenceMethods.dart';
import 'package:test/testChatTab.dart';

import '../test/chats_list_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final SharedPreferenceMethods _pref = SharedPreferenceMethods();
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  Future<void> _logout() async {
    await _pref.logout(context); // ✅ Uses new logout method
  }
  void _profile() {
    Navigator.pushNamed(context, "/profile"); // 🔥 Navigate to ProfileScreen
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, "/adduser");
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue,
                child: Icon(Icons.wechat_outlined, size: 38, color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Bi Chat",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
        actions: [
          const Icon(Icons.search, size: 26),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 26),
            onSelected: (value) {
              if (value == "logout") _logout();
              if (value == "profile") _profile();
              if (value == "share") {}
              if (value == "invite") {}
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Profile")),
              PopupMenuItem(value: "share", child: Text("Share App")),
              PopupMenuItem(value: "invite", child: Text("Invite Friends")),
              PopupMenuItem(value: "logout", child: Text("Logout")),
            ],
          ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _controller,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "Chats"),
            Tab(text: "Groups"),
            Tab(text: "Calls"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          ChatsTab(),
          Center(child: Text("Groups Coming Soon")),
          Center(child: Text("Calls Coming Soon")),
        ],
      ),
    );
  }
}
