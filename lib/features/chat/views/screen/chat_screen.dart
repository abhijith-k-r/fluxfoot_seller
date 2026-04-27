import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluxfoot_seller/core/services/chat_service.dart';
import 'package:fluxfoot_seller/core/themes/app_theme.dart';
import 'package:fluxfoot_seller/features/chat/model/message_model.dart';
import 'package:fluxfoot_seller/features/chat/view_model/chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SellerChatDashboard extends StatelessWidget {
  const SellerChatDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Recent Chats Sidebar (320px)
        _buildRecentChatsSidebar(context),
        Container(
          width: 5,
          height: double.infinity,
          color: WebColors.buttonPurple,
        ),
        // 2. Main Chat Window (Expanded)
        Expanded(child: _buildMainChatWindow(context)),
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
          if (snapshot.hasError) {
            Center(child: Text("Error: ${snapshot.error}"));
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(
              child: Text("No active customer support chats."),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              bool isActive = chatProvider.selectedChatId == chat['chatId'];
              return InkWell(
                onTap: () => chatProvider.selectChat(chat),
                child: _buildChatListItem(chat, isActive),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMainChatWindow(BuildContext context) {
    final chatProvider = Provider.of<SellerChatProvider>(context);
    final String sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ChatService chatService = ChatService();

    if (chatProvider.selectedChatId == null) {
      return const Center(
        child: Text("Select a conversation to start chatting"),
      );
    }

    final chatData = chatProvider.selectedOrderContext!;
    final participants = List<String>.from(chatData['participants'] ?? []);
    final userId = participants.firstWhere(
      (id) => id != sellerId,
      orElse: () => '',
    );

    return Column(
      children: [
        // Chat Header
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(chatProvider.selectedChatId!)
              .snapshots(),
          builder: (context, snapshot) {
            final chatId = chatProvider.selectedChatId!;
            final orderId = chatId.replaceAll('chat_', '');

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .get(),
              builder: (context, orderSnapshot) {
                String customerName = "User";
                String productName = "N/A";

                final chatData = snapshot.hasData
                    ? snapshot.data!.data() as Map<String, dynamic>?
                    : null;
                final orderData = orderSnapshot.hasData
                    ? orderSnapshot.data!.data() as Map<String, dynamic>?
                    : null;

                // Priority for Product Name: Chat Doc > Order Doc
                productName =
                    chatData?['productName'] ??
                    orderData?['productName'] ??
                    "N/A";

                return FutureBuilder<DocumentSnapshot>(
                  future: orderData != null
                      ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(orderData['userId'])
                            .get()
                      : null,
                  builder: (context, userSnapshot) {
                    final userData = userSnapshot.hasData
                        ? userSnapshot.data!.data() as Map<String, dynamic>?
                        : null;

                    // Priority for Customer Name: Chat Doc > User Doc
                    customerName =
                        chatData?['customerName'] ??
                        userData?['name'] ??
                        "User";

                    return Container(
                      height: 85,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: WebColors.bgWiteShade),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer: $customerName",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Product: $productName",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        // Chat Feed
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: StreamBuilder<List<MessageModel>>(
              stream: chatService.getMessages(chatProvider.selectedChatId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return GestureDetector(
                      onLongPress: msg.senderId == sellerId
                          ? () => _showDeleteDialog(
                              context,
                              chatProvider.selectedChatId!,
                              msg.id!,
                            )
                          : null,
                      child: _buildMessageBubble(
                        msg.text,
                        DateFormat('hh:mm a').format(msg.timestamp),
                        isMe: msg.senderId == sellerId,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Input Area
        _buildChatInput(chatProvider.selectedChatId!, userId, sellerId),
      ],
    );
  }

  Widget _buildChatListItem(Map<String, dynamic> chat, bool isActive) {
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
          FutureBuilder<DocumentSnapshot>(
            future: (chat['customerImageUrl'] == null ||
                    chat['customerImageUrl'].toString().isEmpty)
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(() {
                    final List<String> participants =
                        List<String>.from(chat['participants'] ?? []);
                    final String sId =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    return participants.firstWhere((id) => id != sId,
                        orElse: () => '');
                  }())
                    .get()
                : null,
            builder: (context, userSnapshot) {
              String? imageUrl = chat['customerImageUrl'];
              if (imageUrl == null || imageUrl.isEmpty) {
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  imageUrl = userData?['imageUrl'];
                }
              }

              return CircleAvatar(
                backgroundColor: WebColors.bgWiteShade,
                radius: 24,
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Order #${chat['orderId']?.toString().toUpperCase() ?? 'N/A'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      chat['lastTimestamp'] != null
                          ? DateFormat('hh:mm a').format(
                              (chat['lastTimestamp'] as Timestamp).toDate(),
                            )
                          : "",
                      style: TextStyle(fontSize: 11, color: WebColors.iconGrey),
                    ),
                  ],
                ),
                Text(
                  chat['lastMessage'] ?? "No messages yet",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  // lib/features/chat/views/screens/seller_chat_dashboard.dart

  Widget _buildChatInput(String chatId, String userId, String sellerId) {
    final TextEditingController messageController = TextEditingController();
    final chatService = ChatService();
    Future<void> onSend() async {
      if (messageController.text.trim().isNotEmpty) {
        // 1. Create the Message
        final sellerMessage = MessageModel(
          senderId: sellerId,
          text: messageController.text.trim(),
          timestamp: DateTime.now(),
        );

        // 2. Clear input
        messageController.clear();

        // 3. Send via ChatService
        await chatService.sendMessage(
          chatId: chatId,
          message: sellerMessage,
          sellerId: sellerId,
          userId: userId,
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ... (your existing icon buttons) ...
          Expanded(
            child: TextField(
              controller: messageController,
              onSubmitted: (_) => onSend(), // Enter to send
              decoration: const InputDecoration(
                hintText: "Reply to customer...",
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: WebColors.buttonPurple),
            onPressed: () => onSend(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String chatId,
    String messageId,
  ) {
    final chatService = ChatService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message?"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await chatService.deleteMessage(chatId, messageId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
