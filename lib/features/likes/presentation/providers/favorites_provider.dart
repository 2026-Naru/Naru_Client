import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../data/favorites_service.dart';
import '../../data/models/favorite_store_model.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesService? _service;

  List<FavoriteStoreModel> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<FavoriteStoreModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favorites.length;

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = FavoritesService(api);
  }

  Future<void> fetch() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _service!.fetchFavorites();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> remove(int storeId) async {
    if (_service == null) return;
    try {
      await _service!.removeFavorite(storeId);
      _favorites.removeWhere((f) => f.storeId == storeId);
      notifyListeners();
    } catch (_) {}
  }
}
