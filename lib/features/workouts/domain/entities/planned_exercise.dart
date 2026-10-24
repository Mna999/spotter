import 'package:equatable/equatable.dart';

class PlannedExercise extends Equatable {
   String plannedExerciseId;

   String workoutId;

   String uid;

   String exerciseId;

   int order;

   int targetSets;

   int targetReps;

   double targetLoad;

   String targetTempo;

   int restSec;

   int schemaVersion;

   DateTime createdAt;

   DateTime? updatedAt;

   PlannedExercise({
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
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
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
    schemaVersion: schemaVersion ?? this.schemaVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
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
    schemaVersion,
    createdAt,
    updatedAt,
  
  ];
}
