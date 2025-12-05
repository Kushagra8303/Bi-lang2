import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../sharedPrefrenceMethods/SharedPrefrenceMethods.dart';
import '../test/chats_list_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final SharedPreferenceMethods _pref = SharedPreferenceMethods();
  final AuthController authController = AuthController();
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    authController.setUserOnline(); // Home open → mark user online
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔥 App minimize / close handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      authController.setUserOnline();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      authController.setUserOffline();
    }
  }

  // 🔥 Logout function fully updated
  Future<void> _logout() async {
    print("🔹 Logout clicked"); // Debug print

    // 1️⃣ Set offline + last seen
    await authController.setUserOffline();

    // 2️⃣ Firebase sign out + clear prefs + navigate login
    await authController.logout(context);

    print("🔹 Logout finished"); // Debug print
  }

  void _profile() {
    Navigator.pushNamed(context, "/profile");
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
                child: Icon(Icons.wechat_outlined,
                    size: 38, color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text("Bi Chat",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          ],
        ),
        actions: [
          const Icon(Icons.search, size: 26),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 26),
            onSelected: (String value) async {
              print("Selected menu: $value"); // Debug
              if (value == "logout") await _logout();
              if (value == "profile") _profile();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Profile")),
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
