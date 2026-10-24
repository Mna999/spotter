import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/params/planned_exercise_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class GetSetsForWorkoutUseCase
    implements UseCase<List<SetSummary>, PlannedExerciseIdParams> {
  SetRepo setRepo;

  GetSetsForWorkoutUseCase({required this.setRepo});
  @override
  Future<Either<Failure, List<SetSummary>>> call(
    PlannedExerciseIdParams params,
  ) async {
    return setRepo.getSetsFor(
      uid: params.uid,
      workoutId: params.workoutId,
      plannedExerciseId: params.plannedExerciseId,
    );
  }
}
