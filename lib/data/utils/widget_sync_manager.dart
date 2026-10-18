import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../model/important_date_model.dart';
import '../model/moment_model.dart';

class WidgetSyncManager {
  static const String androidWidgetProvider = 'PufluvWidgetProvider';

  /// Sync data Moment (prioritas partner, fallback myMoment) & Countdown ke Home Screen Widget native Android
  static Future<void> syncWidget({
    MomentModel? partnerMoment,
    MomentModel? myMoment,
    List<ImportantDateModel>? dates,
  }) async {
    try {
      final activeMoment = partnerMoment ?? myMoment;
      final isSelf = partnerMoment == null && myMoment != null;

      // 1. Simpan Foto Moment ke file lokal agar bisa dibaca RemoteViews Android
      if (activeMoment != null && activeMoment.photoBase64.isNotEmpty) {
        final cleanBase64 = activeMoment.photoBase64.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);
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
      if (activeMoment != null) {
        final baseCaption = activeMoment.caption.isNotEmpty ? activeMoment.caption : 'Moment baru';
        final displayCaption = isSelf ? '$baseCaption (Kamu)' : baseCaption;
        await HomeWidget.saveWidgetData<String>(
          'partner_caption',
          displayCaption,
        );

        final diff = DateTime.now().difference(activeMoment.updatedAt.toDate());
        String timeAgo = diff.inMinutes < 60
            ? '${diff.inMinutes} mnt lalu'
            : (diff.inHours < 24 ? '${diff.inHours} jam lalu' : '${diff.inDays} hr lalu');
        final moodSuffix = activeMoment.mood != null ? ' · ${activeMoment.mood}' : '';

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
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
        qualifiedAndroidName: 'com.pufluv.app.$androidWidgetProvider',
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

      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
        qualifiedAndroidName: 'com.pufluv.app.$androidWidgetProvider',
      );
      debugPrint('[WidgetSyncManager] Widget data cleared on logout.');
    } catch (e) {
      debugPrint('[WidgetSyncManager] Failed to clear widget data: $e');
    }
  }
}
