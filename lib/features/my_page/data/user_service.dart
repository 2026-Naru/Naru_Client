import '../../../core/services/api_client.dart';
import 'models/user_model.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  Future<UserModel> fetchMe() async {
    final res = await _api.get('/users/me');
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<int> fetchCouponCount() async {
    final res = await _api.get('/users/me/coupons');
    final list = res['data'] as List<dynamic>? ?? const [];
    return list.length;
  }
}
