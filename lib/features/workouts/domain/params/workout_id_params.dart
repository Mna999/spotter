import 'package:equatable/equatable.dart';

class WorkoutIdParams extends Equatable {
  final String uid;
  final String workoutId;

  const WorkoutIdParams({required this.uid, required this.workoutId});

  @override
  List<Object?> get props => [uid, workoutId];
}
