import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluxfoot_seller/features/chat/model/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Generate a unique Chat ID based on Order
  String getChatId(String orderId) => "chat_$orderId";

  // 2. Send a Message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    final chatDoc = _firestore.collection('chats').doc(chatId);

    // Write message to sub-collection
    await chatDoc.collection('messages').add(message.toMap());

    // Update the main chat doc with "Last Message" info for the sidebar
    await chatDoc.set({
      'lastMessage': message.text,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'chatId': chatId,
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
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getSellerChats(String sellerId) {
    return _firestore
        .collection('chats')
        // Only show chats that belong to this seller
        .where('participants', arrayContains: sellerId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
