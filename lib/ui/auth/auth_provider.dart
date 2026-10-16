import 'package:flutter/foundation.dart';
import '../../data/model/user_model.dart';
import '../../data/repository/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentFirebaseUser = _repository.currentFirebaseUser;
      if (currentFirebaseUser != null) {
        _user = await _repository.getUserProfile(currentFirebaseUser.uid);
        _status = (_user != null) ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _user = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseAuthError(dynamic error) {
    final msg = error.toString();
    debugPrint('AUTH ERROR DETAILS: $msg'); // <-- Log error asli untuk debugging
    if (msg.contains('user-not-found') || msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Email atau password salah';
    } else if (msg.contains('email-already-in-use')) {
      return 'Email ini sudah terdaftar';
    } else if (msg.contains('weak-password')) {
      return 'Password minimal 6 karakter';
    } else if (msg.contains('invalid-email')) {
      return 'Format email tidak valid';
    } else if (msg.contains('network-request-failed')) {
      return 'Gagal terhubung ke jaringan';
    }
    return 'Error: $msg';
  }
}
