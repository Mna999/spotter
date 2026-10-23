import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/params/planned_exercise_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/planned_exercise_repo.dart';

class DeletePlannedExerciseUseCase
    implements UseCase<Unit, PlannedExerciseIdParams> {
  PlannedExerciseRepo plannedExerciseRepo;
  DeletePlannedExerciseUseCase({required this.plannedExerciseRepo});

  @override
  Future<Either<Failure, Unit>> call(PlannedExerciseIdParams params) async {
    return await plannedExerciseRepo.delete(
      uid: params.uid,
      workoutId: params.workoutId,
      plannedExerciseId: params.plannedExerciseId,
    );
  }
}
