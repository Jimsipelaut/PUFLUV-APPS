import 'package:cloud_firestore/cloud_firestore.dart';

class MomentModel {
  final String uid;
  final String photoBase64;
  final String caption;
  final String? mood;
  final Timestamp updatedAt;

  MomentModel({
    required this.uid,
    required this.photoBase64,
    required this.caption,
    this.mood,
    required this.updatedAt,
  });

  factory MomentModel.fromMap(String uid, Map<String, dynamic> data) {
    return MomentModel(
      uid: uid,
      photoBase64: data['photoBase64'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      mood: data['mood'] as String?,
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoBase64': photoBase64,
      'caption': caption,
      'mood': mood,
      'updatedAt': updatedAt,
    };
  }

  MomentModel copyWith({
    String? uid,
    String? photoBase64,
    String? caption,
    String? mood,
    Timestamp? updatedAt,
  }) {
    return MomentModel(
      uid: uid ?? this.uid,
      photoBase64: photoBase64 ?? this.photoBase64,
      caption: caption ?? this.caption,
      mood: mood ?? this.mood,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
