import 'package:flutter/material.dart';

class SellerChatProvider extends ChangeNotifier {
  String? _selectedChatId;
  Map<String, dynamic>? _selectedOrderContext;

  String? get selectedChatId => _selectedChatId;
  Map<String, dynamic>? get selectedOrderContext => _selectedOrderContext;

  void selectChat(Map<String, dynamic> chat) {
    _selectedChatId = chat['chatId'];
    _selectedOrderContext = chat;
    notifyListeners(); 
  }
}
