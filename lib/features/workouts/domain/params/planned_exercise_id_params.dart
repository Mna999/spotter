import 'package:equatable/equatable.dart';

class PlannedExerciseIdParams extends Equatable {
  final String uid;
  final String workoutId;
  final String plannedExerciseId;

  const PlannedExerciseIdParams({
    required this.uid,
    required this.workoutId,
    required this.plannedExerciseId,
  });

  @override
  List<Object?> get props => [uid, workoutId, plannedExerciseId];
}
