import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/couple_model.dart';

class CoupleRepository {
  final FirebaseFirestore _firestore;

  CoupleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return List.generate(6, (index) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<CoupleModel> createCouple(String userId) async {
    // 1. Buat coupleId baru
    final coupleRef = _firestore.collection('couples').doc();
    final coupleId = coupleRef.id;

    // 2. Generate invite code unik
    String inviteCode = _generateInviteCode();
    bool codeExists = true;
    while (codeExists) {
      final inviteDoc = await _firestore.collection('invites').doc(inviteCode).get();
      if (!inviteDoc.exists) {
        codeExists = false;
      } else {
        inviteCode = _generateInviteCode();
      }
    }

    final now = Timestamp.now();
    final couple = CoupleModel(
      coupleId: coupleId,
      memberA: userId,
      memberB: null,
      inviteCode: inviteCode,
      createdAt: now,
    );

    // 3. Transaksi Firestore untuk atomitas
    await _firestore.runTransaction((transaction) async {
      // Simpan couple
      transaction.set(coupleRef, couple.toMap());

      // Simpan index invite code
      final inviteRef = _firestore.collection('invites').doc(inviteCode);
      transaction.set(inviteRef, {'coupleId': coupleId});

      // Update user coupleId
      final userRef = _firestore.collection('users').doc(userId);
      transaction.update(userRef, {'coupleId': coupleId});
    });

    return couple;
  }

  Future<CoupleModel> joinCouple(String userId, String inviteCode) async {
    final cleanCode = inviteCode.trim().toUpperCase();

    // 1. Cari invite code di koleksi invites
    final inviteDoc = await _firestore.collection('invites').doc(cleanCode).get();
    if (!inviteDoc.exists || inviteDoc.data() == null) {
      throw Exception('Kode undangan tidak valid atau tidak ditemukan');
    }

    final coupleId = inviteDoc.data()!['coupleId'] as String;
    final coupleRef = _firestore.collection('couples').doc(coupleId);
    final userRef = _firestore.collection('users').doc(userId);

    // 2. Baca data couple
    final coupleSnapshot = await coupleRef.get();
    if (!coupleSnapshot.exists || coupleSnapshot.data() == null) {
      throw Exception('Data couple tidak ditemukan');
    }

    final couple = CoupleModel.fromMap(coupleId, coupleSnapshot.data()!);

    if (couple.isFull) {
      throw Exception('Couple space ini sudah penuh (berisi 2 orang)');
    }

    if (couple.memberA == userId) {
      throw Exception('Anda tidak dapat bergabung dengan couple Anda sendiri');
    }

    // 3. Update data secara langsung (bukan transaction agar toleran jaringan)
    await coupleRef.update({'memberB': userId});
    await userRef.update({'coupleId': coupleId});

    return couple.copyWith(memberB: userId);
  }

  Future<CoupleModel?> getCouple(String coupleId) async {
    final doc = await _firestore.collection('couples').doc(coupleId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CoupleModel.fromMap(doc.id, doc.data()!);
  }
}
