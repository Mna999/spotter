import 'package:equatable/equatable.dart';

class SetSummary extends Equatable {
  final String setId;

  final String workoutId;

  final String uid;

  final String exerciseId;

  final int order;

  final int reps;

  final double load;

  final int timeUnderTension;

  final double? rom;

  final String? tempo;

  final int? formScore;

  final Map<String, int>? faultCounts;

  final int restSec;

  final DateTime completedAt;

  const SetSummary({
    required this.setId,
    required this.workoutId,
    required this.uid,
    required this.exerciseId,
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
  });

  SetSummary copyWith({
    String? setId,
    String? workoutId,
    String? uid,
    String? exerciseId,
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
    int? schemaVersion,
    DateTime? updatedAt,
  }) => SetSummary(
    setId: setId ?? this.setId,
    workoutId: workoutId ?? this.workoutId,
    uid: uid ?? this.uid,
    exerciseId: exerciseId ?? this.exerciseId,
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
  );

  @override
  List<Object?> get props => [
    setId,
    workoutId,
    uid,
    exerciseId,
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
  ];
}
