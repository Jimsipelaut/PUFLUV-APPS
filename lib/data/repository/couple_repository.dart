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
    final userRef = _firestore.collection('users').doc(userId);

    // 1. Validasi awal status user (BR-01, FR-03)
    final userSnap = await userRef.get();
    if (userSnap.exists && userSnap.data() != null) {
      final existingCid = userSnap.data()!['coupleId'] as String?;
      if (existingCid != null && existingCid.isNotEmpty) {
        throw Exception('Anda sudah terhubung ke dalam ruang couple');
      }
    }

    // 2. Buat coupleId baru
    final coupleRef = _firestore.collection('couples').doc();
    final coupleId = coupleRef.id;

    // 3. Generate invite code unik
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

    // 4. Transaksi Firestore untuk atomisitas (create couple + invite + user update)
    await _firestore.runTransaction((transaction) async {
      final uDoc = await transaction.get(userRef);
      if (uDoc.exists && uDoc.data() != null) {
        final cid = uDoc.data()!['coupleId'] as String?;
        if (cid != null && cid.isNotEmpty) {
          throw Exception('Anda sudah memiliki ruang couple');
        }
      }

      // Simpan couple
      transaction.set(coupleRef, couple.toMap());

      // Simpan index invite code
      final inviteRef = _firestore.collection('invites').doc(inviteCode);
      transaction.set(inviteRef, {'coupleId': coupleId});

      // Update user coupleId
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

    // 2. Jalankan runTransaction secara atomik (D-06, BR-01, FR-03)
    return await _firestore.runTransaction((transaction) async {
      // Baca user snapshot dalam transaksi
      final userSnap = await transaction.get(userRef);
      if (userSnap.exists && userSnap.data() != null) {
        final existingCid = userSnap.data()!['coupleId'] as String?;
        if (existingCid != null && existingCid.isNotEmpty) {
          throw Exception('Anda sudah terhubung ke dalam ruang couple lain');
        }
      }

      // Baca couple snapshot dalam transaksi
      final coupleSnapshot = await transaction.get(coupleRef);
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

      // Update couple slot memberB dan user coupleId secara atomik
      transaction.update(coupleRef, {'memberB': userId});
      transaction.update(userRef, {'coupleId': coupleId});

      return couple.copyWith(memberB: userId);
    });
  }

  Future<CoupleModel?> getCouple(String coupleId) async {
    final doc = await _firestore.collection('couples').doc(coupleId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CoupleModel.fromMap(doc.id, doc.data()!);
  }

  /// Update daftar custom reaction tags (D-16, maksimal 6 tag, panjang <= 16 karakter)
  Future<void> updateReactionTags(String coupleId, List<String> tags) async {
    final cleanTags = tags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(6)
        .toList();

    await _firestore.collection('couples').doc(coupleId).update({
      'reactionTags': cleanTags,
    });
  }
}
