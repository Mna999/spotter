import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';

abstract class PlannedExerciseRepo {
  Future<Either<Failure, PlannedExercise>> save({
    required String uid,
    required String workoutId,
    required PlannedExercise plannedExercise,
  });

  Future<Either<Failure, PlannedExercise?>> get({
    required String uid,
    required String workoutId,
    required String exerciseId,
  });

  Future<Either<Failure, List<PlannedExercise>>> list({
    required String uid,
    required String workoutId,
  });

  Future<Either<Failure, PlannedExercise>> update({
    required PlannedExercise plannedExercise,
  });
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  });
}
