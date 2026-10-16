import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puvluf/data/model/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('fromMap should construct UserModel properly', () {
      final now = Timestamp.now();
      final map = {
        'name': 'Pashya',
        'email': 'pashya@example.com',
        'coupleId': 'cid_123',
        'createdAt': now,
      };

      final user = UserModel.fromMap('uid_123', map);

      expect(user.uid, 'uid_123');
      expect(user.name, 'Pashya');
      expect(user.email, 'pashya@example.com');
      expect(user.coupleId, 'cid_123');
      expect(user.createdAt, now);
    });

    test('toMap should convert UserModel to map correctly', () {
      final now = Timestamp.now();
      final user = UserModel(
        uid: 'uid_123',
        name: 'Pashya',
        email: 'pashya@example.com',
        coupleId: null,
        createdAt: now,
      );

      final map = user.toMap();

      expect(map['name'], 'Pashya');
      expect(map['email'], 'pashya@example.com');
      expect(map['coupleId'], isNull);
      expect(map['createdAt'], now);
    });

    test('copyWith should preserve unchanged fields', () {
      final now = Timestamp.now();
      final user = UserModel(
        uid: 'uid_123',
        name: 'Pashya',
        email: 'pashya@example.com',
        coupleId: null,
        createdAt: now,
      );

      final updated = user.copyWith(coupleId: 'new_cid');

      expect(updated.uid, 'uid_123');
      expect(updated.name, 'Pashya');
      expect(updated.email, 'pashya@example.com');
      expect(updated.coupleId, 'new_cid');
      expect(updated.createdAt, now);
    });
  });
}
