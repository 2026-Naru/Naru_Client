import 'package:flutter/material.dart';
import '../../domain/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  static const int deliveryFee = 3000;
  static const int discount = 0;

  int get total => subtotal + deliveryFee - discount;

  void addItem({
    int? menuId,
    int? storeId,
    String? storeName,
    String? storeImagePath,
    required String menuName,
    required String imagePath,
    required String selectedSize,
    required String selectedJokbal,
    required String selectedDrink,
    required int unitPrice,
    required int quantity,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.menuName == menuName &&
          item.selectedSize == selectedSize &&
          item.selectedJokbal == selectedJokbal &&
          item.selectedDrink == selectedDrink,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: '${menuName}_${DateTime.now().millisecondsSinceEpoch}',
        menuId: menuId,
        storeId: storeId,
        storeName: storeName,
        storeImagePath: storeImagePath,
        menuName: menuName,
        imagePath: imagePath,
        selectedSize: selectedSize,
        selectedJokbal: selectedJokbal,
        selectedDrink: selectedDrink,
        unitPrice: unitPrice,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void incrementQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
