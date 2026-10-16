import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/important_date_model.dart';

class DateRepository {
  final FirebaseFirestore _firestore;

  DateRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ImportantDateModel>> observeDates({required String coupleId}) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('importantDates')
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ImportantDateModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addDate({
    required String coupleId,
    required String title,
    required String date, // yyyy-MM-dd
    required bool recurring,
  }) async {
    final ref = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('importantDates')
        .doc();

    final dateModel = ImportantDateModel(
      dateId: ref.id,
      title: title.trim(),
      date: date,
      recurring: recurring,
      createdAt: Timestamp.now(),
    );

    await ref.set(dateModel.toMap());
  }

  Future<void> updateDate({
    required String coupleId,
    required String dateId,
    required String title,
    required String date,
    required bool recurring,
  }) async {
    final ref = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('importantDates')
        .doc(dateId);

    await ref.update({
      'title': title.trim(),
      'date': date,
      'recurring': recurring,
    });
  }

  Future<void> deleteDate({
    required String coupleId,
    required String dateId,
  }) async {
    final ref = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('importantDates')
        .doc(dateId);

    await ref.delete();
  }
}
