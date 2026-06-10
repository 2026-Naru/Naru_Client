import '../../../core/services/api_client.dart';
import '../../../core/exceptions/app_exception.dart';
import 'models/viewed_store_model.dart';

class StoreHistoryService {
  final ApiClient _api;

  StoreHistoryService(this._api);

  static const _historyPaths = [
    '/users/me/store-history',
    '/users/me/viewed-stores',
    '/users/me/history',
  ];

  Future<List<ViewedStoreModel>> fetchViewedStores() async {
    AppException? lastError;
    for (final path in _historyPaths) {
      try {
        final res = await _api.get(path);
        final list = res['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => ViewedStoreModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } on AppException catch (e) {
        if (e.statusCode == 401) rethrow;
        lastError = e;
      }
    }
    throw lastError ?? const AppException('최근 본 가게를 불러오지 못했습니다.');
  }

  Future<void> recordViewedStore(int storeId) async {
    AppException? lastError;
    for (final path in _historyPaths) {
      try {
        await _api.post(path, data: {'storeId': storeId});
        return;
      } on AppException catch (e) {
        if (e.statusCode == 401) rethrow;
        lastError = e;
      }
    }
    throw lastError ?? const AppException('최근 본 가게를 저장하지 못했습니다.');
  }
}
