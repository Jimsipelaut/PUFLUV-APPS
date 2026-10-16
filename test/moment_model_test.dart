import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puvluf/data/model/moment_model.dart';

void main() {
  group('MomentModel Tests', () {
    test('fromMap should construct MomentModel properly', () {
      final now = Timestamp.now();
      final map = {
        'photoBase64': 'base64string',
        'caption': 'Hari ini indah',
        'mood': 'happy',
        'updatedAt': now,
      };

      final moment = MomentModel.fromMap('uid_123', map);

      expect(moment.uid, 'uid_123');
      expect(moment.photoBase64, 'base64string');
      expect(moment.caption, 'Hari ini indah');
      expect(moment.mood, 'happy');
      expect(moment.updatedAt, now);
    });

    test('toMap should convert MomentModel correctly', () {
      final now = Timestamp.now();
      final moment = MomentModel(
        uid: 'uid_123',
        photoBase64: 'base64string',
        caption: 'Caption test',
        mood: null,
        updatedAt: now,
      );

      final map = moment.toMap();

      expect(map['photoBase64'], 'base64string');
      expect(map['caption'], 'Caption test');
      expect(map['mood'], isNull);
      expect(map['updatedAt'], now);
    });

    test('copyWith should preserve unchanged fields', () {
      final now = Timestamp.now();
      final moment = MomentModel(
        uid: 'uid_123',
        photoBase64: 'old_base64',
        caption: 'old caption',
        updatedAt: now,
      );

      final updated = moment.copyWith(caption: 'new caption');

      expect(updated.uid, 'uid_123');
      expect(updated.photoBase64, 'old_base64');
      expect(updated.caption, 'new caption');
    });
  });
}
