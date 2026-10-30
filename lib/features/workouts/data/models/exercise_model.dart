import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/features/workouts/domain/entities/cue_text.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.exerciseId,
    required super.nameAr,
    required super.nameEn,
    super.cues,
    super.repThresholds,
    super.requiredLandmarks,
    super.rules,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  factory ExerciseModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return ExerciseModel(
      exerciseId: (json['exerciseId'] as String?)?.trim().isNotEmpty == true
          ? json['exerciseId'] as String
          : (documentId ?? ''),
      nameAr: (json['nameAr'] as String?) ?? '',
      nameEn: (json['nameEn'] as String?) ?? '',
      cues: (json['cues'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, CueText.fromJson(v)),
      ),
      repThresholds: json['repThresholds'] as Map<String, dynamic>?,
      requiredLandmarks: (json['requiredLandmarks'] as List?)?.cast<int>(),
      rules: (json['rules'] as List?)?.cast<Map<String, dynamic>>(),
      // The seeded catalogue documents only carry the fields above, so fall
      // back to defaults instead of throwing on the missing ones.
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? SCHEMA_VERSION,
      createdAt:
          _toDateTime(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  factory ExerciseModel.fromEntity(Exercise e) {
    return ExerciseModel(
      exerciseId: e.exerciseId,
      nameAr: e.nameAr,
      nameEn: e.nameEn,
      requiredLandmarks: e.requiredLandmarks,
      repThresholds: e.repThresholds,
      rules: e.rules,
      cues: e.cues,
      schemaVersion: e.schemaVersion,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  Map<String, dynamic> toJson({bool isCreating = false}) {
    return {
      'exerciseId': exerciseId,
      'nameAr': nameAr,
      'nameLowerAr': nameAr.toLowerCase(),
      'nameEn': nameEn,
      'nameLowerEn': nameEn.toLowerCase(),
      'cues': cues?.map((k, v) => MapEntry(k, v.toJson())),
      'repThresholds': repThresholds,
      'requiredLandmarks': requiredLandmarks,
      'rules': rules,
      'createdAt': isCreating ? FieldValue.serverTimestamp() : createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': SCHEMA_VERSION,
    };
  }
}
