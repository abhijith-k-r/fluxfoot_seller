import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/services/chat_service.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/chat/view_model/chat_provider.dart';
import 'package:provider/provider.dart';

class SellerChatDashboard extends StatelessWidget {
  const SellerChatDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Recent Chats Sidebar (320px)
        _buildRecentChatsSidebar(context),

        // 2. Main Chat Window (Expanded)
        Expanded(child: _buildMainChatWindow()),
      ],
    );
  }

  Widget _buildRecentChatsSidebar(BuildContext context) {
    final ChatService chatService = ChatService();

    final String sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final chatProvider = Provider.of<SellerChatProvider>(context);
    return SizedBox(
      width: 320,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getSellerChats(sellerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              width: 5,
              height: 30,
              child: Center(child: const CircularProgressIndicator()),
            );
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              bool isActive = chatProvider.selectedChatId == chat['chatId'];
              return InkWell(
                onTap: () => chatProvider.selectChat(chat),
                child: _buildChatListItem(isActive),
              );
            },
          );
        },
      ),

      // Column(
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(20),
      //       child: Column(
      //         children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               const Text(
      //                 "Recent Chats",
      //                 style: TextStyle(
      //                   fontSize: 20,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //               Icon(Icons.search, color: WebColors.iconGrey),
      //             ],
      //           ),
      //           const SizedBox(height: 15),
      //           Row(
      //             children: [
      //               _filterChip("All", isActive: true),
      //               const SizedBox(width: 8),
      //               _filterChip("Unread"),
      //               const SizedBox(width: 8),
      //               _filterChip("Resolved"),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //     Expanded(
      //       child: ListView.builder(
      //         itemCount: 5,
      //         itemBuilder: (context, index) => _buildChatListItem(index == 0),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildMainChatWindow() {
    return Column(
      children: [
        // Chat Header
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: WebColors.bgWiteShade)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer: John Doe",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: WebColors.succesGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Online",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text("View Order Details"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: WebColors.buttonPurple,
                  side: BorderSide(color: WebColors.bgWiteShade),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        // Chat Feed
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMessageBubble(
                  "Hello! I'm reaching out about Order #88291. It says delivered, but I haven't received it yet.",
                  "12:45 PM",
                  isMe: false,
                ),
                _buildInChatProductCard(),
                _buildMessageBubble(
                  "Hello John! I'm sorry to hear that. I'm checking the GPS coordinates of the delivery now. Just a moment.",
                  "12:48 PM",
                  isMe: true,
                ),
              ],
            ),
          ),
        ),
        // Input Area
        _buildChatInput(),
      ],
    );
  }

  // // --- Helper Widgets ---
  // Widget _filterChip(String label, {bool isActive = false}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: isActive ? WebColors.buttonPurple : WebColors.bgWiteShade,
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       label,
  //       style: TextStyle(
  //         color: isActive ? Colors.white : Colors.black,
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildChatListItem(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isActive ? WebColors.buttonPurple : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: WebColors.bgWiteShade, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "John Doe - #88291",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "12:45 PM",
                      style: TextStyle(fontSize: 11, color: WebColors.iconGrey),
                    ),
                  ],
                ),
                const Text(
                  "Hi, I'm checking on the delivery...",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, String time, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: isMe ? WebColors.buttonPurple : WebColors.bgWiteShade,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 5),
          Text(time, style: TextStyle(fontSize: 10, color: WebColors.iconGrey)),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: WebColors.bgWiteShade),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: WebColors.iconGrey,
              onPressed: () {},
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: WebColors.buttonPurple),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInChatProductCard() {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.bgWiteShade),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: WebColors.bgWiteShade,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Apex Runner",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$120",
                  style: TextStyle(
                    color: WebColors.buttonPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
