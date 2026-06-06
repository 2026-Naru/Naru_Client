import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/order_history_model.dart';
import '../../data/order_history_service.dart';

class OrdersProvider extends ChangeNotifier {
  OrderHistoryService? _service;

  List<OrderHistoryModel> _pending = [];
  List<OrderHistoryModel> _completed = [];
  bool _isLoading = false;
  String? _error;

  List<OrderHistoryModel> get pending => _pending;
  List<OrderHistoryModel> get completed => _completed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = OrderHistoryService(api);
  }

  Future<void> fetchPending() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pending = await _service!.fetchPendingOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompleted() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _completed = await _service!.fetchCompletedOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
