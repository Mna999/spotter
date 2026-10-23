import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/params/exercise_filter_params.dart';
import 'package:spotter/features/workouts/domain/repository/exercise_repo.dart';

class ListExercisesUseCase
    implements UseCase<List<Exercise>, ExerciseFilterParams> {
  ExerciseRepo exerciseRepo;
  ListExercisesUseCase({required this.exerciseRepo});
  @override
  Future<Either<Failure, List<Exercise>>> call(
    ExerciseFilterParams params,
  ) async {
    return await exerciseRepo.list(filter: params);
  }
}
