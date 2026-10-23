import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/params/workout_id_params.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class StartWorkoutUseCase implements UseCase<WorkoutSession, WorkoutIdParams> {
  WorkoutRepo workoutRepo;

  StartWorkoutUseCase({required this.workoutRepo});
  @override
  Future<Either<Failure, WorkoutSession>> call(WorkoutIdParams params) async {
    return await workoutRepo.update(
      uid: params.uid,
      workoutId: params.workoutId,
      status: SessionStatus.inProgress,
      startedAt: DateTime.now(),
      scheduledFor: null,
    );
  }
}
