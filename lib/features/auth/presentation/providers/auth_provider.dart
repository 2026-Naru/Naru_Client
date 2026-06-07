import 'package:flutter/material.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/token_storage.dart';
import '../../data/auth_remote_repository.dart';
import '../../domain/auth_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthRemoteRepository? _repo;
  TokenStorage? _storage;

  AuthStatus _status = AuthStatus.initial;
  AuthModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> init() async {
    final storage = await TokenStorage.getInstance();
    final api = await ApiClient.getInstance();
    _storage = storage;
    _repo = AuthRemoteRepository(api, storage);

    if (storage.isLoggedIn) {
      _user = AuthModel(
        email: storage.getUserEmail() ?? '',
        username: storage.getUserName(),
        token: storage.getToken()!,
      );
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo!.login(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is AppException && e.statusCode == 401
          ? '존재하지 않은 이메일 또는 비밀번호 입니다'
          : e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repo!.signup(email, username, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage?.clear();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
