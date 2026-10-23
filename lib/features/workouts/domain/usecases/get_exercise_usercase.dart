import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/params/exercise_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/exercise_repo.dart';

class GetExerciseUseCase implements UseCase<Exercise?, ExerciseIdParams> {
  ExerciseRepo exerciseRepo;
  GetExerciseUseCase({required this.exerciseRepo});
  @override
  Future<Either<Failure, Exercise?>> call(ExerciseIdParams params) async {
    return await exerciseRepo.get(id: params.id);
  }
}
