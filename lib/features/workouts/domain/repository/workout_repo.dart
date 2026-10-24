import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';

abstract class WorkoutRepo {
  Future<Either<Failure, WorkoutSession>> save({
    required WorkoutSession workout,
  });

  Future<Either<Failure, WorkoutSession>> update({
    required WorkoutSession workout,
  });

  Future<Either<Failure, WorkoutSession?>> get({
    required String uid,
    required String workoutId,
  });

  Future<Either<Failure, List<WorkoutSession>>> recent({
    required String uid,
    int limit = 20,
  });

  Future<Either<Failure, List<WorkoutSession>>> inRange({
    required String uid,
    required DateTime start,
    required DateTime end,
  });

  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String workoutId,
  });
}
