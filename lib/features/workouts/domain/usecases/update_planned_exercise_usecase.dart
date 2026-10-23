import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/params/update_planned_exercise_params.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';

class UpdatePlannedExerciseUseCase
    implements UseCase<PlannedExercise, UpdatePlannedExerciseParams> {
  PlannedExerciseRepo plannedExerciseRepo;
  UpdatePlannedExerciseUseCase({required this.plannedExerciseRepo});

  @override
  Future<Either<Failure, PlannedExercise>> call(
    UpdatePlannedExerciseParams params,
  ) async {
    return await plannedExerciseRepo.update(
      uid: params.uid,
      workoutId: params.workoutId,
      plannedExerciseId: params.plannedExerciseId,
      order: params.order,
      restSec: params.restSec,
      targetLoad: params.targetLoad,
      targetReps: params.targetReps,
      targetSets: params.targetSets,
      targetTempo: params.targetTempo,
    );
  }
}
