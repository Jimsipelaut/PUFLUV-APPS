import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessor {
  /// Mengompres file gambar dari path, resize max 720px, kualitas 80,
  /// lalu mengonversinya menjadi string Base64.
  static Future<String> compressAndConvertToBase64(String filePath) async {
    final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 720,
      minHeight: 720,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (compressedBytes == null) {
      throw Exception('Gagal mengompresi gambar');
    }

    // Pastikan ukuran tidak melebihi batas keras Firestore 1MB (target < 400KB)
    if (compressedBytes.lengthInBytes > 400 * 1024) {
      // Kompres ulang dengan kualitas lebih rendah jika masih > 400KB
      final Uint8List? deeperCompressed = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 600,
        minHeight: 600,
        quality: 60,
        format: CompressFormat.jpeg,
      );
      if (deeperCompressed != null) {
        return base64Encode(deeperCompressed);
      }
    }

    return base64Encode(compressedBytes);
  }
}
