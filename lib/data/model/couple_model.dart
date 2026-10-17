import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleModel {
  final String coupleId;
  final String memberA;
  final String? memberB;
  final String inviteCode;
  final Timestamp createdAt;
  final List<dynamic>? reactionTags;

  CoupleModel({
    required this.coupleId,
    required this.memberA,
    this.memberB,
    required this.inviteCode,
    required this.createdAt,
    this.reactionTags,
  });

  bool get isFull => memberA.isNotEmpty && memberB != null && memberB!.isNotEmpty;

  factory CoupleModel.fromMap(String coupleId, Map<String, dynamic> data) {
    return CoupleModel(
      coupleId: coupleId,
      memberA: data['memberA'] as String? ?? '',
      memberB: data['memberB'] as String?,
      inviteCode: data['inviteCode'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      reactionTags: data['reactionTags'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberA': memberA,
      'memberB': memberB,
      'inviteCode': inviteCode,
      'createdAt': createdAt,
      if (reactionTags != null) 'reactionTags': reactionTags,
    };
  }

  CoupleModel copyWith({
    String? coupleId,
    String? memberA,
    String? memberB,
    String? inviteCode,
    Timestamp? createdAt,
    List<dynamic>? reactionTags,
  }) {
    return CoupleModel(
      coupleId: coupleId ?? this.coupleId,
      memberA: memberA ?? this.memberA,
      memberB: memberB ?? this.memberB,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      reactionTags: reactionTags ?? this.reactionTags,
    );
  }
}
