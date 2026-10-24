import 'package:equatable/equatable.dart';

class LogSetParams extends Equatable {
  final String workoutId;
  final String uid;
  final String exerciseId;
  final String plannedExerciseId;
  final int order;
  final int reps;
  final double load;
  final int timeUnderTension;  
  final int restSec;

  const LogSetParams({
    required this.workoutId,
    required this.uid,
    required this.exerciseId,
    required this.plannedExerciseId,
    required this.order,
    required this.reps,
    required this.load,
    required this.timeUnderTension,
    required this.restSec,
  });

  @override
  List<Object?> get props => [
        workoutId, uid, exerciseId, plannedExerciseId, order,
        reps, load, timeUnderTension, restSec,
      ];
}
