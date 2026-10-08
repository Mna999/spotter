import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';

class UserAccountModel extends UserAccount {
  UserAccountModel({
    required super.createdAt,
    required super.displayName,
    required super.email,
    required super.uid,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserAccountModel.fromFirebaseUser(User user) {
    return UserAccountModel(
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      uid: user.uid,
    );
  }

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      displayName: json['displayName'],
      email: json['email'],
      uid: json['uid'],
    );
  }
}
