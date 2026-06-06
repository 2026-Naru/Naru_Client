import '../../../core/services/api_client.dart';

class OrderService {
  final ApiClient _api;

  OrderService(this._api);

  Future<Map<String, dynamic>> createOrder({
    required String type,
    String? deliveryAddress,
    List<int>? cartItemIds,
  }) async {
    final body = <String, dynamic>{'type': type};
    if (deliveryAddress != null) body['deliveryAddress'] = deliveryAddress;
    if (cartItemIds != null) body['cartItemIds'] = cartItemIds;

    final res = await _api.post('/orders', data: body);
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOrderStatus(int orderId) async {
    final res = await _api.get('/orders/$orderId/status');
    return res['data'] as Map<String, dynamic>;
  }
}
