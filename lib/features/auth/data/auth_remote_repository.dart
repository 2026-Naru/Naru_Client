import '../../../core/services/api_client.dart';
import '../../../core/services/token_storage.dart';
import '../domain/auth_model.dart';
import 'auth_repository.dart';

class AuthRemoteRepository implements AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRemoteRepository(this._api, this._storage);

  @override
  Future<AuthModel> login(String email, String password) async {
    final res = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await _storage.saveToken(token);
    await _storage.saveUser(
      email: user['email'] as String? ?? email,
      name: user['name'] as String? ?? '',
    );

    return AuthModel(
      email: user['email'] as String? ?? email,
      username: user['name'] as String?,
      token: token,
    );
  }

  @override
  Future<AuthModel> signup(
      String email, String username, String password) async {
    final res = await _api.post('/auth/signup', data: {
      'email': email,
      'name': username,
      'password': password,
    });
    final data = res['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await _storage.saveToken(token);
    await _storage.saveUser(
      email: user['email'] as String? ?? email,
      name: user['name'] as String? ?? username,
    );

    return AuthModel(
      email: user['email'] as String? ?? email,
      username: user['name'] as String? ?? username,
      token: token,
    );
  }
}
