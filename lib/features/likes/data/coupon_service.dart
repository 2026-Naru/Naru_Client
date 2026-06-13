import '../../../core/services/api_client.dart';

class CouponService {
  final ApiClient _api;

  CouponService(this._api);

  Future<List<UserCoupon>> fetchCoupons() async {
    final res = await _api.get('/users/me/coupons');
    final list = res['data'] as List<dynamic>? ?? const [];
    return list
        .map((e) => UserCoupon.fromJson(e as Map<String, dynamic>))
        .where((coupon) => coupon.discountAmount > 0)
        .toList();
  }
}

class UserCoupon {
  final int id;
  final int couponId;
  final String name;
  final int discountAmount;
  final String? expiresAt;

  const UserCoupon({
    required this.id,
    required this.couponId,
    required this.name,
    required this.discountAmount,
    this.expiresAt,
  });

  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    return UserCoupon(
      id: (json['id'] as num?)?.toInt() ?? 0,
      couponId: (json['coupon_id'] as num?)?.toInt() ??
          (json['couponId'] as num?)?.toInt() ??
          0,
      name: json['name'] as String? ?? 'Discount coupon',
      discountAmount: (json['discount_amount'] as num?)?.toInt() ??
          (json['discountAmount'] as num?)?.toInt() ??
          0,
      expiresAt: json['expires_at'] as String? ?? json['expiresAt'] as String?,
    );
  }
}
