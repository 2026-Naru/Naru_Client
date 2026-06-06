import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserService? _service;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = UserService(api);
  }

  Future<void> fetch() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service!.fetchMe();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
