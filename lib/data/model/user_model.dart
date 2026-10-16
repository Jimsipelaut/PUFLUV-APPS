import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? coupleId;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.coupleId,
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      coupleId: data['coupleId'] as String?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'coupleId': coupleId,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? coupleId,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      coupleId: coupleId ?? this.coupleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
