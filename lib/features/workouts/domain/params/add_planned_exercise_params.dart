import 'package:equatable/equatable.dart';

class AddPlannedExerciseParams extends Equatable {
  final String uid;
  final String workoutId;

  final String exerciseId;

  final int order;

  final int targetSets;
  final int targetReps;
  final double targetLoad;
  final String targetTempo;
  final int restSec;

  const AddPlannedExerciseParams({
    required this.uid,
    required this.workoutId,
    required this.exerciseId,
    required this.order,
    required this.targetSets,
    required this.targetReps,
    required this.targetLoad,
    required this.targetTempo,
    required this.restSec,
  });

  @override
  List<Object?> get props => [
        uid, workoutId, exerciseId, order,
        targetSets, targetReps, targetLoad, targetTempo, restSec,
      ];
}
