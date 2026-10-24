import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';

class PlannedExerciseModel extends PlannedExercise {
   PlannedExerciseModel({
    required super.plannedExerciseId,
    required super.workoutId,
    required super.uid,
    required super.exerciseId,
    required super.order,
    required super.targetSets,
    required super.targetReps,
    required super.targetLoad,
    required super.targetTempo,
    required super.restSec,
    required super.schemaVersion,
    required super.createdAt,
    super.updatedAt,
  });

  factory PlannedExerciseModel.fromJson(Map<String, dynamic> json) {
    return PlannedExerciseModel(
      plannedExerciseId: json['plannedExerciseId'] as String,
      workoutId: json['workoutId'] as String,
      uid: json['uid'] as String,
      exerciseId: json['exerciseId'] as String,
      order: (json['order'] as num).toInt(),
      targetSets: (json['targetSets'] as num).toInt(),
      targetReps: (json['targetReps'] as num).toInt(),
      targetLoad: (json['targetLoad'] as num).toDouble(),
      targetTempo: json['targetTempo'] as String,
      restSec: (json['restSec'] as num).toInt(),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory PlannedExerciseModel.fromEntity(PlannedExercise pe) {
    return PlannedExerciseModel(
      plannedExerciseId: pe.plannedExerciseId,
      workoutId: pe.workoutId,
      uid: pe.uid,
      exerciseId: pe.exerciseId,
      order: pe.order,
      targetSets: pe.targetSets,
      targetReps: pe.targetReps,
      targetLoad: pe.targetLoad,
      targetTempo: pe.targetTempo,
      restSec: pe.restSec,
      schemaVersion: pe.schemaVersion,
      createdAt: pe.createdAt,
      updatedAt: pe.updatedAt,
    );
  }

  Map<String, dynamic> toJson({bool isCreating = false}) {
    return {
      'plannedExerciseId': plannedExerciseId,
      'workoutId': workoutId,
      'uid': uid,
      'exerciseId': exerciseId,
      'order': order,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetLoad': targetLoad,
      'targetTempo': targetTempo,
      'restSec': restSec,
      'schemaVersion': SCHEMA_VERSION,
      'createdAt': isCreating ? FieldValue.serverTimestamp() : createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
