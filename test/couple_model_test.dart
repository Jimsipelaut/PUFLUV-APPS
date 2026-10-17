import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puvluf/data/model/couple_model.dart';

void main() {
  group('CoupleModel Tests', () {
    test('isFull should return true when both members are present', () {
      final couple = CoupleModel(
        coupleId: 'cid_1',
        memberA: 'user_1',
        memberB: 'user_2',
        inviteCode: 'ABC123',
        createdAt: Timestamp.now(),
      );

      expect(couple.isFull, true);
    });

    test('isFull should return false when memberB is null or empty', () {
      final couple = CoupleModel(
        coupleId: 'cid_1',
        memberA: 'user_1',
        memberB: null,
        inviteCode: 'ABC123',
        createdAt: Timestamp.now(),
      );

      expect(couple.isFull, false);
    });

    test('fromMap and toMap conversion', () {
      final now = Timestamp.now();
      final map = {
        'memberA': 'user_1',
        'memberB': 'user_2',
        'inviteCode': 'XYZ789',
        'createdAt': now,
      };

      final couple = CoupleModel.fromMap('cid_99', map);

      expect(couple.coupleId, 'cid_99');
      expect(couple.memberA, 'user_1');
      expect(couple.memberB, 'user_2');
      expect(couple.inviteCode, 'XYZ789');

      final exported = couple.toMap();
      expect(exported['memberA'], 'user_1');
      expect(exported['memberB'], 'user_2');
      expect(exported['inviteCode'], 'XYZ789');
    });
  });
}
