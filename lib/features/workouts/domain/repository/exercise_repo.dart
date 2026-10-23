import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/params/exercise_filter_params.dart';

abstract class ExerciseRepo {
  Future<Either<Failure, List<Exercise>>> list({
    required ExerciseFilterParams filter,
  });
  Future<Either<Failure, Exercise?>> get({required String id});
  Future<Either<Failure, List<Exercise>>> search({required String query});
}
