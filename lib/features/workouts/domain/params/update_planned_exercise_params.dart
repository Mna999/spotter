import 'package:equatable/equatable.dart';

class UpdatePlannedExerciseParams extends Equatable {
  final String uid;
  final String workoutId;
  final String plannedExerciseId;

  final int? order;
  final int? targetSets;
  final int? targetReps;
  final double? targetLoad;
  final String? targetTempo;
  final int? restSec;

  const UpdatePlannedExerciseParams({
    required this.uid,
    required this.workoutId,
    required this.plannedExerciseId,
    this.order,
    this.targetSets,
    this.targetReps,
    this.targetLoad,
    this.targetTempo,
    this.restSec,
  });

  @override
  List<Object?> get props => [
        uid, workoutId, plannedExerciseId,
        order, targetSets, targetReps, targetLoad, targetTempo, restSec,
      ];
}
