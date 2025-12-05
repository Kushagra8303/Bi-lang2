import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isComing; // True = Incoming (Left), False = Outgoing (Right)
  final bool status;   // True = Read (Blue ticks), False = Unread (Grey ticks)
  final String? imageUrl; // Optional: Agar image hai toh URL pass karein

  const MessageBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.isComing,
    this.status = false,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      // Agar message aa raha hai (isComing) toh Left, warna Right
      alignment: isComing ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isComing? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3040), // Bubble Background Color
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                // Agar incoming hai toh bottom-left sharp hoga, warna bottom-right
                bottomLeft: isComing ? Radius.zero : const Radius.circular(12),
                bottomRight: isComing ? const Radius.circular(12) : Radius.zero,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Logic (Agar image URL null nahi hai toh dikhaye)
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // 2. Message Text
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 5),

                // 3. Time & Status Row

              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 2.0,bottom: 12,left: 8,right: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                ),
                // Agar message maine bheja hai (!isComing) tabhi ticks dikhaye
                if (!isComing) ...[
                  const SizedBox(width: 5),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    // Agar status true hai toh Blue, warna Grey
                    color: status ? Colors.blue : Colors.grey,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}