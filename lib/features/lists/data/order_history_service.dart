import '../../../core/services/api_client.dart';
import 'models/order_history_model.dart';

class OrderHistoryService {
  final ApiClient _api;

  OrderHistoryService(this._api);

  Future<List<OrderHistoryModel>> fetchAllOrders() async {
    final res = await _api.get('/users/me/orders');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderHistoryModel>> fetchPendingOrders() async {
    final res = await _api
        .get('/users/me/orders', queryParameters: {'status': 'pending'});
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderHistoryModel>> fetchCompletedOrders() async {
    final res = await _api
        .get('/users/me/orders', queryParameters: {'status': 'completed'});
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
