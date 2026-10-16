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
  });
}
