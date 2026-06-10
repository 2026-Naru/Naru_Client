import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/api_client.dart';
import '../../data/models/viewed_store_model.dart';
import '../../data/store_history_service.dart';

class StoreHistoryProvider extends ChangeNotifier {
  static const _localViewedStoresKey = 'naru_local_viewed_stores';

  StoreHistoryService? _service;
  List<ViewedStoreModel> _viewedStores = [];
  bool _isLoading = false;
  String? _error;

  List<ViewedStoreModel> get viewedStores => _viewedStores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = StoreHistoryService(api);
  }

  Future<void> fetch() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localStores = await _loadLocalViewedStores();
    try {
      final remoteStores = await _service!.fetchViewedStores();
      _viewedStores = _sortAndDedupe([...localStores, ...remoteStores]);
    } catch (e) {
      _viewedStores = _sortAndDedupe(localStores);
      _error = localStores.isEmpty ? null : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordViewedStore({
    int? storeId,
    required String name,
    String? description,
    String? imageUrl,
    double rating = 0,
    int reviewCount = 0,
    String? categoryName,
  }) async {
    if (_service == null) await init();

    final viewedStore = ViewedStoreModel(
      storeId: storeId ?? 0,
      name: name,
      description: description,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      categoryName: categoryName,
      viewedAt: DateTime.now().toIso8601String(),
      isLocal: true,
    );

    final localStores = await _loadLocalViewedStores();
    final updatedLocalStores = _sortAndDedupe([viewedStore, ...localStores]);
    await _saveLocalViewedStores(updatedLocalStores.take(50).toList());
    _viewedStores = _sortAndDedupe([viewedStore, ..._viewedStores]);
    notifyListeners();

    if (storeId == null || storeId <= 0) return;
    try {
      await _service!.recordViewedStore(storeId);
    } catch (e) {
      // Local history is already saved above. Remote sync can fail when the
      // deployed API or DB migration has not caught up yet, so keep the UI usable.
    }
  }

  List<ViewedStoreModel> _sortAndDedupe(List<ViewedStoreModel> stores) {
    final deduped = <String, ViewedStoreModel>{};
    for (final store in stores) {
      final key = store.storeId > 0 ? 'store:${store.storeId}' : store.name;
      final existing = deduped[key];
      if (existing != null && existing.isLocal && !store.isLocal) {
        deduped[key] = store;
        continue;
      }
      if (existing != null && !existing.isLocal && store.isLocal) continue;
      deduped[key] = store;
    }

    final list = deduped.values.toList();
    list.sort((a, b) => _viewedTime(b).compareTo(_viewedTime(a)));
    return list;
  }

  DateTime _viewedTime(ViewedStoreModel store) {
    return DateTime.tryParse(store.viewedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<ViewedStoreModel>> _loadLocalViewedStores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localViewedStoresKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ViewedStoreModel.fromLocalJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocalViewedStores(List<ViewedStoreModel> stores) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      stores.map((store) => store.toLocalJson()).toList(),
    );
    await prefs.setString(_localViewedStoresKey, encoded);
  }
}
