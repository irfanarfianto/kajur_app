import 'package:flutter/material.dart';

class MessageStatus extends ChangeNotifier {
  bool _isRead = false;

  bool get isRead => _isRead;

  void markAsRead() {
    _isRead = true;
    notifyListeners();
  }
}
