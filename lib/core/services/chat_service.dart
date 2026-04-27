import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluxfoot_seller/features/chat/model/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Generate a unique Chat ID based on Order
  String getChatId(String orderId) => "chat_$orderId";

  // 2. Send a Message
  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
    required String sellerId,
    required String userId,
    String? productName,
    String? customerName,
    String? sellerName,
  }) async {
    final chatDoc = _firestore.collection('chats').doc(chatId);

    // Write message to sub-collection
    await chatDoc.collection('messages').add(message.toMap());

    // Update the main chat doc with "Last Message" info for the sidebar
     await chatDoc.set({
      'chatId': chatId,
      'participants': FieldValue.arrayUnion([
        userId,
        sellerId,
      ]),
      'lastMessage': message.text,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'orderId': chatId.replaceAll('chat_', ''),
      if (productName != null) 'productName': productName,
      if (customerName != null) 'customerName': customerName,
      if (sellerName != null) 'sellerName': sellerName,
    }, SetOptions(merge: true));
  }

  // 3. Get Real-time Messages (The Stream)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // 4. Delete a Message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getSellerChats(String sellerId) {
    return _firestore
        .collection('chats')
        // Only show chats that belong to this seller
        .where('participants', arrayContains: sellerId)
        // .orderBy('lastTimestamp', descending: true) // Commented for Index debugging
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
