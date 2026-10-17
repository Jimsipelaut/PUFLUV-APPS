import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/reaction_model.dart';

class ReactionRepository {
  final FirebaseFirestore _firestore;

  ReactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ReactionModel>> getReactionsStream(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('reactions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReactionModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> sendReaction({
    required String coupleId,
    required String uid,
    required String tag,
  }) async {
    final cleanTag = tag.trim().length > 16 ? tag.trim().substring(0, 16) : tag.trim();
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('reactions')
        .doc(uid)
        .set({
      'tag': cleanTag,
      'updatedAt': Timestamp.now(),
    });
  }
}
