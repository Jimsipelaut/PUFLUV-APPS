import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String uid;
  final String tag;
  final Timestamp updatedAt;

  ReactionModel({
    required this.uid,
    required this.tag,
    required this.updatedAt,
  });

  factory ReactionModel.fromMap(String uid, Map<String, dynamic> data) {
    return ReactionModel(
      uid: uid,
      tag: data['tag'] as String? ?? '',
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'updatedAt': updatedAt,
    };
  }
}
