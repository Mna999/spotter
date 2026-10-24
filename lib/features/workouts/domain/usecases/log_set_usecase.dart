import 'package:dartz/dartz.dart';
import 'package:spotter/core/constants.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/set_summary.dart';
import 'package:spotter/features/workouts/domain/params/log_set_params.dart';
import 'package:spotter/features/workouts/domain/repository/set_repo.dart';

class LogSetUseCase extends UseCase<SetSummary, LogSetParams> {
  SetRepo setRepo;
  LogSetUseCase({required this.setRepo});
  @override
  Future<Either<Failure, SetSummary>> call(LogSetParams params) async {
    return await setRepo.saveSet(
      uid: params.uid,
      workoutId: params.workoutId,
      plannedExerciseId: params.plannedExerciseId,
      setSummary: SetSummary(
        setId: '',
        workoutId: params.workoutId,
        uid: params.uid,
        exerciseId: params.exerciseId,
        plannedExerciseId: params.plannedExerciseId,
        order: params.order,
        reps: params.reps,
        load: params.load,
        timeUnderTension: params.timeUnderTension,
        restSec: params.restSec,
        completedAt: DateTime.now(),
        schemaVersion: SCHEMA_VERSION,
        createdAt: DateTime.now(),
      ),
    );
  }
}
