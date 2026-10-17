import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puvluf/data/model/important_date_model.dart';

void main() {
  group('ImportantDateModel Tests', () {
    test('fromMap and toMap conversion', () {
      final now = Timestamp.now();
      final map = {
        'title': 'Anniversary',
        'date': '2026-10-25',
        'recurring': true,
        'createdAt': now,
      };

      final item = ImportantDateModel.fromMap('date_1', map);

      expect(item.dateId, 'date_1');
      expect(item.title, 'Anniversary');
      expect(item.date, '2026-10-25');
      expect(item.recurring, true);

      final exported = item.toMap();
      expect(exported['title'], 'Anniversary');
      expect(exported['date'], '2026-10-25');
      expect(exported['recurring'], true);
    });

    test('daysUntil calculation for non-recurring date', () {
      final today = DateTime(2026, 10, 20);
      final item = ImportantDateModel(
        dateId: '1',
        title: 'Event',
        date: '2026-10-25',
        recurring: false,
        createdAt: Timestamp.now(),
      );

      expect(item.daysUntil(today), 5);
    });

    test('non-recurring past date returns negative daysUntil', () {
      final today = DateTime(2026, 10, 20);
      final pastItem = ImportantDateModel(
        dateId: '2',
        title: 'Past Event',
        date: '2026-10-15',
        recurring: false,
        createdAt: Timestamp.now(),
      );

      expect(pastItem.daysUntil(today), -5);
    });

    test('recurring date occurrence crosses year correctly', () {
      final today = DateTime(2026, 10, 20);
      final recurringItem = ImportantDateModel(
        dateId: '3',
        title: 'Valentine',
        date: '2024-02-14',
        recurring: true,
        createdAt: Timestamp.now(),
      );

      final next = recurringItem.nextOccurrence(today);
      expect(next.year, 2027);
      expect(next.month, 2);
      expect(next.day, 14);
    });

    test('leap year 29 Feb recurring maps to 28 Feb in non-leap year (D-07)', () {
      final today = DateTime(2026, 1, 1);
      final leapItem = ImportantDateModel(
        dateId: '4',
        title: 'Leap Birthday',
        date: '2024-02-29',
        recurring: true,
        createdAt: Timestamp.now(),
      );

      // 2026 bukan tahun kabisat -> harus 28 Feb 2026
      final next2026 = leapItem.nextOccurrence(today);
      expect(next2026.year, 2026);
      expect(next2026.month, 2);
      expect(next2026.day, 28);
    });

    test('recurring date with first year in future stays in future year', () {
      final today = DateTime(2026, 10, 20);
      final futureItem = ImportantDateModel(
        dateId: '5',
        title: 'Future Wedding',
        date: '2028-06-15',
        recurring: true,
        createdAt: Timestamp.now(),
      );

      final next = futureItem.nextOccurrence(today);
      expect(next.year, 2028);
      expect(next.month, 6);
      expect(next.day, 15);
    });
  });
}
