import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FcmService {
  /// Sends a push notification to a specific user based on their UID
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      // 1. Fetch the user's FCM token from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        log("FCM: User document not found for $userId");
        return;
      }

      final fcmToken = userDoc.data()?['fcmToken'];
      if (fcmToken == null || fcmToken.toString().isEmpty) {
        log("FCM: No token found for user $userId");
        return;
      }

      log("FCM: Sending notification to token: $fcmToken");

      // 2. Prepare the notification payload
      // NOTE: This uses the Legacy API structure for simplicity in setup.
      // For FCM v1, you would need an OAuth2 Bearer token.
      final Map<String, dynamic> payload = {
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
        }
      };

      // 3. Send the request
      // IMPORTANT: Replace YOUR_SERVER_KEY with your key from Firebase Console 
      // (Project Settings > Cloud Messaging > Cloud Messaging API (Legacy) )
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'key=YOUR_SERVER_KEY', 
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log("FCM: Notification sent successfully!");
      } else {
        log("FCM: Failed to send notification. Status: ${response.statusCode}");
        log("FCM: Response body: ${response.body}");
      }
    } catch (e) {
      log("FCM: Error sending notification: $e");
    }
  }
}
