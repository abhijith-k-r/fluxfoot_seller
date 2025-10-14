// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

class KeyboardProvider extends ChangeNotifier {
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0.0;
  DateTime _lastUpdate = DateTime.now();

  bool get isKeyboardVisible => _isKeyboardVisible;
  double get keyboardHeight => _keyboardHeight;

  void updateKeybaordState(double keyboadHeight) {
    final now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds < 100) return;

    final wasVisible = _isKeyboardVisible;
    _keyboardHeight = keyboadHeight;
    _isKeyboardVisible = keyboadHeight > 50;

    if (wasVisible != _isKeyboardVisible) {
      notifyListeners();
    }
  }
}
