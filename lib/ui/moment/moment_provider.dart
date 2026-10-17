import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repository/moment_repository.dart';
import '../../data/utils/image_processor.dart';

class MomentProvider with ChangeNotifier {
  final MomentRepository _repository;
  final ImagePicker _picker;

  MomentProvider({
    MomentRepository? repository,
    ImagePicker? picker,
  })  : _repository = repository ?? MomentRepository(),
        _picker = picker ?? ImagePicker();

  bool _isLoading = false;
  bool _isCompressing = false;
  String? _errorMessage;
  String? _selectedImageBase64;
  File? _selectedImageFile;

  bool get isLoading => _isLoading;
  bool get isCompressing => _isCompressing;
  String? get errorMessage => _errorMessage;
  String? get selectedImageBase64 => _selectedImageBase64;
  File? get selectedImageFile => _selectedImageFile;

  Future<void> pickImage(ImageSource source) async {
    _clearError();
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _isCompressing = true;
        notifyListeners();

        _selectedImageFile = File(pickedFile.path);
        _selectedImageBase64 = await ImageProcessor.compressAndConvertToBase64(pickedFile.path);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isCompressing = false;
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImageFile = null;
    _selectedImageBase64 = null;
    notifyListeners();
  }

  Future<bool> saveMoment({
    required String coupleId,
    required String uid,
    required String caption,
    String? existingPhotoBase64,
    String? mood,
  }) async {
    final photoToSave = _selectedImageBase64 ?? existingPhotoBase64;
    if (photoToSave == null || photoToSave.isEmpty) {
      _errorMessage = 'Foto belum dipilih';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.saveMoment(
        coupleId: coupleId,
        uid: uid,
        photoBase64: photoToSave,
        caption: caption,
        mood: mood,
      );
      clearSelectedImage();
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
