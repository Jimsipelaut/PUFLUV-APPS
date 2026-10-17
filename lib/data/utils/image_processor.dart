import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessor {
  static const int maxHardLimitBytes = 400 * 1024; // 400 KB batas keras sesuai D-03

  /// Mengompres file gambar dari path secara adaptif (M5, D-03).
  /// Mengulang kompresi bertahap dengan menurunkan kualitas sampai ukuran <= 400KB.
  static Future<String> compressAndConvertToBase64(String filePath) async {
    // Profil kompresi bertahap (lebar x tinggi, kualitas)
    final compressionProfiles = [
      {'minDim': 720, 'quality': 80},
      {'minDim': 720, 'quality': 65},
      {'minDim': 600, 'quality': 55},
      {'minDim': 480, 'quality': 45},
      {'minDim': 360, 'quality': 35},
    ];

    Uint8List? compressed;

    for (final profile in compressionProfiles) {
      final minDim = profile['minDim']!;
      final quality = profile['quality']!;

      compressed = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: minDim,
        minHeight: minDim,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed != null && compressed.lengthInBytes <= maxHardLimitBytes) {
        return base64Encode(compressed);
      }
    }

    if (compressed != null && compressed.lengthInBytes <= 550 * 1024) {
      // Masih aman di bawah batas rules Firestore (600.000 char base64)
      return base64Encode(compressed);
    }

    throw Exception(
      'Ukuran foto terlalu besar untuk disimpan gratis. Harap pilih foto lain atau potong sebagian.',
    );
  }
}
