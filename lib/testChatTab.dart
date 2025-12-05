// import 'package:flutter/material.dart';
//
// class ChatsTab extends StatelessWidget {
//   const ChatsTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: [
//
//
//     buildChatTile(
//     name: "Saas Kumari",
//     message: "Bad me bat krte hai",
//     time: "08:33 PM",
//     ),
//
//     ],
//     );
//   }
//   Widget buildChatTile({
//     required String name,
//     required String message,
//     required String time,
//     Color avatarColor = Colors.indigoAccent,
//     IconData avatarIcon = Icons.person,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: const Color(0xFF2B3040),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: avatarColor,
//               child: Icon(
//                 avatarIcon,
//                 size: 32,
//                 color: Colors.white,
//               ),
//             ),
//
//             const SizedBox(width: 12),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     message,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.white54,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             Text(
//               time,
//               style: const TextStyle(color: Colors.white54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
