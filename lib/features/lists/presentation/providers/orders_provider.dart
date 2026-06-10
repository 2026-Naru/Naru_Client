import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/order_history_model.dart';
import '../../data/order_history_service.dart';

class OrdersProvider extends ChangeNotifier {
  static const _localOrdersKey = 'naru_local_orders';

  OrderHistoryService? _service;

  List<OrderHistoryModel> _all = [];
  List<OrderHistoryModel> _pending = [];
  List<OrderHistoryModel> _completed = [];
  bool _isLoading = false;
  String? _error;

  List<OrderHistoryModel> get all => _all;
  List<OrderHistoryModel> get pending => _pending;
  List<OrderHistoryModel> get completed => _completed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = OrderHistoryService(api);
  }

  Future<void> fetchAll() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localOrders = await _loadLocalOrders();

    try {
      final remoteOrders = await _service!.fetchAllOrders();
      _all = _sortOrders([...localOrders, ...remoteOrders]);
    } catch (e) {
      if (localOrders.isNotEmpty) {
        _all = _sortOrders(localOrders);
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPending() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localOrders =
        (await _loadLocalOrders()).where((order) => order.isPending).toList();

    try {
      final remoteOrders = await _service!.fetchPendingOrders();
      _pending = _sortOrders([...localOrders, ...remoteOrders]);
    } catch (e) {
      if (localOrders.isNotEmpty) {
        _pending = _sortOrders(localOrders);
      }
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

    final localOrders = (await _loadLocalOrders())
        .where((order) => order.status == 'COMPLETED')
        .toList();

    try {
      final remoteOrders = await _service!.fetchCompletedOrders();
      _completed = _sortOrders([...localOrders, ...remoteOrders]);
    } catch (e) {
      if (localOrders.isNotEmpty) {
        _completed = _sortOrders(localOrders);
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderHistoryModel> recordLocalOrder({
    int? remoteOrderId,
    required String storeName,
    String? storeImageUrl,
    required int totalAmount,
    required List<OrderHistoryItemModel> items,
    String status = 'PAID',
  }) async {
    final localOrders = await _loadLocalOrders();
    final order = OrderHistoryModel(
      id: remoteOrderId ?? -DateTime.now().microsecondsSinceEpoch,
      status: status,
      storeName: storeName,
      storeImageUrl: storeImageUrl,
      totalAmount: totalAmount,
      orderedAt: DateTime.now().toIso8601String(),
      items: items,
      isLocal: true,
    );

    final updatedLocalOrders = _sortOrders([order, ...localOrders]);
    await _saveLocalOrders(updatedLocalOrders);
    _all = _sortOrders([order, ..._all]);
    if (order.isPending) {
      _pending = _sortOrders([order, ..._pending]);
    }
    if (order.status == 'COMPLETED') {
      _completed = _sortOrders([order, ..._completed]);
    }
    _error = null;
    notifyListeners();
    return order;
  }

  Future<void> completeOrder(int orderId) async {
    if (_service == null) await init();

    if (orderId > 0) {
      try {
        await _service!
            .updateOrderStatus(orderId: orderId, status: 'COMPLETED');
      } catch (e) {
        _error = e.toString();
      }
    }

    final localOrders = await _loadLocalOrders();
    final updatedLocalOrders = localOrders
        .map((order) =>
            order.id == orderId ? order.copyWith(status: 'COMPLETED') : order)
        .toList();
    await _saveLocalOrders(updatedLocalOrders);

    _all = _sortOrders(_all
        .map((order) =>
            order.id == orderId ? order.copyWith(status: 'COMPLETED') : order)
        .toList());
    _pending = _sortOrders(
      _pending
          .map((order) =>
              order.id == orderId ? order.copyWith(status: 'COMPLETED') : order)
          .where((order) => order.isPending)
          .toList(),
    );

    final completedOrder = [
      ...updatedLocalOrders,
      ..._all,
    ].where((order) => order.id == orderId && order.status == 'COMPLETED');
    if (completedOrder.isNotEmpty) {
      _completed = _sortOrders([completedOrder.first, ..._completed]);
    }

    notifyListeners();
  }

  List<OrderHistoryModel> _sortOrders(List<OrderHistoryModel> orders) {
    final deduped = <String, OrderHistoryModel>{};
    for (final order in orders) {
      final key = order.id > 0 ? 'order:${order.id}' : 'local:${order.id}';
      final existing = deduped[key];
      if (existing != null && existing.isLocal && !order.isLocal) {
        deduped[key] = order;
        continue;
      }
      if (existing != null && !existing.isLocal && order.isLocal) continue;
      deduped[key] = order;
    }

    final list = deduped.values.toList();
    list.sort((a, b) => _orderTime(b).compareTo(_orderTime(a)));
    return list;
  }

  DateTime _orderTime(OrderHistoryModel order) {
    return DateTime.tryParse(order.orderedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<OrderHistoryModel>> _loadLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localOrdersKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
              (e) => OrderHistoryModel.fromLocalJson(e as Map<String, dynamic>))
          .where((order) => order.id != 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocalOrders(List<OrderHistoryModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final localOrders = orders.where((order) => order.isLocal).toList();
    final encoded = jsonEncode(
      localOrders.map((order) => order.toLocalJson()).toList(),
    );
    await prefs.setString(_localOrdersKey, encoded);
  }
}
