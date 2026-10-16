import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ImportantDateModel {
  final String dateId;
  final String title;
  final String date; // format: yyyy-MM-dd (D-07)
  final bool recurring;
  final Timestamp createdAt;

  ImportantDateModel({
    required this.dateId,
    required this.title,
    required this.date,
    required this.recurring,
    required this.createdAt,
  });

  factory ImportantDateModel.fromMap(String dateId, Map<String, dynamic> data) {
    return ImportantDateModel(
      dateId: dateId,
      title: data['title'] as String? ?? '',
      date: data['date'] as String? ?? '',
      recurring: data['recurring'] as bool? ?? false,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'recurring': recurring,
      'createdAt': createdAt,
    };
  }

  ImportantDateModel copyWith({
    String? dateId,
    String? title,
    String? date,
    bool? recurring,
    Timestamp? createdAt,
  }) {
    return ImportantDateModel(
      dateId: dateId ?? this.dateId,
      title: title ?? this.title,
      date: date ?? this.date,
      recurring: recurring ?? this.recurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Menghitung tanggal kemunculan berikutnya (tahun ini atau tahun depan jika recurring)
  DateTime nextOccurrence(DateTime today) {
    if (date.isEmpty) return today;
    try {
      final parsed = DateFormat('yyyy-MM-dd').parseStrict(date);
      if (!recurring) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }
      // Recurring: setiap tahun di bulan & hari yang sama
      var occurrence = DateTime(today.year, parsed.month, parsed.day);
      if (occurrence.isBefore(DateTime(today.year, today.month, today.day))) {
        occurrence = DateTime(today.year + 1, parsed.month, parsed.day);
      }
      return occurrence;
    } catch (_) {
      return today;
    }
  }

  /// Selisih hari dari today ke nextOccurrence
  int daysUntil(DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final next = nextOccurrence(today);
    final nextDate = DateTime(next.year, next.month, next.day);
    return nextDate.difference(todayDate).inDays;
  }
}
