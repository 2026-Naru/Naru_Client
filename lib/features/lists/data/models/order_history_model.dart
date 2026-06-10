class OrderHistoryModel {
  final int id;
  final String status;
  final String storeName;
  final String? storeImageUrl;
  final int totalAmount;
  final String orderedAt;
  final List<OrderHistoryItemModel> items;
  final bool isLocal;

  const OrderHistoryModel({
    required this.id,
    required this.status,
    required this.storeName,
    this.storeImageUrl,
    required this.totalAmount,
    required this.orderedAt,
    this.items = const [],
    this.isLocal = false,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    final store = json['stores'] as Map<String, dynamic>?;
    final orderItems = json['order_items'] as List<dynamic>? ?? const [];
    return OrderHistoryModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'UNKNOWN',
      storeName: store?['name'] as String? ?? '알 수 없는 가게',
      storeImageUrl: store?['image_url'] as String?,
      totalAmount: (json['paid_amount'] as num?)?.toInt() ??
          (json['total_amount'] as num?)?.toInt() ??
          0,
      orderedAt:
          json['paid_at'] as String? ?? json['ordered_at'] as String? ?? '',
      items: orderItems
          .map((e) => OrderHistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory OrderHistoryModel.fromLocalJson(Map<String, dynamic> json) {
    final orderItems = json['items'] as List<dynamic>? ?? const [];
    return OrderHistoryModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'PAID',
      storeName: json['storeName'] as String? ?? 'Delivery order',
      storeImageUrl: json['storeImageUrl'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      orderedAt: json['orderedAt'] as String? ?? '',
      items: orderItems
          .map((e) =>
              OrderHistoryItemModel.fromLocalJson(e as Map<String, dynamic>))
          .toList(),
      isLocal: true,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'status': status,
      'storeName': storeName,
      'storeImageUrl': storeImageUrl,
      'totalAmount': totalAmount,
      'orderedAt': orderedAt,
      'items': items.map((item) => item.toLocalJson()).toList(),
    };
  }

  bool get isPending =>
      status == 'PAID' || status == 'COOKING' || status == 'DELIVERING';

  String get displayStatus {
    switch (status) {
      case 'PAID':
        return 'Order Being Prepared';
      case 'COOKING':
        return 'Cooking';
      case 'DELIVERING':
        return 'On the Way';
      case 'COMPLETED':
        return 'Purchase Confirmed';
      case 'CANCELED':
        return 'Canceled';
      default:
        return status;
    }
  }

  String get itemSummary {
    if (items.isEmpty) return 'Delivery order';
    if (items.length == 1) return items.first.displayName;
    return '${items.first.displayName} + ${items.length - 1} items';
  }

  String? get displayImageUrl {
    if (items.isNotEmpty && items.first.imageUrl != null) {
      return items.first.imageUrl;
    }
    return storeImageUrl;
  }

  String get formattedDate {
    if (orderedAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(orderedAt);
      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      return '${dt.month}.${dt.day} ${days[dt.weekday - 1]}';
    } catch (_) {
      return orderedAt;
    }
  }
}

class OrderHistoryItemModel {
  final String name;
  final String? imageUrl;
  final int quantity;
  final int unitPrice;

  const OrderHistoryItemModel({
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final menu = json['menus'] as Map<String, dynamic>?;
    return OrderHistoryItemModel(
      name: json['menu_name'] as String? ??
          json['menuName'] as String? ??
          json['name'] as String? ??
          menu?['name'] as String? ??
          'Ordered item',
      imageUrl: json['menu_image'] as String? ??
          json['menuImage'] as String? ??
          json['image_url'] as String? ??
          json['imageUrl'] as String? ??
          menu?['image_url'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toInt() ??
          (json['price'] as num?)?.toInt() ??
          0,
    );
  }

  factory OrderHistoryItemModel.fromLocalJson(Map<String, dynamic> json) {
    return OrderHistoryItemModel(
      name: json['name'] as String? ?? 'Ordered item',
      imageUrl: json['imageUrl'] as String? ??
          json['image_url'] as String? ??
          json['menu_image'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  String get displayName {
    if (quantity <= 1) return name;
    return '$name x$quantity';
  }
}
