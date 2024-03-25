import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    final cartItemIndex =
        _cartItems.indexWhere((item) => item.productId == productId);
    if (cartItemIndex != -1) {
      _cartItems[cartItemIndex].quantity = newQuantity;
      notifyListeners();
    }
  }
}
