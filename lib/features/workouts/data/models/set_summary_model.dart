import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';

class SetSummaryModel extends SetSummary {
  SetSummaryModel({
    required super.setId,
    required super.workoutId,
    required super.uid,
    required super.exerciseId,
    required super.plannedExerciseId,
    required super.order,
    required super.reps,
    required super.load,
    required super.timeUnderTension,
    required super.restSec,
    required super.completedAt,
    super.faultCounts,
    super.formScore,
    super.rom,
    super.tempo,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  factory SetSummaryModel.fromJson(Map<String, dynamic> json) {
    return SetSummaryModel(
      setId: json['setId'] as String,
      workoutId: json['workoutId'] as String,
      uid: json['uid'] as String,
      exerciseId: json['exerciseId'] as String,
      plannedExerciseId: json['plannedExerciseId'] as String,
      order: (json['order'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      load: (json['load'] as num).toDouble(),
      timeUnderTension: (json['timeUnderTension'] as num).toInt(),
      restSec: (json['restSec'] as num).toInt(),
      completedAt: (json['completedAt'] as Timestamp).toDate(),
      faultCounts: (json['faultCounts'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      formScore: (json['formScore'] as num?)?.toInt(),
      rom: (json['rom'] as num?)?.toDouble(),
      tempo: json['tempo'] as String?,
      schemaVersion: (json['schemaVersion'] as num).toInt(),

      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory SetSummaryModel.fromEntity(SetSummary s) {
    return SetSummaryModel(
      setId: s.setId,
      workoutId: s.workoutId,
      uid: s.uid,
      exerciseId: s.exerciseId,
      plannedExerciseId: s.plannedExerciseId,
      order: s.order,
      reps: s.reps,
      load: s.load,
      timeUnderTension: s.timeUnderTension,
      restSec: s.restSec,
      completedAt: s.completedAt,
      faultCounts: s.faultCounts,
      formScore: s.formScore,
      rom: s.rom,
      tempo: s.tempo,
      schemaVersion: s.schemaVersion,
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    );
  }

  Map<String, dynamic> toJson({bool isCreating = false}) {
    return {
      'setId': setId,
      'workoutId': workoutId,
      'uid': uid,
      'exerciseId': exerciseId,
      'plannedExerciseId': plannedExerciseId,
      'order': order,
      'reps': reps,
      'load': load,
      'timeUnderTension': timeUnderTension,
      'restSec': restSec,
      'completedAt': completedAt,
      'faultCounts': faultCounts,
      'formScore': formScore,
      'rom': rom,
      'tempo': tempo,
      'createdAt': isCreating ? FieldValue.serverTimestamp() : createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': SCHEMA_VERSION,
    };
  }
}
