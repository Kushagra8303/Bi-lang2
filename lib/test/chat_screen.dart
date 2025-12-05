import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../sharedPrefrenceMethods/SharedPrefrenceMethods.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SharedPreferenceMethods _prefs = SharedPreferenceMethods();
  final Dio _dio = Dio();

  late String userLanguage = "en-US";
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = getChatRoomId(widget.currentUserId, widget.otherUserId);
    _loadUserLanguage();
  }

  String getChatRoomId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? "${id1}_$id2" : "${id2}_$id1";
  }

  Future<void> _loadUserLanguage() async {
    userLanguage = await _prefs.getUserLanguage() ?? "en-US";
    setState(() {});
  }

  // ---------------- SEND MESSAGE ----------------
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messageRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages");

    await messageRef.add({
      "senderId": widget.currentUserId,
      "message": text,
      "timestamp": FieldValue.serverTimestamp(),
      "translatedCache": {},
    });

    _messageController.clear();
  }

  // ---------------- TRANSLATE MESSAGE FIRST ----------------
  Future<void> translateMessage(
      String original, DocumentReference ref, Map<String, dynamic> cache) async {
    if (cache.containsKey(userLanguage)) return;

    try {
      final apiKey = "ap2_0dc5e861-dcd6-4cf1-a450-5da08a7fdfa8";

      final response = await _dio.post(
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
          response.data['translations'][0]['translated_text'] ?? original;

      cache[userLanguage] = translated;
      await ref.update({"translatedCache": cache});
    } catch (e) {
      debugPrint("Translation error: $e");
    }
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
        appBar: AppBar(title: Text(widget.otherUserName)),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(chatRoomId)
                    .collection("messages")
                    .orderBy("timestamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final original = data["message"] ?? "";
                      final cache =
                      Map<String, dynamic>.from(data["translatedCache"] ?? {});
                      final isMe =
                          data["senderId"] == widget.currentUserId;

                      // ------------------ MY MESSAGE ------------------
                      if (isMe) {
                        return _myMessage(original);
                      }

                      // ------------------ RECEIVED MESSAGE ------------------

                      // translated text if exists
                      String translated = cache[userLanguage] ?? "";

                      // if translation does not exist → translate first
                      if (!cache.containsKey(userLanguage)) {
                        translateMessage(original, doc.reference, cache);
                        return const SizedBox(height: 0); // DO NOT SHOW ORIGINAL
                      }

                      // direct translated message show
                      return _otherMessage(translated);
                    },
                  );
                },
              ),
            ),

            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // ---------------- MESSAGE UI MOCKS ----------------

  Widget _myMessage(String msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.black12,
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
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Colors.purple),
          )
        ],
      ),
    );
  }
}
