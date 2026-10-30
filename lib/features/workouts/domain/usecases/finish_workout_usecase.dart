import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class FinishWorkoutUseCase implements UseCase<WorkoutSession, WorkoutSession> {
  WorkoutRepo workoutRepo;
  FinishWorkoutUseCase({required this.workoutRepo});
  @override
  Future<Either<Failure, WorkoutSession>> call(WorkoutSession workout) async {
    workout.status = SessionStatus.finished;
    workout.endedAt = DateTime.now();
    workout.scheduledFor = null;
    return await workoutRepo.update(workout: workout);
  }
}
