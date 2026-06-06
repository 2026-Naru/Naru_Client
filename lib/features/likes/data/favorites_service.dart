import '../../../core/services/api_client.dart';
import 'models/favorite_store_model.dart';

class FavoritesService {
  final ApiClient _api;

  FavoritesService(this._api);

  Future<List<FavoriteStoreModel>> fetchFavorites() async {
    final res = await _api.get('/users/me/favorites');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => FavoriteStoreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(int storeId) async {
    await _api.post('/users/me/favorites', data: {'storeId': storeId});
  }

  Future<void> removeFavorite(int storeId) async {
    await _api.delete('/users/me/favorites/$storeId');
  }
}
