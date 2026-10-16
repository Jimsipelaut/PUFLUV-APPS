import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleModel {
  final String coupleId;
  final String memberA;
  final String memberB;
  final String inviteCode;
  final Timestamp createdAt;

  CoupleModel({
    required this.coupleId,
    required this.memberA,
    required this.memberB,
    required this.inviteCode,
    required this.createdAt,
  });

  bool get isFull => memberA.isNotEmpty && memberB.isNotEmpty;

  factory CoupleModel.fromMap(String coupleId, Map<String, dynamic> data) {
    return CoupleModel(
      coupleId: coupleId,
      memberA: data['memberA'] as String? ?? '',
      memberB: data['memberB'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberA': memberA,
      'memberB': memberB,
      'inviteCode': inviteCode,
      'createdAt': createdAt,
    };
  }

  CoupleModel copyWith({
    String? coupleId,
    String? memberA,
    String? memberB,
    String? inviteCode,
    Timestamp? createdAt,
  }) {
    return CoupleModel(
      coupleId: coupleId ?? this.coupleId,
      memberA: memberA ?? this.memberA,
      memberB: memberB ?? this.memberB,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
