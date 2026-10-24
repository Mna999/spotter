import 'package:equatable/equatable.dart';

class UpdateSetParams extends Equatable {
  final String uid;
  final String workoutId;
  final String plannedExerciseId;
  final String setId;
  final int? reps;
  final double? load;
  final int? timeUnderTension;
  final int? restSec;

  const UpdateSetParams({
    required this.setId,
    required this.uid,
    required this.workoutId,
    required this.plannedExerciseId,
    this.reps,
    this.load,
    this.timeUnderTension,
    this.restSec,
  });

  @override
  List<Object?> get props => [
    setId,
    reps,
    load,
    timeUnderTension,
    restSec,
    uid,
    workoutId,
    plannedExerciseId,
  ];
}
