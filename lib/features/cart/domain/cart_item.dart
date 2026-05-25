class CartItem {
  final String id;
  final String menuName;
  final String imagePath;
  final String selectedSize;
  final String selectedJokbal;
  final String selectedDrink;
  final int unitPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.menuName,
    required this.imagePath,
    required this.selectedSize,
    required this.selectedJokbal,
    required this.selectedDrink,
    required this.unitPrice,
    this.quantity = 1,
  });

  int get totalPrice => unitPrice * quantity;

  String get optionsSummary => '$selectedSize · $selectedJokbal · $selectedDrink';
}
