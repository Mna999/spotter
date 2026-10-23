import 'package:equatable/equatable.dart';

class PlannedExercise extends Equatable {
  final String plannedExerciseId;

  final String workoutId;

  final String uid;

  final String exerciseId;

  final int order;

  final int targetSets;

  final int targetReps;

  final double targetLoad;

  final String targetTempo;

  final int restSec;

  const PlannedExercise({
    required this.plannedExerciseId,
    required this.workoutId,
    required this.uid,
    required this.exerciseId,
    required this.order,
    required this.targetSets,
    required this.targetReps,
    required this.targetLoad,
    required this.targetTempo,
    required this.restSec,
  });

  PlannedExercise copyWith({
    String? plannedExerciseId,
    String? workoutId,
    String? uid,
    String? exerciseId,
    int? order,
    int? targetSets,
    int? targetReps,
    double? targetLoad,
    String? targetTempo,
    int? restSec,
    int? schemaVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlannedExercise(
    plannedExerciseId: plannedExerciseId ?? this.plannedExerciseId,
    workoutId: workoutId ?? this.workoutId,
    uid: uid ?? this.uid,
    exerciseId: exerciseId ?? this.exerciseId,
    order: order ?? this.order,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    targetLoad: targetLoad ?? this.targetLoad,
    targetTempo: targetTempo ?? this.targetTempo,
    restSec: restSec ?? this.restSec,

  );

  @override
  List<Object?> get props => [
    plannedExerciseId,
    workoutId,
    uid,
    exerciseId,
    order,
    targetSets,
    targetReps,
    targetLoad,
    targetTempo,
    restSec,
  
  ];
}
