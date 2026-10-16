import 'package:flutter/foundation.dart';
import '../../data/repository/date_repository.dart';

class DateProvider with ChangeNotifier {
  final DateRepository _repository;

  DateProvider({DateRepository? repository})
      : _repository = repository ?? DateRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addDate({
    required String coupleId,
    required String title,
    required String date,
    required bool recurring,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.addDate(
        coupleId: coupleId,
        title: title,
        date: date,
        recurring: recurring,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDate({
    required String coupleId,
    required String dateId,
    required String title,
    required String date,
    required bool recurring,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateDate(
        coupleId: coupleId,
        dateId: dateId,
        title: title,
        date: date,
        recurring: recurring,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDate({
    required String coupleId,
    required String dateId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteDate(coupleId: coupleId, dateId: dateId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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
}
