// data/models/user_profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.uid,
    required super.isMale,
    required super.age,
    required super.height,
    required super.weight,
    required super.experienceLevel,
    required super.trainingDays,
    required super.weeklyTargetMin,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String,
      isMale: json['isMale'] as bool,
      age: (json['age'] as num).toInt(),
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      experienceLevel: ExperienceLevel.values.byName(json['experience']),
      trainingDays: (json['trainingDays'] as num).toInt(),
      weeklyTargetMin: (json['weeklyTargetMin'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'isMale': isMale,
    'age': age,
    'height': height,
    'weight': weight,
    'experience': experienceLevel.name, 
    'trainingDays': trainingDays,
    'weeklyTargetMin': weeklyTargetMin,
    'schemaVersion': SCHEMA_VERSION,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
