import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';

abstract class SetRepo {
  Future<Either<Failure, SetSummary>> saveSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required SetSummary setSummary,
  });

  Future<Either<Failure, List<SetSummary>>> getSetsFor({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
  });
  Future<Either<Failure, Unit>> deleteSet({
    required String uid,
    required String workoutId,
    required String plannedExerciseId,
    required String setId,
  });

  Future<Either<Failure, SetSummary>> update({required SetSummary setSummary});
}
