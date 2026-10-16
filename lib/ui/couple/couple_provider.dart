import 'package:flutter/foundation.dart';
import '../../data/model/couple_model.dart';
import '../../data/model/user_model.dart';
import '../../data/repository/couple_repository.dart';

class CoupleProvider with ChangeNotifier {
  final CoupleRepository _repository;

  CoupleProvider({CoupleRepository? repository})
      : _repository = repository ?? CoupleRepository();

  CoupleModel? _couple;
  bool _isLoading = false;
  String? _errorMessage;

  CoupleModel? get couple => _couple;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createCouple(UserModel user) async {
    _setLoading(true);
    _clearError();

    try {
      _couple = await _repository.createCouple(user.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinCouple(UserModel user, String inviteCode) async {
    _setLoading(true);
    _clearError();

    try {
      _couple = await _repository.joinCouple(user.uid, inviteCode);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCouple(String coupleId) async {
    _setLoading(true);
    try {
      _couple = await _repository.getCouple(coupleId);
      notifyListeners();
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

  String _parseError(dynamic error) {
    final msg = error.toString();
    debugPrint('[CoupleProvider] Error details: $msg');
    if (msg.contains('tidak valid') || msg.contains('tidak ditemukan')) {
      return 'Kode undangan tidak valid';
    } else if (msg.contains('sudah penuh')) {
      return 'Couple space ini sudah penuh';
    } else if (msg.contains('sendiri')) {
      return 'Anda tidak dapat bergabung dengan couple Anda sendiri';
    } else if (msg.contains('permission-denied') || msg.contains('PERMISSION_DENIED')) {
      return 'Izin ditolak oleh server (Firestore Rules)';
    }
    return 'Gagal: $msg';
  }
}
