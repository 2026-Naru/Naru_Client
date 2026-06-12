import '../../../core/exceptions/app_exception.dart';
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
    final data = _mapFrom(res['data'], fallbackMessage: _messageFrom(res));
    final user = _mapFrom(data['user'], fallbackMessage: _messageFrom(data));
    final token = _stringFrom(data['token'], fallbackMessage: '로그인 토큰이 없습니다.');

    await _storage.saveToken(token);
    await _storage.saveUser(
      email: _optionalString(user['email']) ?? email,
      name: _optionalString(user['name']) ?? '',
    );

    return AuthModel(
      email: _optionalString(user['email']) ?? email,
      username: _optionalString(user['name']),
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
    final data = _mapFrom(res['data'], fallbackMessage: _messageFrom(res));
    final user = _mapFrom(data['user'], fallbackMessage: _messageFrom(data));
    final token = _stringFrom(data['token'], fallbackMessage: '회원가입 토큰이 없습니다.');

    await _storage.saveToken(token);
    await _storage.saveUser(
      email: _optionalString(user['email']) ?? email,
      name: _optionalString(user['name']) ?? username,
    );

    return AuthModel(
      email: _optionalString(user['email']) ?? email,
      username: _optionalString(user['name']) ?? username,
      token: token,
    );
  }

  Map<String, dynamic> _mapFrom(
    dynamic value, {
    required String fallbackMessage,
  }) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw AppException(
      value is String && value.trim().isNotEmpty
          ? value.trim()
          : fallbackMessage,
    );
  }

  String _stringFrom(dynamic value, {required String fallbackMessage}) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw AppException(fallbackMessage);
  }

  String _messageFrom(Map<String, dynamic> json) {
    final message = json['message'] ?? json['error'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    if (message != null) return message.toString();
    return '서버 응답 형식이 올바르지 않습니다.';
  }

  String? _optionalString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}
