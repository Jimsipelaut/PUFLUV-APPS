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

  /// Menghitung tanggal kemunculan berikutnya (D-07, D-08, M9)
  DateTime nextOccurrence(DateTime today) {
    if (date.isEmpty) return today;
    try {
      final parsed = DateFormat('yyyy-MM-dd').parseStrict(date);
      final todayDate = DateTime(today.year, today.month, today.day);

      if (!recurring) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }

      // Jika tahun awal recurring di masa depan, gunakan tanggal awal tersebut
      if (DateTime(parsed.year, parsed.month, parsed.day).isAfter(todayDate)) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }

      // Recurring tahunan: tangani kabisat 29 Februari (D-07 -> 28 Feb di tahun non-kabisat)
      DateTime makeOccurrence(int year, int month, int day) {
        if (month == 2 && day == 29) {
          final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
          return isLeapYear ? DateTime(year, 2, 29) : DateTime(year, 2, 28);
        }
        return DateTime(year, month, day);
      }

      var occurrence = makeOccurrence(today.year, parsed.month, parsed.day);
      if (occurrence.isBefore(todayDate)) {
        occurrence = makeOccurrence(today.year + 1, parsed.month, parsed.day);
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
