import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/params/workout_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';

class GetPlannedExercisesUseCase
    implements UseCase<List<PlannedExercise>, WorkoutIdParams> {
  PlannedExerciseRepo plannedExerciseRepo;
  GetPlannedExercisesUseCase({required this.plannedExerciseRepo});
  @override
  Future<Either<Failure, List<PlannedExercise>>> call(
    WorkoutIdParams params,
  ) async {
    return await plannedExerciseRepo.list(
      uid: params.uid,
      workoutId: params.workoutId,
    );
  }
}
