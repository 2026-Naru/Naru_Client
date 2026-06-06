import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_client.dart';
import '../../data/favorites_service.dart';
import '../../data/models/favorite_store_model.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _localFavoritesKey = 'naru_local_favorites';

  FavoritesService? _service;

  List<FavoriteStoreModel> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<FavoriteStoreModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favorites.length;

  bool isFavorite(int storeId) {
    return _favorites.any((favorite) => favorite.storeId == storeId);
  }

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = FavoritesService(api);
  }

  Future<void> fetch() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localFavorites = await _loadLocalFavorites();

    try {
      final remoteFavorites = await _service!.fetchFavorites();
      _favorites = _mergeFavorites(localFavorites, remoteFavorites);
      await _saveLocalFavorites(_favorites);
    } catch (e) {
      if (localFavorites.isNotEmpty) {
        _favorites = localFavorites;
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(FavoriteStoreModel store) async {
    final existing = _favoriteByStoreId(store.storeId);
    if (existing != null) {
      await remove(store.storeId, syncRemote: existing.syncRemote);
      return;
    }
    await add(store);
  }

  Future<void> add(FavoriteStoreModel store) async {
    if (store.storeId <= 0 || isFavorite(store.storeId)) return;

    _favorites = [store, ..._favorites];
    _error = null;
    await _saveLocalFavorites(_favorites);
    notifyListeners();

    try {
      if (store.syncRemote) {
        if (_service == null) await init();
        await _service!.addFavorite(store.storeId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> remove(int storeId, {bool syncRemote = true}) async {
    if (storeId <= 0) return;

    _favorites.removeWhere((f) => f.storeId == storeId);
    _error = null;
    await _saveLocalFavorites(_favorites);
    notifyListeners();

    try {
      if (syncRemote) {
        if (_service == null) await init();
        await _service!.removeFavorite(storeId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  FavoriteStoreModel? _favoriteByStoreId(int storeId) {
    for (final favorite in _favorites) {
      if (favorite.storeId == storeId) return favorite;
    }
    return null;
  }

  List<FavoriteStoreModel> _mergeFavorites(
    List<FavoriteStoreModel> localFavorites,
    List<FavoriteStoreModel> remoteFavorites,
  ) {
    final merged = <FavoriteStoreModel>[];
    final seen = <int>{};

    for (final favorite in localFavorites) {
      if (favorite.storeId <= 0 || seen.contains(favorite.storeId)) continue;
      if (favorite.syncRemote &&
          !remoteFavorites
              .any((remote) => remote.storeId == favorite.storeId)) {
        continue;
      }
      merged.add(favorite);
      seen.add(favorite.storeId);
    }

    for (final favorite in remoteFavorites) {
      if (favorite.storeId <= 0 || seen.contains(favorite.storeId)) continue;
      merged.add(favorite);
      seen.add(favorite.storeId);
    }

    return merged;
  }

  Future<List<FavoriteStoreModel>> _loadLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localFavoritesKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) =>
              FavoriteStoreModel.fromLocalJson(e as Map<String, dynamic>))
          .where((favorite) => favorite.storeId > 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocalFavorites(List<FavoriteStoreModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      favorites.map((favorite) => favorite.toLocalJson()).toList(),
    );
    await prefs.setString(_localFavoritesKey, encoded);
  }
}
