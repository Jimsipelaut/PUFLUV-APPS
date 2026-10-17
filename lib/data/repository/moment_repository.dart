import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/moment_model.dart';

class MomentRepository {
  final FirebaseFirestore _firestore;

  MomentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveMoment({
    required String coupleId,
    required String uid,
    required String photoBase64,
    required String caption,
    String? mood,
  }) async {
    final momentRef = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('moments')
        .doc(uid);

    final moment = MomentModel(
      uid: uid,
      photoBase64: photoBase64,
      caption: caption,
      mood: mood,
      updatedAt: Timestamp.now(),
    );

    // D-04: Menimpa dokumen moments/{uid} secara atomik tanpa merge flag
    await momentRef.set(moment.toMap());
  }

  /// Update caption dan/atau mood saja tanpa upload ulang data foto (M8)
  Future<void> updateCaptionOrMood({
    required String coupleId,
    required String uid,
    required String caption,
    String? mood,
  }) async {
    final momentRef = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('moments')
        .doc(uid);

    await momentRef.update({
      'caption': caption,
      if (mood != null) 'mood': mood,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<MomentModel?> getMoment({
    required String coupleId,
    required String uid,
  }) async {
    final doc = await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('moments')
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return MomentModel.fromMap(doc.id, doc.data()!);
  }

  Stream<MomentModel?> observeMoment({
    required String coupleId,
    required String uid,
  }) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('moments')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return MomentModel.fromMap(doc.id, doc.data()!);
    });
  }

  Stream<List<MomentModel>> observeCoupleMoments({
    required String coupleId,
  }) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('moments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
