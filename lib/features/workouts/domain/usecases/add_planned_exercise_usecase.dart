import 'package:dartz/dartz.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/domain/params/add_planned_exercise_params.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';

class AddPlannedExerciseUseCase
    implements UseCase<PlannedExercise, AddPlannedExerciseParams> {
  PlannedExerciseRepo plannedExerciseRepo;
  AddPlannedExerciseUseCase({required this.plannedExerciseRepo});
  @override
  Future<Either<Failure, PlannedExercise>> call(
    AddPlannedExerciseParams params,
  ) async {
    return await plannedExerciseRepo.save(
      uid: params.uid,
      workoutId: params.workoutId,
      plannedExercise: PlannedExercise(
        plannedExerciseId: '',
        workoutId: params.workoutId,
        uid: params.uid,
        exerciseId: params.exerciseId,
        order: params.order,
        targetSets: params.targetSets,
        targetReps: params.targetReps,
        targetLoad: params.targetLoad,
        targetTempo: params.targetTempo,
        restSec: params.restSec,
        schemaVersion: SCHEMA_VERSION,
        createdAt: DateTime.now(),
      ),
    );
  }
}
