import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/domain/params/create_params.dart';
import 'package:spotter/features/workouts/domain/repository/workout_repo.dart';

class CreateWorkoutUseCase implements UseCase<WorkoutSession, CreateParams> {
  WorkoutRepo workoutRepo;
  CreateWorkoutUseCase({required this.workoutRepo});
  @override
  Future<Either<Failure, WorkoutSession>> call(CreateParams params) async {
    final DateTime? scheduledFor = params.scheduledFor;
    final SessionStatus status = scheduledFor == null
        ? SessionStatus.inProgress
        : SessionStatus.planned;

    return await workoutRepo.save(
      workout: WorkoutSession(workoutId: '', uid: params.uid, status: status),
    );
  }
}
