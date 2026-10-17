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
        await imageFile.writeAsBytes(bytes, flush: true);

        // Pastikan izin file bisa dibaca oleh proses sistem Android / Launcher
        try {
          await Process.run('chmod', ['644', imageFile.path]);
        } catch (_) {}

        await HomeWidget.saveWidgetData<String>(
          'partner_image_path',
          imageFile.absolute.path,
        );
      } else {
        await HomeWidget.saveWidgetData<String>('partner_image_path', null);
      }

      // 2. Simpan Caption & Mood / Time ago
      if (partnerMoment != null) {
        await HomeWidget.saveWidgetData<String>(
          'partner_caption',
          partnerMoment.caption.isNotEmpty ? partnerMoment.caption : 'Moment baru',
        );

        final diff = DateTime.now().difference(partnerMoment.updatedAt.toDate());
        String timeAgo = diff.inMinutes < 60
            ? '${diff.inMinutes} mnt lalu'
            : (diff.inHours < 24 ? '${diff.inHours} jam lalu' : '${diff.inDays} hr lalu');
        final moodSuffix = partnerMoment.mood != null ? ' · ${partnerMoment.mood}' : '';

        await HomeWidget.saveWidgetData<String>(
          'partner_time_ago',
          '$timeAgo$moodSuffix',
        );
      } else {
        await HomeWidget.saveWidgetData<String>('partner_caption', null);
        await HomeWidget.saveWidgetData<String>('partner_time_ago', null);
      }

      // 3. Simpan Countdown Terdekat (hanya daysUntil >= 0)
      if (dates != null && dates.isNotEmpty) {
        final now = DateTime.now();
        final upcoming = dates.where((d) => d.daysUntil(now) >= 0).toList()
          ..sort((a, b) => a.daysUntil(now).compareTo(b.daysUntil(now)));

        if (upcoming.isNotEmpty) {
          final nearest = upcoming.first;
          final days = nearest.daysUntil(now);
          await HomeWidget.saveWidgetData<String>(
            'nearest_event_title',
            nearest.title.toUpperCase(),
          );
          await HomeWidget.saveWidgetData<String>(
            'nearest_countdown_number',
            '$days',
          );
          await HomeWidget.saveWidgetData<String>(
            'nearest_countdown_label',
            days == 0 ? 'hari ini' : 'hari lagi',
          );
        } else {
          await HomeWidget.saveWidgetData<String>('nearest_event_title', null);
          await HomeWidget.saveWidgetData<String>('nearest_countdown_number', null);
          await HomeWidget.saveWidgetData<String>('nearest_countdown_label', null);
        }
      } else {
        await HomeWidget.saveWidgetData<String>('nearest_event_title', null);
        await HomeWidget.saveWidgetData<String>('nearest_countdown_number', null);
        await HomeWidget.saveWidgetData<String>('nearest_countdown_label', null);
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
      await HomeWidget.saveWidgetData<String>('partner_time_ago', null);
      await HomeWidget.saveWidgetData<String>('nearest_event_title', null);
      await HomeWidget.saveWidgetData<String>('nearest_countdown_number', null);
      await HomeWidget.saveWidgetData<String>('nearest_countdown_label', null);

      await HomeWidget.updateWidget(androidName: androidWidgetProvider);
      debugPrint('[WidgetSyncManager] Widget data cleared on logout.');
    } catch (e) {
      debugPrint('[WidgetSyncManager] Failed to clear widget data: $e');
    }
  }
}
