import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../model/important_date_model.dart';
import '../model/moment_model.dart';

class WidgetSyncManager {
  static const String androidWidgetProvider = 'PufluvWidgetProvider';

  /// Sync data Moment Partner & Countdown ke Home Screen Widget native Android
  static Future<void> syncWidget({
    MomentModel? partnerMoment,
    List<ImportantDateModel>? dates,
  }) async {
    try {
      // 1. Simpan Foto Moment ke file lokal agar bisa dibaca RemoteViews Android
      if (partnerMoment != null && partnerMoment.photoBase64.isNotEmpty) {
        final bytes = base64Decode(partnerMoment.photoBase64);
        final tempDir = await getApplicationSupportDirectory();
        final imageFile = File('${tempDir.path}/partner_moment_widget.jpg');
        await imageFile.writeAsBytes(bytes);

        await HomeWidget.saveWidgetData<String>(
          'partner_image_path',
          imageFile.absolute.path,
        );
      } else {
        await HomeWidget.saveWidgetData<String>('partner_image_path', null);
      }

      // 2. Simpan Caption & Mood
      if (partnerMoment != null && partnerMoment.caption.isNotEmpty) {
        final moodPrefix = partnerMoment.mood != null ? '${partnerMoment.mood} ' : '';
        await HomeWidget.saveWidgetData<String>(
          'partner_caption',
          '$moodPrefix${partnerMoment.caption}',
        );
      } else {
        await HomeWidget.saveWidgetData<String>('partner_caption', null);
      }

      // 3. Simpan Countdown Terdekat (hanya daysUntil >= 0)
      if (dates != null && dates.isNotEmpty) {
        final now = DateTime.now();
        final upcoming = dates.where((d) => d.daysUntil(now) >= 0).toList()
          ..sort((a, b) => a.daysUntil(now).compareTo(b.daysUntil(now)));

        if (upcoming.isNotEmpty) {
          final nearest = upcoming.first;
          final days = nearest.daysUntil(now);
          final text = days == 0 ? 'Hari ini: ${nearest.title}' : '$days hr: ${nearest.title}';
          await HomeWidget.saveWidgetData<String>('nearest_countdown', text);
        } else {
          await HomeWidget.saveWidgetData<String>('nearest_countdown', null);
        }
      } else {
        await HomeWidget.saveWidgetData<String>('nearest_countdown', null);
      }

      // 4. Minta sistem Android update UI AppWidget
      await HomeWidget.updateWidget(
        androidName: androidWidgetProvider,
      );
      debugPrint('[WidgetSyncManager] Native widget successfully updated!');
    } catch (e, stack) {
      debugPrint('[WidgetSyncManager] Failed to sync widget: $e\n$stack');
    }
  }

  /// Menghapus seluruh data widget dan file foto lokal saat pengguna logout (H6)
  static Future<void> clearWidgetData() async {
    try {
      final savedPath = await HomeWidget.getWidgetData<String>('partner_image_path');
      if (savedPath != null) {
        final f = File(savedPath);
        if (await f.exists()) {
          await f.delete();
        }
      }

      await HomeWidget.saveWidgetData<String>('partner_image_path', null);
      await HomeWidget.saveWidgetData<String>('partner_caption', null);
      await HomeWidget.saveWidgetData<String>('nearest_countdown', null);

      await HomeWidget.updateWidget(androidName: androidWidgetProvider);
      debugPrint('[WidgetSyncManager] Widget data cleared on logout.');
    } catch (e) {
      debugPrint('[WidgetSyncManager] Failed to clear widget data: $e');
    }
  }
}
