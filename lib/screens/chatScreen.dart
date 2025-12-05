// import 'package:flutter/material.dart';
//
// import '../Widgets/chat_screen_Widgets/chatBubbles.dart';
//
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   // Dummy Data
//   final List<Map<String, dynamic>> messages = [
//     {
//       "isMe": false,
//       "message": "Hello How are you ?",
//       "time": "10:10 AM",
//       "type": "text",
//     },
//     {
//       "isMe": true,
//       "message": "Hello How are you ?",
//       "time": "10:10 AM",
//       "type": "text",
//     },
//     {
//       "isMe": true,
//       "message": "Hello How are you ?",
//       "time": "10:10 AM",
//       "type": "image",
//       "imageUrl": "https://storage.googleapis.com/cms-storage-bucket/704dd39688e4f8ec8395.png",
//     },
//     {
//       "isMe": false,
//       "message": "Hello How are you ?",
//       "time": "10:10 AM",
//       "type": "text",
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D141C),
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//
//                 // Yahan par humne naya MessageBubble widget use kiya hai
//                 return MessageBubble(
//                   message: msg['message'],
//                   time: msg['time'],
//                   isComing: !msg['isMe'], // Logic: Agar 'Me' nahi hai, to 'Coming' hai
//                   status: true, // Example: Blue ticks on
//                   imageUrl: msg['type'] == 'image' ? msg['imageUrl'] : null,
//                 );
//               },
//             ),
//           ),
//           _buildInputArea(),
//         ],
//       ),
//     );
//   }
//
//   // 1. AppBar Widget
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: const Color(0xFF2B3040),
//       titleSpacing: 0,
//       leading: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: CircleAvatar(
//           backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"),
//           backgroundColor: Colors.grey,
//         ),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: const [
//           Text(
//             "Nitish Kumar",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           Text(
//             "Online",
//             style: TextStyle(fontSize: 12, color: Colors.grey),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.call, color: Colors.white),
//         ),
//         IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.videocam, color: Colors.white),
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }
//
//   // 2. Bottom Input Area
//   Widget _buildInputArea() {
//     return Padding(
//       padding:  EdgeInsets.symmetric(vertical: 12.0),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         color: const Color(0xFF0D141C),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2B3040),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.mic, color: Colors.grey),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     hintText: "Type message ...",
//                     hintStyle: TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//               const Icon(Icons.image_outlined, color: Colors.grey),
//               const SizedBox(width: 10),
//               const Icon(Icons.send, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // --- Custom Message Bubble Widget ---
// // Agar aapne iski alag file banayi hai to is part ko hata kar import kar lena
// // class MessageBubble extends StatelessWidget {
// //   final String message;
// //   final String time;
// //   final bool isComing;
// //   final bool status;
// //   final String? imageUrl;
// //
// //   const MessageBubble({
// //     Key? key,
// //     required this.message,
// //     required this.time,
// //     required this.isComing,
// //     this.status = false,
// //     this.imageUrl,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Align(
// //       alignment: isComing ? Alignment.centerLeft : Alignment.centerRight,
// //       child: Container(
// //         margin: const EdgeInsets.symmetric(vertical: 8),
// //         padding: const EdgeInsets.all(12),
// //         constraints: BoxConstraints(
// //           maxWidth: MediaQuery.of(context).size.width * 0.75,
// //         ),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFF2B3040),
// //           borderRadius: BorderRadius.only(
// //             topLeft: const Radius.circular(12),
// //             topRight: const Radius.circular(12),
// //             bottomLeft: isComing ? Radius.zero : const Radius.circular(12),
// //             bottomRight: isComing ? const Radius.circular(12) : Radius.zero,
// //           ),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if (imageUrl != null && imageUrl!.isNotEmpty)
// //               Container(
// //                 margin: const EdgeInsets.only(bottom: 8),
// //                 height: 150,
// //                 width: double.infinity,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(8),
// //                   image: DecorationImage(
// //                     image: NetworkImage(imageUrl!),
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //               ),
// //             Text(
// //               message,
// //               style: const TextStyle(color: Colors.white, fontSize: 15),
// //             ),
// //             const SizedBox(height: 5),
// //             Row(
// //               mainAxisSize: MainAxisSize.min,
// //               mainAxisAlignment: MainAxisAlignment.end,
// //               children: [
// //                 Text(
// //                   time,
// //                   style: TextStyle(color: Colors.grey[400], fontSize: 10),
// //                 ),
// //                 if (!isComing) ...[
// //                   const SizedBox(width: 5),
// //                   Icon(
// //                     Icons.done_all,
// //                     size: 14,
// //                     color: status ? Colors.blue : Colors.grey,
// //                   ),
// //                 ]
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
