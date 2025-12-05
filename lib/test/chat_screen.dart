import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../sharedPrefrenceMethods/SharedPrefrenceMethods.dart';
import '../models/UserModel.dart';
import 'chatControler.dart';

class ChatScreen extends StatefulWidget {
  final UserModel me;   // Current user
  final UserModel other;

  const ChatScreen({
    super.key,
    required this.me,
    required this.other,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SharedPreferenceMethods _prefs = SharedPreferenceMethods();
  final Dio _dio = Dio();
  final ChatController _chatController = ChatController();

  late String userLanguage = "en-US";
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = _chatController.getChatId(widget.me.id!, widget.other.id!);
    _loadUserLanguage();
  }

  Future<void> _loadUserLanguage() async {
    userLanguage = await _prefs.getUserLanguage() ?? "en-US";
    setState(() {});
  }

  // ---------------- SEND MESSAGE ----------------
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _chatController.sendMessage(
      me: widget.me,
      other: widget.other,
      message: text,
    );

    _messageController.clear();
  }

  // ---------------- TRANSLATE ----------------
  Future<void> translateMessage(
      String original,
      DocumentReference ref,
      Map<String, dynamic> cache,
      ) async {
    if (cache.containsKey(userLanguage)) return;

    try {
      final apiKey = "ap2_0dc5e861-dcd6-4cf1-a450-5da08a7fdfa8";
      final res = await _dio.post(
        "https://api.murf.ai/v1/text/translate",
        options: Options(headers: {
          "api-key": apiKey,
          "Content-Type": "application/json",
        }),
        data: {
          "targetLanguage": userLanguage,
          "texts": [original],
        },
      );

      final translated =
          res.data["translations"][0]["translated_text"] ?? original;

      cache[userLanguage] = translated;
      await ref.update({"translatedCache": cache});
      setState(() {}); // trigger rebuild to show translation immediately
    } catch (e) {
      print("ChatScreen: translation error => $e");
    }
  }

  // ---------------- RECEIVED MESSAGE WIDGET ----------------
  Widget _buildReceivedMessage(Map<String, dynamic> data, DocumentReference ref) {
    final original = data["message"] ?? "";
    final cache = Map<String, dynamic>.from(data["translatedCache"] ?? {});

    if (cache.containsKey(userLanguage)) {
      return _otherMessage(cache[userLanguage]!);
    }

    translateMessage(original, ref, cache);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            ),
            SizedBox(width: 8),
            Text("Translating...", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D141C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2B3040),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: (widget.other.profileImage != null &&
                    widget.other.profileImage!.isNotEmpty)
                    ? NetworkImage(widget.other.profileImage!)
                    : null,
                child: (widget.other.profileImage == null ||
                    widget.other.profileImage!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  widget.other.name ?? "Chat",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(chatRoomId)
                    .collection("messages")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("Say Hi!", style: TextStyle(color: Colors.white54)),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final bool isMe = data["senderId"] == widget.me.id;

                      if (isMe) return _myMessage(data["message"] ?? "");

                      return _buildReceivedMessage(data, doc.reference);
                    },
                  );
                },
              ),
            ),
            _inputField(),
          ],
        ),
      ),
    );
  }

  // ---------------- MESSAGE UI ----------------
  Widget _myMessage(String msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _otherMessage(String msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------
  Widget _inputField() {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          border: Border.all(color: Colors.purple.shade300),
          borderRadius: BorderRadius.circular(12),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.purple),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
