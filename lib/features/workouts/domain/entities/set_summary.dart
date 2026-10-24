import 'package:equatable/equatable.dart';

class SetSummary extends Equatable {
   String setId;

   String workoutId;

   String uid;

   String exerciseId;

   String plannedExerciseId;

   int order;

   int reps;

   double load;

   int timeUnderTension;

   double? rom;

   String? tempo;

   int? formScore;

   Map<String, int>? faultCounts;

   int restSec;

   DateTime completedAt;

   int schemaVersion;

   DateTime createdAt;

   DateTime? updatedAt;

   SetSummary({
    required this.setId,
    required this.workoutId,
    required this.uid,
    required this.exerciseId,
    required this.plannedExerciseId,
    required this.order,
    required this.reps,
    required this.load,
    required this.timeUnderTension,
    this.rom,
    this.tempo,
    this.formScore,
    this.faultCounts,
    required this.restSec,
    required this.completedAt,
    required this.schemaVersion,
    required this.createdAt,
    this.updatedAt,
  });

  SetSummary copyWith({
    String? setId,
    String? workoutId,
    String? uid,
    String? exerciseId,
    String? plannedExerciseId,
    int? order,
    int? reps,
    double? load,
    int? timeUnderTension,
    double? rom,
    String? tempo,
    int? formScore,
    Map<String, int>? faultCounts,
    int? restSec,
    DateTime? completedAt,
    DateTime? createdAt,
    int? schemaVersion,
    DateTime? updatedAt,
  }) => SetSummary(
    setId: setId ?? this.setId,
    workoutId: workoutId ?? this.workoutId,
    uid: uid ?? this.uid,
    exerciseId: exerciseId ?? this.exerciseId,
    plannedExerciseId: plannedExerciseId ?? this.plannedExerciseId,
    order: order ?? this.order,
    reps: reps ?? this.reps,
    load: load ?? this.load,
    timeUnderTension: timeUnderTension ?? this.timeUnderTension,
    rom: rom ?? this.rom,
    tempo: tempo ?? this.tempo,
    formScore: formScore ?? this.formScore,
    faultCounts: faultCounts ?? this.faultCounts,
    restSec: restSec ?? this.restSec,
    completedAt: completedAt ?? this.completedAt,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    setId,
    workoutId,
    uid,
    exerciseId,
    plannedExerciseId,
    order,
    reps,
    load,
    timeUnderTension,
    rom,
    tempo,
    formScore,
    faultCounts,
    restSec,
    completedAt,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
}
