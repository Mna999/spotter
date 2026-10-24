import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';

class UpdatePlannedExerciseUseCase
    implements UseCase<PlannedExercise, PlannedExercise> {
  PlannedExerciseRepo plannedExerciseRepo;
  UpdatePlannedExerciseUseCase({required this.plannedExerciseRepo});

  @override
  Future<Either<Failure, PlannedExercise>> call(
    PlannedExercise plannedExercise,
  ) async {
    return await plannedExerciseRepo.update(plannedExercise: plannedExercise);
  }
}
