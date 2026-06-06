class OrderHistoryModel {
  final int id;
  final String status;
  final String storeName;
  final String? storeImageUrl;
  final int totalAmount;
  final String orderedAt;

  const OrderHistoryModel({
    required this.id,
    required this.status,
    required this.storeName,
    this.storeImageUrl,
    required this.totalAmount,
    required this.orderedAt,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    final store = json['stores'] as Map<String, dynamic>?;
    return OrderHistoryModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'UNKNOWN',
      storeName: store?['name'] as String? ?? '알 수 없는 가게',
      storeImageUrl: store?['image_url'] as String?,
      totalAmount: (json['paid_amount'] as num?)?.toInt() ??
          (json['total_amount'] as num?)?.toInt() ?? 0,
      orderedAt: json['paid_at'] as String? ??
          json['ordered_at'] as String? ?? '',
    );
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
