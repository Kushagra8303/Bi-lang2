import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../sharedPrefrenceMethods/SharedPrefrenceMethods.dart';
import '../models/UserModel.dart';
import 'chatControler.dart';
import 'other_user_status_controller.dart';

class ChatScreen extends StatefulWidget {
  final UserModel me;
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
  final TextEditingController _controller = TextEditingController();
  final SharedPreferenceMethods _prefs = SharedPreferenceMethods();
  final ChatController chatCtrl = ChatController();
  final UserStatusController userStatusCtrl = UserStatusController();
  final Dio _dio = Dio();

  late String chatId;
  String language = "en-US";

  // ---------------------------------------------------
  // TIME AGO FUNCTION
  // ---------------------------------------------------
  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";

    if (diff.inHours < 24) {
      return diff.inHours == 1 ? "1 hr ago" : "${diff.inHours} hrs ago";
    }

    if (diff.inDays == 1) return "yesterday";

    return "${diff.inDays} days ago";
  }

  @override
  void initState() {
    super.initState();
    chatId = chatCtrl.getChatId(widget.me.id!, widget.other.id!);
    loadLang();

    Future.delayed(const Duration(milliseconds: 300), () {
      chatCtrl.markMessagesSeen(chatId, widget.me.id!);
    });
  }

  loadLang() async {
    language = (await _prefs.getUserLanguage()) ?? "en-US";
    setState(() {});
  }

  send() async {
    String msg = _controller.text.trim();
    if (msg.isEmpty) return;

    _controller.clear();

    await chatCtrl.sendMessage(
      me: widget.me,
      other: widget.other,
      message: msg,
    );
  }

  translateAndCache(
      String original, DocumentReference ref, Map<String, dynamic> cache) async {
    if (cache.containsKey(language)) return;

    try {
      final res = await _dio.post(
        "https://api.murf.ai/v1/text/translate",
        options: Options(headers: {
          "api-key": "ap2_0dc5e861-dcd6-4cf1-a450-5da08a7fdfa8",
          "Content-Type": "application/json",
        }),
        data: {
          "targetLanguage": language,
          "texts": [original],
        },
      );

      final text = res.data["translations"][0]["translated_text"] ?? original;

      cache[language] = text;
      await ref.update({"translatedCache": cache});
      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D141C),

      // ---------------------- APPBAR ----------------------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 1,
        backgroundColor: const Color(0xFF2B3040),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
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
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.other.name ?? "",
                      overflow: TextOverflow.ellipsis),

                  // 🔥 ONLINE / LAST SEEN STREAM
                  StreamBuilder<DocumentSnapshot>(
                    stream: userStatusCtrl
                        .getUserStatusStream(widget.other.id ?? ""),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Text(
                          "loading...",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        );
                      }

                      final data =
                      snap.data!.data() as Map<String, dynamic>?;

                      String status = data?["status"] ?? "offline";
                      var lastSeenRaw = data?["lastOnlineStatus"];

                      String lastSeen = "";

                      // 🔥 HANDLE TIMESTAMP + STRING BOTH
                      if (lastSeenRaw is Timestamp) {
                        lastSeen = timeAgo(lastSeenRaw.toDate());
                      } else if (lastSeenRaw is String) {
                        lastSeen = lastSeenRaw;
                      } else {
                        lastSeen = "just now";
                      }

                      return Row(
                        children: [
                          // Dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: status == "online"
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (status == "online"
                                      ? Colors.green
                                      : Colors.red)
                                      .withOpacity(0.7),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Offline → show last seen
                          if (status != "online")
                            Text(
                              " $lastSeen",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),

                          // Online
                          if (status == "online")
                            const Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_sharp),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call_rounded),
          ),

SizedBox(width: 10,)
        ],
      ),

      // ---------------------- BODY ----------------------
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .doc(chatId)
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                chatCtrl.markMessagesSeen(chatId, widget.me.id!);

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;

                    bool isMe = data["senderId"] == widget.me.id;

                    if (isMe) return myBubble(data);

                    return receiverBubble(doc);
                  },
                );
              },
            ),
          ),
          inputBox(),
        ],
      ),
    );
  }

  // ---------------- MY MESSAGE BUBBLE ---------------------
  Widget myBubble(Map<String, dynamic> data) {
    bool isSeen = data["seen"] ?? false;

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data["message"],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Icon(
            isSeen ? Icons.done_all : Icons.done,
            size: 20,
            color: isSeen ? Colors.blue : Colors.white54,
          ),
        ],
      ),
    );
  }

  // ---------------- RECEIVER MESSAGE ---------------------
  Widget receiverBubble(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ref = doc.reference;
    final msg = data["message"];
    Map<String, dynamic> cache =
    Map<String, dynamic>.from(data["translatedCache"] ?? {});

    if (cache.containsKey(language)) {
      return otherBubble(cache[language]);
    }

    translateAndCache(msg, ref, cache);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: null,
      ),
    );
  }

  Widget otherBubble(String msg) {
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

  // ---------------- INPUT BOX ---------------------
  Widget inputBox() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "  Type a message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: send,
          )
        ],
      ),
    );
  }
}
